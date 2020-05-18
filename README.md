# Investigative Debugging Workshop Docker container

## Setup

1. Install Docker.
2. Install [VSCode](https://code.visualstudio.com/). 
   I've customizes the .devcontainer config to Just Work within VSCode, and I'll be doing all my demoing within VSCode. You can use this container definition without VSCode, but I can't help you with it. If you do use it outside of VSCode, you may want to reference `.devcontainer/devcontainer.json` for how to build and start the Docker container with the expected  configuration.
3. Install the [Remote Development Extension Pack](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.vscode-remote-extensionpack).  Cmd-Shift-X and search for "Remote Development".
4. Git clone this repo
5. Open VSCode in the `idw` repo. (`cd` to the directory and run `code .`)
6. Reopen VSCode inside the Docker container: Cmd-Shift-P and search for `Remote-Containers: Reopen inside container`
7. Go make a pot of coffee, because if all goes well the container build will take a while!
8. If the build breaks for some reason, let me know!