# IETF Internet-Draft

To-Do list:

- [ ] Replace rfcdiff with [iddiff](https://github.com/ietf-tools/iddiff)
- [ ] Consider adding [idnits](https://github.com/ietf-tools/idnits) check
- [ ] Consider adding [rfclint](https://github.com/ietf-tools/rfclint) check

## Usage

[draft.md](draft.md) contains the source content of the Internet-Draft (ID) in [kramdown-rfc](https://github.com/cabo/kramdown-rfc) Markdown format. All other ID formats (XML, plain text, and HTML) are generated from this Markdown source.

### Development Container

This repository comes with a [.devcontainer.json](.devcontainer.json) configuration file that uses [fclad-ietf/ietf-id-devcontainer](https://github.com/fclad-ietf/ietf-id-devcontainer/pkgs/container/ietf-id-devcontainer).

The development container includes the [kramdown-rfc](https://github.com/cabo/kramdown-rfc) and [xml2rfc](https://github.com/ietf-tools/xml2rfc) binaries needed to generate the XML, plain text, and HTML versions of the ID from Markdown, as well as producing [iddiffs](https://author-tools.ietf.org/iddiff).

For more information on development containers, see https://containers.dev/.


### Build

The provided [Makefile](Makefile) has targets to generate XML, plain text, HTML, and iddiff artifacts from the [draft.md](draft.md). The easiest way to build from this Makefile is from inside the [development container](#development-container).

**XML:**

```shell
make xml
```

Note: the XML file is also generated when using any of the following commands.

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


### Workflow

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
