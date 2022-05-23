# DFXCTL
## Info
This file contains HOWTO instructions for running scripts on your environments

## Requirements
- Docker >= 17
- User with shell and rights to run docker
- Git for downloading repository
- Internet connection for downloading docker images from docker hub

*All instructions tested on Ubuntu 20, but they will work for other Linux system.*
*You can choose which you are familiar with.*

------------
## About
This project contains tools for **[Internet Computer canister](https://smartcontracts.org/ "Smart Contracts")** development to: 
- Develop more easily on Windows
- Get started more quickly with a prebuilt development toolkit and
- Manage multiple dfx projects more efficiently in your CLI

The docker container (which can be found in **[DockerHub](https://hub.docker.com/r/identitylabs/dfxctl)**) comes prebuilt with everything a developer needs to get started building and deploying canisters on the Internet Computer:
- **dfx**
- **rust**
- **nodejs**
- other libs and tools
- default project for environment setup checks (we're using **[Internet Identity](https://smartcontracts.org/docs/current/tokenomics/identity-auth/what-is-ic-identity)**, but it could be any)

**dfxctl**, the command line tool to interact with the docker environment, is what you'll be using to manage your projects.

## Build
- Open shell in the folder which contains Dockerfile
- Run `docker build -t dfxctl .`
- You will get a docker image with the name **dfxctl** after the build finishes
- Build arguments can be passed to manage versions

### Build Arguments:
- **RUST_VERSION** - Version of Rust which will be installed in image.
- **DFX_VERSION** - Version of DFX which will be installed in image.
- **NODE_INSTALL_VERSION** - Version of Nodejs which will be installed in image.
- **RUN_INTERNET_IDENTITY** - Use Internet Identity as default_project.

## Run
- Create a projects folder in your root directory (the below assumes **/Projects**)
- Each project should be a subfolder within the projects folder
- Open shell in the root directory
- Run `docker run -v $(pwd):/Projects -p 8000:8000 -p 8080:8080 --name my_dfx dfxctl`

Docker will run `/usr/bin/dfx_run` script, which will run **dfx** with **default_project** project.
**default_project** - will be Internet Identity if **RUN_INTERNET_IDENTITY** env var is `true` (by default)

### Environment Variables:
- **DFX_PROJECTS_DIR** - Path **inside** your docker which must contain projects. Default: **/Projects**


### dfxctl
Script works as a **wrapper** above dfx and exposes useful interactivity with dfx.
Any libraries required for your projects should be installed separately on your own.
For interacting with your projects inside this Docker container you need use the `docker exec` command in addition to the main `docker run` process:
- `docker exec my_dfx dfxctl help`  - will show help page of **dfxctl**
- `docker exec my_dfx dfxctl list`  - will show projects inside Project dir

Entire list of commands:
```bash
DFX Controller script.

Syntax: dfxctl [-h|--help] (start|stop|status|delete|clean|list) project_name

options:
help                  Print this Help.
start                 Start your project in dfx.
stop                  Stop your project in dfx.
status                Status of canisters in your project.
delete                Delete your project in dfx.
clean                 Clean your project in dfx.
list                  List of Projects.

```
## Examples
- List available projects in mounted folder
```bash
docker exec -it my_dfx dfxctl list
 2022-05-11 18:44:10 [INFO ] Listing your projects
 2022-05-11 18:44:10 [INFO ] Current project folder is: /Projects

project-one
project-two
```

- Start `project-one`
*(be sure that you have install all necessary libs before this point)*
```bash
docker exec -it my_dfx dfxctl start project-one
 2022-05-11 19:04:33 [INFO ] Starting Project: project-one

Creating a wallet canister on the local network.
The wallet canister on the "local" network for user "default" is "aaaaa-aaaaa-aaaaa-aaaaa-aaa"
Deploying all canisters.
Creating canisters...
Creating canister "example"...
"example" canister created with canister id: "aaaaa-aaaaa-aaaaa-aaaaa-aaa"
Building canisters...
Building frontend...
Generating type declarations for canister example:
  src/declarations/example/example.did.d.ts
  src/declarations/example/example.did.js
  src/declarations/example/index.js
  src/declarations/example/example.did

Installing canisters...
Creating UI canister on the local network.
The UI canister on the "local" network is "aaaaa-aaaaa-aaaaa-aaaaa-aaa"
Installing code for canister example, with canister_id aaaaa-aaaaa-aaaaa-aaaaa-aaa
Uploading assets to asset canister...
Starting batch.
Staging contents of new and changed assets:
  /index.html (gzip) 1/1 (456 bytes)
  /favicon.ico 1/1 (15406 bytes)
  /index.html 1/1 (806 bytes)
  /index.js (gzip) 1/1 (145127 bytes)
  /index.js 1/1 (607109 bytes)
  /index.js.map 1/1 (658869 bytes)
  /index.js.map (gzip) 1/1 (149549 bytes)
  /logo.png 1/1 (25397 bytes)
  /main.css 1/1 (783 bytes)
  /main.css (gzip) 1/1 (356 bytes)
  /sample-asset.txt 1/1 (25 bytes)
Committing batch.
Deployed canisters.
URLs:
  Frontend:
    example: http://127.0.0.1:8000/?canisterId=aaaaa-aaaaa-aaaaa-aaaaa-aaa
```

- Status of `project-one`
```bash
docker exec -it my_dfx dfxctl status project-one
 2022-05-11 19:09:42 [INFO ] Status of project: project-one

Canister status call result for example.
Status: Running
Controllers: aaaaa-aaaaa-aaaaa-aaaaa-aaa aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-aaaaa-aaa
Memory allocation: 0
Compute allocation: 0
Freezing threshold: 2_592_000
Memory Size: Nat(4389588)
Balance: 4_000_000_000_000 Cycles
Module hash: 0xe000000000000000000000000000000000000000000000000000000000000000

```

- Stop `project-one`
```bash
docker exec -it my_dfx dfxctl stop project-one
 2022-05-11 19:12:25 [INFO ] Stopping Project: project-one

Stopping code for canister example, with canister_id aaaaa-aaaaa-aaaaa-aaaaa-aaa
```

- Delete `project-one`
```bash
docker exec -it my_dfx dfxctl delete project-one
 2022-05-11 18:57:41 [WARN ] Deleting Project: project-one

Beginning withdrawal of cycles to canister aaaaa-aaaaa-aaaaa-aaaaa-aaa; on failure try --no-wallet --no-withdrawal.
Setting the controller to identity princpal.
Installing temporary wallet in canister example to enable transfer of cycles.
Transfering 3990000000000 cycles to canister aaaaa-aaaaa-aaaaa-aaaaa-aaa.
Deleting code for canister example, with canister_id aaaaa-aaaaa-aaaaa-aaaaa-aaa
```
- Clean `.dfx` folder for `project-one`
```bash
docker exec -it my_dfx dfxctl clean project-one
 2022-05-11 19:01:52 [INFO ] Cleaning Project: project-one
```
