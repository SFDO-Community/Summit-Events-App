# Git - ***Notes***

## Git commands I keep using

Resetting my local repository to what is on the remote:

```git
git fetch origin
git reset --hard origin/master
git clean -f
```

Connecting to remote?

```git
git remote add [name] [URL]
```


Getting new .gitignore entries to work ***Make sure you have committed all other changes before doing this***:

```git
git rm -rf --cached .
git add .
git commit -m "I just updated ignore with..."
```
