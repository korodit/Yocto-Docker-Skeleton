# Yocto Docker environment skeleton

A skeleton of a docker and docker-compose based project to run yocto inside a container. Based on Ubuntu 18.04 LTS. WSL friendly.
Will need heavy customization for your specific usecase. Setup downloads some layers I use.

IMPORTANT: The version you use here sets up a Yocto Sumo (2.5) environment.
When a new version is added, a new suitable branch will be created.

## Current use:  
  * You need to have docker and docker-compose V2 installed.
  * Start a build environment with "./run.sh". Change any variables before starting. Supplied values will be
    saved in the ".env" file and reused in the next run. First time running the script will allow you to run
    other first time setup scripts to prepare the project folder correctly.
  * You are in a yocto environment now!
  * sudo password for the default user "yoctouser" is "yoctouser". You can use tmux too if you are familiar with
    it. Build projects code is inside "./build-files/poky" on host, "/home/yoctouser/poky" inside the container.
    Edit on either of the two.
  * To update the tool, simply pull the latest git revision. After updating, run the "create-yocto-mini.sh" script
    so that the docker images gets the latest changes.
  * You can edit the layer files directly on host. When container is spin-up, its 'yoctouser' is set to have the same
    uid and gid as the user 'build-files' folder belongs to.
  * If needed, change placeholder values accordingly for proxy files to work.

## TODO
  * Un-isolate docker compose network  - use host network
  * Git - allow use of ssh
  * Improve conf reset process
  * Improve proxy script input
