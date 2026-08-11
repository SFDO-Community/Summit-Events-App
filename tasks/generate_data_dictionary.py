from pathlib import PurePosixPath
from zipfile import ZipFile

from lxml.etree import XMLSyntaxError

from cumulusci.tasks.datadictionary import GenerateDataDictionary, PackageVersion
from cumulusci.utils.xml import metadata_tree


class SafeGenerateDataDictionary(GenerateDataDictionary):
    """GenerateDataDictionary, but skips metadata files that fail to parse
    instead of aborting the entire multi-release walk.

    Some old published GitHub releases contain corrupted metadata files
    (e.g. release/0.27.0.1 has a byte-corrupted .object-meta.xml with a
    stray "cci " prefix before the XML declaration). Those releases can't
    be edited after the fact, so the task needs to tolerate them.
    """

    def _skip(self, path: str, version: PackageVersion, error: XMLSyntaxError):
        self.logger.warning(
            f"Skipping unparseable metadata file {path} in "
            f"{version.package.package_name} {version.version}: {error}"
        )

    def _process_mdapi_release(self, zip_file: ZipFile, version: PackageVersion):
        for f in zip_file.namelist():
            path = PurePosixPath(f)
            if path.parent == PurePosixPath("src/objects") and path.suffix == ".object":
                sobject_name = path.stem
                if sobject_name.count("__") == 1:
                    sobject_name = f"{version.package.namespace}{sobject_name}"

                try:
                    element = metadata_tree.fromstring(zip_file.read(f))
                except XMLSyntaxError as e:
                    self._skip(f, version, e)
                    continue

                self._process_object_element(sobject_name, element, version)

    def _process_sfdx_release(self, zip_file: ZipFile, version: PackageVersion):
        for f in zip_file.namelist():
            path = PurePosixPath(f)
            # Be flexible about processing directories in SFDX context.
            # This may not be optimal if the repo contains multiple
            # 2GP package subdirectories.
            if "objects/" in f and not f.startswith("unpackaged/"):
                if path.suffixes == [".object-meta", ".xml"]:
                    sobject_name = path.name[: -len(".object-meta.xml")]
                    if sobject_name.count("__") == 1:
                        sobject_name = f"{version.package.namespace}{sobject_name}"

                    try:
                        element = metadata_tree.fromstring(zip_file.read(f))
                    except XMLSyntaxError as e:
                        self._skip(f, version, e)
                        continue

                    if self._should_process_object(
                        version.package.namespace, sobject_name, element
                    ):
                        self._process_object_element(sobject_name, element, version)
                    else:
                        # If this is an object type from which we shouldn't process any fields,
                        # track it in omit_sobjects so we can drop any fields later if we don't have
                        # the right information at time of processing.

                        # Note that the owning object may be in a dependency package, so we won't find it below.
                        if not self._should_process_object_fields(
                            sobject_name, element
                        ):
                            self.omit_sobjects.add(sobject_name)
                elif path.suffixes == [".field-meta", ".xml"]:
                    # To get the sObject name, we need to remove the `/fields/SomeField.field-meta.xml`
                    # and take the last path component

                    # Find the sObject metadata file
                    sobject_name = f"{path.parent.parent.stem}"
                    sobject_file = str(
                        path.parent.parent / f"{sobject_name}.object-meta.xml"
                    )
                    if sobject_name.count("__") == 1:
                        sobject_name = f"{version.package.namespace}{sobject_name}"

                    # If the object-meta file is locatable, load it so we can check
                    # if this is a Custom Setting.
                    object_entity = None
                    if sobject_file in zip_file.namelist():
                        try:
                            object_entity = metadata_tree.fromstring(
                                zip_file.read(sobject_file)
                            )
                        except XMLSyntaxError as e:
                            self._skip(sobject_file, version, e)

                    if self._should_process_object_fields(sobject_name, object_entity):
                        try:
                            field_element = metadata_tree.fromstring(zip_file.read(f))
                        except XMLSyntaxError as e:
                            self._skip(f, version, e)
                            continue

                        self._process_field_element(
                            sobject_name, field_element, version
                        )
