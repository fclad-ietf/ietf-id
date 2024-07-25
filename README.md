# IETF Internet-Draft

## Build

**Plain text:**

```shell
make # or "make txt"
```

**HTML:**

```shell
make html
```

**RFCdiff:**

```shell
make diff
```


## Workflow

1. Work on changes in current branch, commit, push.

2. If not on master, merge revision branch into master, then delete revision
   branch with
```shell
git branch -d revision-* && git remote prune origin
```

3. Submit to datatracker.

4. Tag the submitted revision with
```shell
make tag && git push --tags
```

5. Create a branch for next revision and bump version number with
```shell
make bump
```

6. Push the new revision branch with
```shell
git push -u origin revision-*
```

Repeat from 1.
