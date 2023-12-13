# setup Fedora Environment 🧊☕️🪶 (setup)

Setup your Fedora devcontainer Environment

## Example Usage

```json
"features": {
    "ghcr.io/coffedora/feature/setup:0": {}
}
```

## Options

| Options Id | Description | Type | Default Value |
|-----|-----|-----|-----|
| username | Auto use existing user with home dir or create remote-user | string | automatic |
| copr(TODO) | Add Copr Repositories.automatic Recognizes ENV variables of packages to add their copr repos | string | automatic |
| dnfInstall | packages installed by default separated by whitespaces. automatic installs requirements including those of other settings  | string | automatic |
| remove(TODO) | Remove packages from Image | string | automatic |



---

_Note: This file was auto-generated from the [devcontainer-feature.json](https://github.com/coffedora/feature/blob/main/src/setup/devcontainer-feature.json).  Add additional notes to a `NOTES.md`._

