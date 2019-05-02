# OTL Container Stack environment

The Container Stack installs the following components:

**Server components**: 
verifies Docker

Optionally, provides commands for installing Go language, NodeJS 10, npm and yarn (check install-container-stack.sh for available commands)


### Requirements ##
a) Install Docker

-[Install Docker CE](https://docs.docker.com/install/)  
Follow instructions for your OS. Runs on Linux, Mac and windows. The new version of docker (Native windows virtualization for Hyper-V) works on windows 10 Professional. 
* docker and docker-compose 
* Access to a console with sudo permissions (SSH will do)

## Install
Run the following command in a terminal (ssh or bash):

    curl https://raw.githubusercontent.com/one-tec-lab/container-stack/master/install-container-stack.sh > $HOME/install-container-stack.sh;source install-container-stack.sh; install-stack 2>&1 | tee install-container-stack.log

Logs will be available at the file install-container-stack.log of your user home.
