# IETF Internet-Draft

## Build

**Plain text:**

```shell
make
```

or

```shell
make txt
```

**HTML:**

```shell
make html
```

## Produce RFCdiff

```shell
make diff
```

## Workflow

```shell
# 1. Work on changes in current branch, commit, push
# 2. If not on master, merge revision branch into master, then delete revision
#    branch with "git branch -d revision-*; git remote prune origin"
# 3. Submit to datatracker
# 4. Tag the submitted revision using:
make tag && git push --tags
# 5. Create a branch for next revision and bump version number using:
make bump
# 6. Push the new revision branch using:
git push -u origin revision-*
# Repeat from 1.
```
