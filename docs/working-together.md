# Working Together

## Git a github account of your own

Add your credentials for easy pushing and pulling from your online github repository. You will want to create a Person Access Token for your password (https://github.com/settings/tokens):

```bash
git config --global credential.helper store
```

-- global can be replaced with --local if you do not want to affect all your repositories.
## Fork the Summit Events repository

## Freshen your fork at any time

Check what remotes you currently are set up for repository:

```bash
git remote -v
```

If you don't see the Summit Events main repository add the Summit Events main repository as upstream remote to your repository:

```bash
git remote add upstream https://github.com/tcdahlberg/Summit-Events-App.git
```

Check to make sure you see the Summit Events main repository in the upstream remote list:

```bash
git remote -v
```

Fetch and merge the upstream remote to your local repository:

```bash
git fetch upstream
git checkout master
git merge upstream/master
```

Push the freshened changes from the upstream remote to your github repository:
```bash
git push
```


## Make a pull request to contribute your innovations