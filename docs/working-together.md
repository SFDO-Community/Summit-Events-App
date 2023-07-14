# Working Together

## Git a github account of your own

Add your credentials for easy pushing and pulling from your online github repository. You will want to create a Person Access Token for your password (https://github.com/settings/tokens):

```bash
git config --global credential.helper store
```

-- global can be replaced with --local if you do not want to affect all your repositories.
## Fork the Summit Events repository

To fork a repository, go to the Summit Events Repository and click "Fork" as shown below:
![image](https://github.com/FrancisTR/Summit-Events-App/assets/123771828/457a12b9-6237-480c-b1b5-854de1d356dd)

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

### Make sure you follow these steps:

- Anything added must be pushed in a new branch OR in a forked repository.
- In the pull request, make sure to give a description of the changes you made based on the template given in the pull request.
- If your pull request is reviewed and approved, your pull request will be merged to the main branch.
### Thank you for Contributing!
