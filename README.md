# OTL Container Stack environment

The Container Stack installs the following components:

**Server components**: verifies Docker, Go language, NodeJS 10, npm and yarn


### Requirements ##
* UBUNTU 18.04 LTS
* docker and docker-compose (if not installed)
* Access to a console with sudo permissions (SSH will do)

## Install
Run the following command in a terminal (ssh or bash):

    curl https://raw.githubusercontent.com/one-tec-lab/container-stack/master/install-container-stack.sh > $HOME/install-container-stack.sh;source install-container-stack.sh; install-stack 2>&1 | tee install-container-stack.log

Logs will be available at the file install-container-stack.log of your user home.
