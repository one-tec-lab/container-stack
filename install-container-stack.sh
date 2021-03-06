#!/bin/bash

################################################################
# Script_Name : install-container-stack..sh
# Description : Perform an automated standard installation
# of a container stack environment 
# on ubuntu 18.04.1 and later
# Date : march 2019
# written by : tadeo
# 
# Version : 0.3
# History : 0.3 - sourced by .bashrc

# 0.1 - Initial Script
# Disclaimer : Script provided AS IS. Use it at your own risk....
##################################################################
export CONTAINER_STACK_VER="3.0"
function addreplacevalue {

   usesudo="$4"
   archivo="$3"
   nuevacad="$2"
   buscar="$1"
   temporal="$archivo.tmp.kalan"
   listalineas=""
   linefound=0       
   listalineas=$(cat $archivo)
   if [[ !  -z  $listalineas  ]];then
     #echo "buscando lineas existentes con:"
     #echo "$nuevacad"
     #$usesudo >$temporal
     while read -r linea; do
     if [[ $linea == *"$buscar"* ]];then
       #echo "... $linea ..."
       if [ ! "$nuevacad" == "_DELETE_" ];then
          ## just add new line if value is NOT _DELETE_
          echo $nuevacad >> $temporal
       fi
       linefound=1
     else
       echo $linea >> $temporal

     fi
     done <<< "$listalineas"

     cat $temporal > $archivo
     rm -rf $temporal
   fi
   if [ $linefound == 0 ];then
     echo "Adding new value to file: $nuevacad"
     echo $nuevacad>>$archivo
   fi
}

function install-server {

   /bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
   /bin/echo -e "\e[1;36m# Standard stack SERVER Installation Script #\e[0m"
   /bin/echo -e "\e[1;36m# Written by Tadeo - Nov 2018-  #\e[0m"
   /bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
   echo
   version=$(lsb_release -d | awk -F":" '/Description/ {print $2}')
   echo $version   
   sudo echo
   
   if [ "$USER" == "root" ];then
      echo
      echo "To properly use the stack, you need a non-root user with sudo priviledges"
      #sudo adduser stackuser
      echo ' Example: Create a new user called "stackuser" (suggested) and add it to the sudo users:'
      echo " sudo adduser stackuser" 
      echo " sudo usermod -aG sudo stackuser"
      #sudo usermod -aG sudo stackuser 
      echo "Logout from root and run this install-stack command again under the non-root user"
      echo
      exit
   fi

   ########### git
   #sudo add-apt-repository ppa:git-core/ppa -y

   sudo apt-get update
   #sudo apt-get upgrade -y
   #followinf line just for development
   ##sudo apt-get install gcc g++ make apt-transport-https ca-certificates curl software-properties-common wget ufw openconnect git -y
   sudo apt-get install git -y
  
   
   mkdir -p $HOME/stack
   /bin/echo -e "\e[1;36m#-----------------------------------------------------------------------#\e[0m"
   /bin/echo -e "\e[1;36m# Installation Completed\e[0m"
   /bin/echo -e "\e[1;36m# Please test your Server configuration....\e[0m"
   /bin/echo -e "\e[1;36m# Written by Tadeo - install-container-stack.sh\e[0m"
   /bin/echo -e "\e[1;36m#-----------------------------------------------------------------------#\e[0m"
   echo
}

function install-docker {
   ######## docker
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

   sudo apt-key fingerprint 0EBFCD88
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

   sudo apt-get update
   sudo apt-get install docker-ce -y

   sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose

   #sudo groupadd docker
   #sudo usermod -aG docker stackuser
   sudo echo "127.0.0.1     dockerhost" | sudo tee -a  /etc/hosts

}
function install-go {
   ####### go
   echo 'export GOPATH=$HOME/go' >> $HOME/.bashrc
   echo 'export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin' >> $HOME/.bashrc
   source $HOME/.bashrc
   sudo echo
   sudo rm -rf /usr/local/go
   cd $HOME/
   curl -sL https://dl.google.com/go/go1.12.3.linux-amd64.tar.gz -o $HOME/go.tar.gz
   sudo tar -C /usr/local -xzf go.tar.gz
   mkdir -p $HOME/go/bin
   rm ~/go.tar.gz
}

function install-node {
   ###### node 10
   cd $HOME/
   curl -sL https://deb.nodesource.com/setup_10.x -o $HOME/nodesource_setup.sh
   sudo bash $HOME/nodesource_setup.sh
   sudo apt-get install -y nodejs

   #YARN
   curl -sL https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
   echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
   sudo apt-get update && 
   sudo apt-get install yarn -y
   rm ~/nodesource_setup.sh
   echo
}


function clean-stack {


echo "Stack cleaned"
}

function update-stack {
   
   mkdir -p ~/Pictures
   cd ~/stack
   if [ ! -d ~/stack/container-stack  ]; then
     git clone https://github.com/one-tec-lab/container-stack.git 
   fi
   cd ~/stack/container-stack
   git fetch --all
   git reset --hard origin/master
   git pull origin master
   
   cp -rf ~/stack/container-stack/install-container-stack.sh ~/install-container-stack.sh
   addreplacevalue "source ~/install-container-stack.sh" "source ~/install-container-stack.sh" ~/.bashrc
   source ~/.bashrc
   echo "Stack utilities updated to $CONTAINER_STACK_VER"
}

function install-stack {
 install-server
 update-stack
 clean-stack
}

function setup-git {
   while [ "$1" != "" ]; do
       case $1 in
           -m | --gitmail )
               shift
               gitmail="$1"
               ;;
           -g | --gitname )
               shift
               gitname="$1"
               ;;
       esac
       shift
   done

   # Get git account data
   if [ -n "$gitmail" ] && [ -n "$gitname" ]; then
           use_gitmail=$gitmail
           use_gitname=$gitname
   else
       echo 
       while true
       do
           read -p "Enter GITHUB email: " use_gitmail
           echo
           [ -z "$use_gitmail" ] && echo "Please provide GITHUB mail" || break
           echo
       done
       echo
       while true
       do
           read  -p "Enter GITHUB user name: " use_gitname
           echo
           [ -z "$use_gitname" ] && echo "Please provide GITHUB user name" || break
           echo
       done
       echo
   fi
   git config --global user.email $use_gitmail
   git config --global user.name $use_gitname


}

function setup-buffalo {
   mkdir -p $GOPATH/src/github.com/one-tec-lab/
   cd  $GOPATH/src/github.com/one-tec-lab/
   setup-git
   #go get -u -v -tags sqlite github.com/gobuffalo/buffalo/buffalo
   go get -u -v github.com/gobuffalo/buffalo/buffalo
   curl https://raw.githubusercontent.com/cippaciong/buffalo_bash_completion/master/buffalo_completion.sh > ~/stack/buffalo_completion.sh
   addreplacevalue "source ~/stack/buffalo_completion.sh" "source ~/stack/buffalo_completion.sh" ~/.bashrc
   
}
function clean-traefik {
    sudo rm -rf ~/stack/container-stack/stackdata/traefik/traefik.toml
    rm -rf ~/stack/container-stack/.env
}

function stack-up {
   comment_acme_staging=" "
   comment_redirect="#"
   comment_acme="#"
   cd ~/stack/container-stack
   mkdir -p ~/stack/container-stack/stackdata/traefik/acme
   mkdir -p ~/stack/container-stack/stackdata/portainer
   mkdir -p ~/stack/container-stack/stackdata/wordpress
   mkdir -p ~/stack/container-stack/stackdata/mysql
   mkdir -p ~/stack/container-stack/stackdata/api
   sudo apt-get install -y mysql-client
      
   searchString="127.0.0.1     dockerhost"
   file="/etc/hosts"
   if grep -Fxq "$searchString" $file
   then
         echo "String found in $fi  le"
   else
         echo "String not found in $file. Adding dockerhost"
         sudo echo "127.0.0.1     dockerhost" | sudo tee -a  /etc/hosts
   fi

   cat /etc/hosts
   # Get script arguments for non-interactive mode
   while [ "$1" != "" ]; do
       case $1 in
           -m | --mysqlrootpwd )
               shift
               mysqlrootpwd="$1"
               ;;
           -a | --apidbpwd )
               shift
               apidbpwd="$1"
               ;;
           -d | --domain )
               shift
               $domain_name="$1"
               ;;
               
       esac
       shift
   done

   # Get MySQL root password and Guacamole User password
   if [ -n "$mysqlrootpwd" ] && [ -n "$apidbpwd" ] && [ -n "$domain_name" ]; then
           mysqlrootpassword=$mysqlrootpwd
           dbuserpassword=$apidbpwd
           stackdomain=$domain_name
   else
       echo 

       if [ ! -f ~/stack/container-stack/stackdata/traefik/traefik.toml ]; then
          while true
          do
              read  -p "Enter DOMAIN: " stackdomain
              echo
              [ -z "$stackdomain" ] && echo "Please provide a DOMAIN" || break
              echo
          done

          echo "STACK_MAIN_DOMAIN=$stackdomain" > ~/stack/container-stack/.env

          while true
          do
              read  -p "Enter E-MAIL for certificates notifications: " certs_mail
              echo
              [ -z "$certs_mail" ] && echo "Please provide a valid mail for certs" || break
              echo
          done
          
          bash -c "cat > ~/stack/container-stack/stackdata/traefik/traefik.toml" <<-EOF
debug = false

logLevel = "ERROR"
defaultEntryPoints = ["https","http"]

[entryPoints]
  [entryPoints.http]
      address = ":80"
      $comment_redirect [entryPoints.http.redirect]
      $comment_redirect   entryPoint = "https"
  [entryPoints.https]
      address = ":443"
      [entryPoints.https.tls]

[retry]

[docker]
endpoint = "unix:///var/run/docker.sock"
domain = "$stackdomain"
watch = true
exposedByDefault = false

$comment_acme [acme]
$comment_acme  $comment_acme_staging caServer = "https://acme-staging-v02.api.letsencrypt.org/directory"
$comment_acme   email = "$certs_mail"
$comment_acme   storage = "acme/certs.json"
$comment_acme   entryPoint = "https"
$comment_acme   onHostRule = true
$comment_acme   [acme.httpChallenge]
$comment_acme      entryPoint = "http"
EOF
       fi
              
       while true
       do
           read -s -p "Enter a MySQL ROOT Password: " mysqlrootpassword
           echo
           read -s -p "Confirm MySQL ROOT Password: " password2
           echo
           [ "$mysqlrootpassword" = "$password2" ] && break
           echo "Passwords don't match. Please try again."
           echo
       done
       echo
       while true
       do
           read -s -p "Enter a database user Password: " dbuserpassword
           echo
           read -s -p "Confirm database user Password: " password2
           echo
           [ "$dbuserpassword" = "$password2" ] && break
           echo "Passwords don't match. Please try again."
           echo
       done
       echo
   fi

   sudo docker network create traefik-net
   sudo MYSQL_ROOT_PASSWORD=$mysqlrootpassword docker-compose up -d mysql

   # Sleep to let MySQL load (there's probably a better way to do this)
   echo "Waiting 20 seconds for MySQL to load"
   sleep 20
    
   # Create the databases and the user account
   # SQL Code
   SQLCODE="
   create database api_db CHARACTER SET utf8 COLLATE utf8_general_ci; 
   create user 'api_user'@'%' identified by '$dbuserpassword'; 
   GRANT ALL PRIVILEGES ON api_db.* TO 'api_user'@'%'; 
   create database wp_db CHARACTER SET utf8 COLLATE utf8_general_ci; 
   create user 'wp_user'@'%' identified by '$dbuserpassword'; 
   GRANT ALL PRIVILEGES ON wp_db.* TO 'wp_user'@'%'; 
   flush privileges;"

   # Execute SQL Code
   
   mysql_ip=$(sudo docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql )
 
   echo $SQLCODE | mysql -h $mysql_ip -P 3306 -u root -p$mysqlrootpassword

   sudo MYSQL_PASSWORD=$dbuserpassword \
   DATABASE_PASSWORD=$dbuserpassword \
   WORDPRESS_DB_PASSWORD=$dbuserpassword \
   CURRENT_UID=$(id -u):$(id -g) \
   docker-compose up -d
   
}


function stack-down {
   cd ~/stack/container-stack
   sudo docker-compose down
}
function clean-docker {
   stack-down
   sudo docker system prune -a
   sudo docker volume prune
 
}


 export PROXY_DOMAIN=localhost
