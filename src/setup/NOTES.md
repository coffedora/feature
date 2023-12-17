# Dev Container Templates: FEdora Based Devcontainer - Coffedora

## How to get the CLI
On linux you can install the ClI tool via homebrew.
On windows you have to use it from wsl or install npm first.
Easiest way to get npm is the *node version manager* **nvm** 
```powershell
scoop install nvm
nvm install lts
nvm apply lts
npm install -g @devcontainers/cli
```


## How to get the Template in my project
Apply the template in a directory and edit the ARG in Dockerfile. YOu have also to adjust the name in the devcontainer.json
```json
		"ghcr.io/coffedora/feature/setup:latest": {
			"userName": "automatic",
			"copr": "automatic",
			"dnfInstall": "automatic",
			"dnfRemove": "automatic",
			"languageSupport": "automatic"
		}
```
## VSCode Customizations
   "customizations": {
        "vscode": {
            "extensions": [
                "golang.Go",
                "GitHub.copilot",
                "GitHub.copilot-chat",
                "yzhang.markdown-all-in-one",
                "formulahendry.github-actions",
                "ms-azuretools.vscode-docker"
            ],
            "settings": {
                "files.autoSave": "afterDelay",
                "editor.smoothScrolling": true,
                "terminal.integrated.lineHeight": 1.5,
                "editor.fontLigatures": true,
                "editor.lineHeight": 1.5,
                "editor.minimap.enabled": false,
                "editor.tabSize": 2,
                "editor.semanticTokenColorCustomizations": {
                    "enabled": true
                },
                "editor.semanticHighlighting.enabled": true,
                "files.eol": "\n",
                "extensions.ignoreRecommendations": true,
                "task.problemMatchers.neverPrompt": {
                    "shell": true
                }
            }
        }
    }