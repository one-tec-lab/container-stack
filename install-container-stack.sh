#!/bin/bash

################################################################
# Script_Name : install-dev.sh
# Description : Perform an automated standard installation
# of an ubuntu dev environment 
# on ubuntu 18.04.1 and later
# Date : Nov 2018
# written by : tadeo
# 
# Version : 0.2
# History : 0.2 - sourced by .bashrc
# - Updated the polkit section
# - New formatting and structure
# 0.1 - Initial Script
# Disclaimer : Script provided AS IS. Use it at your own risk....
##################################################################

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
   /bin/echo -e "\e[1;36m# Standard OTl SERVER Installation Script - Ver 0.2 #\e[0m"
   /bin/echo -e "\e[1;36m# Written by Tadeo - Nov 2018-  #\e[0m"
   /bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
   echo
   version=$(lsb_release -d | awk -F":" '/Description/ {print $2}')
   echo $version   
   sudo echo

   if [ -f /root/.cloud-locale-test.skip ];then
      echo "Running in Digital-Ocean. Using original repositories"
      if [ "$USER" == "root" ];then
         echo
         sudo adduser devuser
         echo
         sudo usermod -aG sudo devuser 
         echo "User 'devuser' Created. Logout from root and run the install command again under user 'devuser'"
         echo
         exit
      fi
   else
      cd $HOME/
      if grep -q 'APT::Periodic::Update-Package-Lists "1";' /etc/apt/apt.conf.d/20auto-upgrades; then
        echo "Auto-updates required to be disabled (done). "
        sudo cp /etc/apt/apt.conf.d/20auto-upgrades /etc/backup_apt_apt.conf.d_20auto-upgrades
        sudo echo 'APT::Periodic::Update-Package-Lists "0";' | sudo tee /etc/apt/apt.conf.d/20auto-upgrades
        sudo echo 'APT::Periodic::Unattended-Upgrade "1";' | sudo tee -a /etc/apt/apt.conf.d/20auto-upgrades
        echo "A backup of /etc/apt/apt.conf.d/20auto-upgrades was created at /etc/backup_20auto-upgrades"
        echo "Restart the system and run the installation command again "
        #sudo addreplacevalue 'APT::Periodic::Update-Package-Lists "1";' 'APT::Periodic::Update-Package-Lists "0";' /etc/apt/apt.conf.d/20auto-upgrades
        exit
      fi

      sudo cp /etc/apt/sources.list /etc/apt/sources.list.backup 

      sudo echo "deb http://archive.ubuntu.com/ubuntu bionic main universe" | sudo tee /etc/apt/sources.list
      sudo echo "deb-src http://archive.ubuntu.com/ubuntu bionic main universe #Added by software-properties" | sudo tee -a /etc/apt/sources.list
      sudo echo "deb http://archive.ubuntu.com/ubuntu bionic-security main universe" | sudo tee -a /etc/apt/sources.list
      sudo echo "deb-src http://archive.ubuntu.com/ubuntu bionic-security main universe #Added by software-properties" | sudo tee -a /etc/apt/sources.list
      sudo echo "deb http://archive.ubuntu.com/ubuntu bionic-updates main universe" | sudo tee -a /etc/apt/sources.list
      sudo echo "deb-src http://archive.ubuntu.com/ubuntu bionic-updates main universe #Added by software-properties" | sudo tee -a /etc/apt/sources.list
   fi
   ########### git
   sudo add-apt-repository ppa:git-core/ppa -y

   sudo apt-get update
   #sudo apt-get upgrade -y
   sudo apt-get install gcc g++ make apt-transport-https ca-certificates curl software-properties-common wget ufw openconnect git -y


   ######## docker
   curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -

   sudo apt-key fingerprint 0EBFCD88
   sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

   sudo apt-get update
   sudo apt-get install docker-ce -y

   sudo curl -L "https://github.com/docker/compose/releases/download/1.23.2/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
   sudo chmod +x /usr/local/bin/docker-compose

   sudo groupadd docker
   sudo usermod -aG docker devuser
   sudo echo "127.0.0.1     dockerhost" | sudo tee -a  /etc/hosts


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
   echo
   
   
   mkdir -p $HOME/otl
   /bin/echo -e "\e[1;36m#-----------------------------------------------------------------------#\e[0m"
   /bin/echo -e "\e[1;36m# Installation Completed\e[0m"
   /bin/echo -e "\e[1;36m# Please test your Server configuration....\e[0m"
   /bin/echo -e "\e[1;36m# Written by Tadeo - Nov 2018 - Ver 0.2 - install-dev.sh\e[0m"
   /bin/echo -e "\e[1;36m#-----------------------------------------------------------------------#\e[0m"
   echo
}


function install-desktop {

   /bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
   /bin/echo -e "\e[1;36m# Standard development DESKTOP Installation Script - Ver 0.2 #\e[0m"
   /bin/echo -e "\e[1;36m# Written by Tadeo - Nov 2018-  #\e[0m"
   /bin/echo -e "\e[1;36m#-------------------------------------------------------------#\e[0m"
   echo
 
   version=$(lsb_release -d | awk -F":" '/Description/ {print $2}')

   echo $version

   #---------------------------------------------------#
   # Step 1 - Install Desktop Software....
   #---------------------------------------------------#
   echo
   /bin/echo -e "---------------------------------------------"
   /bin/echo -e " Installing DESKTOP Packages...Proceeding..."
   /bin/echo -e "---------------------------------------------"
   echo
   sudo echo
   sudo apt-get install ubuntu-desktop gufw mysql-workbench mysql-client gnome-system-monitor gnome-tweak-tool xrdp xrdp-pulseaudio-installer -y
   echo
   /bin/echo -e "---------------------------------------------"
   /bin/echo -e " Granting Console Access...Proceeding... "
   /bin/echo -e "---------------------------------------------"
   echo

   sudo sed -i 's/allowed_users=console/allowed_users=anybody/' /etc/X11/Xwrapper.config
   echo
   /bin/echo -e "---------------------------------------------"
   /bin/echo -e " Creating Polkit File...Proceeding... "
   /bin/echo -e "---------------------------------------------"
   echo

   sudo bash -c "cat >/etc/polkit-1/localauthority/50-local.d/45-allow.colord.pkla" <<-EOF
[Allow Colord all Users]
Identity=unix-user:*
Action=org.freedesktop.color-manager.create-device;org.freedesktop.color-manager.create-profile;org.freedesktop.color-manager.delete-device;org.freedesktop.color-manager.delete-profile;org.freedesktop.color-manager.modify-device;org.freedesktop.color-manager.modify-profile
ResultAny=no
ResultInactive=no
ResultActive=yes
EOF

   echo
   /bin/echo -e "---------------------------------------------"
   /bin/echo -e " Install Extensions Dock...Proceeding... "
   /bin/echo -e "---------------------------------------------"
   echo
   gnome-shell-extension-tool -e ubuntu-dock@ubuntu.com
   gnome-shell-extension-tool -e ubuntu-appindicators@ubuntu.com
   echo

 
   sudo ufw allow 3389/tcp
   sudo ufw allow 22/tcp
   sudo ufw allow 80/tcp
   sudo ufw allow 443/tcp
   
   #sudo xrdp-build-pulse-modules
   cd /tmp
   sudo apt source pulseaudio

   cd /tmp/pulseaudio-11.1
   sudo ./configure


   cd /usr/src/xrdp-pulseaudio-installer
   sudo make PULSE_DIR="/tmp/pulseaudio-11.1"

   sudo install -t "/var/lib/xrdp-pulseaudio-installer" -D -m 644 *.so



   ####chrome
   cd $HOME
   wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
   sudo dpkg -i google-chrome-stable_current_amd64.deb

   ###### vs code
   curl https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
   sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/trusted.gpg.d/
   sudo sh -c 'echo "deb [arch=amd64] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
   sudo apt-get install apt-transport-https -y
   sudo apt-get update
   sudo apt-get install code -y # or code-insiders

   ####### dash to panel

   cd $HOME/otl
   git clone https://github.com/home-sweet-gnome/dash-to-panel.git
   cd $HOME/otl/dash-to-panel
   make install
   cd $HOME/


   ######## pop icons
   sudo add-apt-repository ppa:system76/pop -y
   sudo apt-get update
   sudo apt-get install pop-icon-theme -y


   #####community team
   sudo add-apt-repository ppa:communitheme/ppa -y
   sudo apt-get update
   sudo apt-get install ubuntu-communitheme-session -y

   #sudo apt-get -y upgrade
   
   sudo systemctl start graphical.target

   wget https://raw.githubusercontent.com/one-tec-lab/ubuntu-dev/master/saved_settings.dconf

   mkdir -p ~/.config/autostart
   
bash -c "cat >~/.config/autostart/gnome-terminal.desktop" <<-EOF
[Desktop Entry]
Type=Application
Exec=gnome-terminal
Hidden=false
NoDisplay=false
X-GNOME-Autostart-enabled=true
Name[en_NG]=Terminal
Name=Terminal
Comment[en_NG]=Start Terminal On Startup
Comment=Start Terminal On Startup
EOF

echo "source ~/install-dev.sh" >> ~/.bashrc

echo
/bin/echo -e "-----------------------------------------------------------------------"
/bin/echo -e " Installation Completed"
/bin/echo -e " Please test your Desktop configuration...."
/bin/echo -e " Written by Tadeo - Nov 2018 - Ver 0.2 - install-dev.sh"
/bin/echo -e "-----------------------------------------------------------------------"
echo

}

function install-graphic-editors {
   ##### graphic editors
   sudo add-apt-repository ppa:otto-kesselgulasch/gimp -y
   sudo add-apt-repository ppa:inkscape.dev/stable -y
   sudo add-apt-repository ppa:kritalime/ppa -y
   sudo apt-get update
   sudo apt-get install gimp inkscape krita vlc -y
}

function clean-otl {
   rm ~/nodesource_setup.sh
   rm ~/google-chrome-stable_current_amd64.deb 
   rm ~/go.tar.gz
}

function update-otl {
   
   mkdir -p ~/Pictures
   cd ~/otl
   if [ ! -d ~/otl/ubuntu-dev  ]; then
     git clone https://github.com/one-tec-lab/ubuntu-dev.git 
   fi
   cd ~/otl/ubuntu-dev
   git fetch --all
   git reset --hard origin/master
   git pull origin master
   
   cp -rf ~/otl/ubuntu-dev/install-dev.sh ~/install-dev.sh
   cp ~/otl/ubuntu-dev/img/* ~/Pictures
   if [ ! -f ~/.config/Code/User/settings.json  ]; then
      mkdir -p ~/.config/Code/User/
      cp ~/otl/ubuntu-dev/code/settings.json ~/.config/Code/User/settings.json
   fi
}

function install-otl {
 install-server
 install-desktop
 update-otl
 clean-otl
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
   curl https://raw.githubusercontent.com/cippaciong/buffalo_bash_completion/master/buffalo_completion.sh > ~/otl/buffalo_completion.sh
   addreplacevalue "source ~/otl/buffalo_completion.sh" "source ~/otl/buffalo_completion.sh" ~/.bashrc
   
}

function save-desktop-settings {
   #if [ ! -f ~/desktop_settings.dconf ]; then
      echo "saving desktop settings"
      dconf dump / > ~/otl/ubuntu-dev/saved_settings.dconf
   #fi
}
function default-desktop-settings {
   curl https://raw.githubusercontent.com/one-tec-lab/ubuntu-dev/master/saved_settings.dconf > ~/saved_settings.dconf
}

function configure-stack {
   
   GUACVERSION="0.9.14"

   # Get script arguments for non-interactive mode
   while [ "$1" != "" ]; do
       case $1 in
           -m | --mysqlpwd )
               shift
               mysqlpwd="$1"
               ;;
           -g | --guacpwd )
               shift
               guacpwd="$1"
               ;;
       esac
       shift
   done

   # Get MySQL root password and Guacamole User password
   if [ -n "$mysqlpwd" ] && [ -n "$guacpwd" ]; then
           mysqlrootpassword=$mysqlpwd
           dbuserpassword=$guacpwd
   else
       echo 
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

   #Install Stuff
   #sudo apt-get update
   #sudo apt-get -y install mysql-client wget

   # Set SERVER to be the preferred download server from the Apache CDN
   SERVER="http://apache.org/dyn/closer.cgi?action=download&filename=guacamole/${GUACVERSION}"

   ## Download Guacamole authentication extensions
   #wget -O guacamole-auth-jdbc-${GUACVERSION}.tar.gz ${SERVER}/binary/guacamole-auth-jdbc-${GUACVERSION}.tar.gz
   #if [ $? -ne 0 ]; then
   #    echo "Failed to download guacamole-auth-jdbc-${GUACVERSION}.tar.gz"
   #    echo "${SERVER}/binary/guacamole-auth-jdbc-${GUACVERSION}.tar.gz"
   #    exit
   #fi

   #tar -xzf guacamole-auth-jdbc-${GUACVERSION}.tar.gz

   # Start MySQL
    
    
    cd ~/otl/ubuntu-dev
    docker network create web
    MYSQL_ROOT_PASSWORD=$mysqlrootpassword docker-compose up -d mysql

   # Sleep to let MySQL load (there's probably a better way to do this)
   echo "Waiting 20 seconds for MySQL to load"
   sleep 20
    
   docker run --rm guacamole/guacamole /opt/guacamole/bin/initdb.sh --mysql > initdb.sql
   
   # Create the databases and the user account
   # SQL Code
   SQLCODE="
   create database guacamole_db; 
   create user 'guacamole_user'@'%' identified by '$dbuserpassword'; 
   GRANT SELECT,INSERT,UPDATE,DELETE ON guacamole_db.* TO 'guacamole_user'@'%'; 
   create database api_db CHARACTER SET utf8 COLLATE utf8_general_ci; 
   create user 'api_user'@'%' identified by '$dbuserpassword'; 
   GRANT ALL PRIVILEGES ON api_db.* TO 'api_user'@'%'; 
   flush privileges;"

   # Execute SQL Code
   
   mysql_ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' mysql )

   
   echo $SQLCODE | mysql -h $mysql_ip -P 3306 -u root -p$mysqlrootpassword
   
   cat initdb.sql | mysql -u root -p$mysqlrootpassword -h $mysql_ip -P 3306 guacamole_db
   
   #cat guacamole-auth-jdbc-${GUACVERSION}/mysql/schema/*.sql | mysql -u root -p$mysqlrootpassword -h 127.0.0.1 -P 3306 guacamole_db
   
   MYSQL_PASSWORD=$dbuserpassword DATABASE_PASSWORD=$dbuserpassword docker-compose up -d
   
   #docker run --restart=always --name guacd -d guacamole/guacd
   #docker run --restart=always --name guacamole  --link mysql:mysql --link guacd:guacd -e MYSQL_HOSTNAME=127.0.0.1 -e MYSQL_DATABASE=guacamole_db -e MYSQL_USER=guacamole_user -e MYSQL_PASSWORD=$guacdbuserpassword --detach -p 8090:8080 guacamole/guacamole

   #rm -rf guacamole-auth-jdbc-${GUACVERSION}*

}

function clean-docker {
   cd ~/otl/ubuntu-dev
   docker-compose down
   #docker stop guacd
   #docker rm guacd
   docker system prune -a
   docker volume prune
 
}



if [ -f ~/saved_settings.dconf ]; then
   gnome-shell-extension-tool -e dash-to-panel@jderose9.github.com 2>/dev/null
   gsettings set org.gnome.desktop.interface icon-theme 'Pop'
   gsettings set org.gnome.desktop.interface gtk-theme 'Adwaita-dark'
   dconf load / < ~/saved_settings.dconf
   rm -rf ~/saved_settings.dconf
   gsettings set org.gnome.desktop.background picture-uri ~/Pictures/wallpaper.jpg
fi

 export PROXY_DOMAIN=localhost
