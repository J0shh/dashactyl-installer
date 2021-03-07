#!/bin/bash

set -e
#############################################################################
#                                                                           #
# Github Project 'dashactyl-installer'                                      #
# By _Josh_#0086                                                            #
#                                                                           #
#   This program is free software: you can redistribute it and/or modify    #
#   it under the terms of the GNU General Public License as published by    #
#   the Free Software Foundation, either version 3 of the License, or       #
#   (at your option) any later version.                                     #
#                                                                           #
#   This program is distributed in the hope that it will be useful,         #
#   but WITHOUT ANY WARRANTY; without even the implied warranty of          #
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the           #
#   GNU General Public License for more details.                            #
#                                                                           #
#   You should have received a copy of the GNU General Public License       #
#   along with this program.  If not, see <https://www.gnu.org/licenses/>.  #
#                                                                           #
#############################################################################
   clear

    echo "Dashactyl Install Script"
    echo "-------------------------------------------------------"
    echo "Made by _Josh_#0086"
    echo "-------------------------------------------------------"

    echo "Please note that this script is meant to be installed on a fresh OS. Installing it on a non-fresh OS may cause problems."
    echo "-------------------------------------------------------"

    if [ "$lsb_dist" =  "ubuntu" ]; then
    echo "This script currently is only available for Ubuntu operating systems."
    echo "-------------------------------------------------------"
    fi

install_options(){
    echo "Please select your installation option:"
    echo "[1] Full Fresh Dashactyl Install (Dependercies, Files, Configuration)"
    echo "[2] Install the Dependercies."
    echo "[3] Install the Files."
    echo "[4] Configure Settings."
    echo "[5] Create and configure a reverse proxy."
    echo "[6] Check for Updates"
    echo "-------------------------------------------------------"
    read choice
    case $choice in
        1 ) installoption=1
            dependercy_install
            file_install
            settings_configuration
            reverseproxy_configuration
            ;;
        2 ) installoption=2
            dependercy_install
            ;;
        3 ) installoption=3
            file_install
            ;;
        4 ) installoption=4
            settings_configuration
            ;;
        5 ) installoption=5
            reverseproxy_configuration
            ;;
        6 ) installoption=6
            update_check
            ;;
        * ) output "You did not enter a valid selection."
            install_options
    esac
}

dependercy_install() {
    echo "------------------------------------------------------"
    echo "Starting Dependercy install."
    echo "------------------------------------------------------"
    sudo apt-get install nodejs -y
    sudo apt install npm -y
    sudo apt-get install git -y
    sudo apt update -y
    echo "-------------------------------------------------------"
    echo "Dependercy Install Completed!"
    echo "-------------------------------------------------------"
}
file_install() {
    echo "-------------------------------------------------------"
    echo "Starting File install."
    echo "-------------------------------------------------------"
    cd /var/www/
    sudo git clone https://github.com/real2two/dashactyl.git
    cd dashactyl
    sudo npm install
    sudo npm install forever -g
    echo "-------------------------------------------------------"
    echo "Dashactyl File Install Completed!"
    echo "-------------------------------------------------------"
}
settings_configuration() {
    echo "-------------------------------------------------------"
    echo "Starting Settings Configuration."
    echo "Read the Docs for more infomration about the settings."
    echo "https://josh0086.gitbook.io/dashactyl/"
    echo "-------------------------------------------------------"
    cd /var/www/dashactyl/
    file=settings.json

    echo "What is the web port? [80] (This is the port Dashactyl will run on)"
    read WEBPORT
    echo "What is the web secret? (This will be used for logins)"
    read WEB_SECRET
    echo "What is the pterodactyl domain? [panel.yourdomain.com]"
    read PTERODACTYL_DOMAIN
    echo "What is the pterodactyl key?"
    read PTERODACTYL_KEY
    echo "What is the Discord Oauth2 ID?"
    read DOAUTH_ID
    echo "What is the Discord Oauth2 Secret?"
    read DOAUTH_SECRET
    echo "What is the Discord Oauth2 Link?"
    read DOAUTH_LINK
    echo "What is the Callback path? [callback]" 
    read DOAUTH_CALLBACKPATH
    echo "Prompt [TRUE/FALSE] (When set to true users wont have to relogin after a session)"
    read DOAUTH_PROMPT
    sed -i -e 's/"port":.*/"port": '$WEBPORT',/' -e 's/"secret":.*/"secret": "'$WEB_SECRET'"/' -e 's/"domain":.*/"domain": "'$PTERODACTYL_DOMAIN'",/' -e 's/"key":.*/"key": "'$PTERODACTYL_KEY'"/' -e 's/"id":.*/"id": "'$DOAUTH_ID'",/' -e 's/"link":.*/"link": "'$DOAUTH_LINK'",/' -e 's/"path":.*/"path": "'$DOAUTH_CALLBACKPATH'",/' -e 's/"prompt":.*/"prompt": '$DOAUTH_PROMPT'/' -e '0,/"secret":.*/! {0,/"secret":.*/ s/"secret":.*/"secret": "'$DOAUTH_SECRET'",/}' $file
    echo "-------------------------------------------------------"
    echo "Configuration Settings Completed!"
}
reverseproxy_configuration() {
    echo "-------------------------------------------------------"
    echo "Starting Reverse Proxy Configuration."
    echo "Read the Docs for more infomration about the Configuration."
    echo "https://josh0086.gitbook.io/dashactyl/"
    echo "-------------------------------------------------------"

   echo "Select your webserver [NGINX]"
   read WEBSERVER
   echo "Protocol Type [HTTP]"
   read PROTOCOL
   if [ $PROTOCOL != "HTTP" ]; then
   echo "------------------------------------------------------"
   echo "HTTP is currently only supported on the install script."
   echo "------------------------------------------------------"
   return
   fi
   if [ $WEBSERVER != "NGINX" ]; then
   echo "------------------------------------------------------"
   echo "Aborted, only Nginx is currently supported for the reverse proxy."
   echo "------------------------------------------------------"
   return
   fi
   echo "What is your domain? [example.com]"
   read DOMAIN
   apt install nginx -y
   sudo wget -O /etc/nginx/conf.d/dashactyl.conf https://raw.githubusercontent.com/J0shh/dashactyl-installer/main/assets/NginxHTTPReverseProxy.conf
   sudo apt-get install jq -y
   port=$(jq -r '.["website"]["port"]' /var/www/dashactyl/settings.json)
   sed -i 's/PORT/'$port'/g' /etc/nginx/conf.d/dashactyl.conf
   sed -i 's/DOMAIN/'$DOMAIN'/g' /etc/nginx/conf.d/dashactyl.conf
   sudo nginx -t
   sudo nginx -s reload
   systemctl restart nginx
   echo "-------------------------------------------------------"
   echo "Reverse Proxy Install and configuration completed."
   echo "-------------------------------------------------------"
   echo "Here is the config status:"
   sudo nginx -t
   echo "-------------------------------------------------------"
   echo "Note: if it does not say OK in the line, an error has occurred and you should try again or get help in the Dashactyl Discord Server."
   echo "-------------------------------------------------------"
   if [ $WEBSERVER = "APACHE" ]; then
   echo "Apache isn't currently supported with the install script."
   echo "------------------------------------------------------"
   return
   fi
}
update_check() {
    latest=$(wget https://raw.githubusercontent.com/J0shh/dashactyl-installer/main/assets/LATEST.json -q -O -)
    #latest='"version": "0.1.2-themes6",'
    version=$(grep -Po '"version":.*?[^\\]",' /var/www/dashactyl/settings.json) 

    if [ "$latest" =  "$version" ]; then
    echo "-------------------------------------------------------"
    echo "You're running the latest version of Dashactyl."
    echo "-------------------------------------------------------"
    else 
    echo "You're running an outdated version of Dashactyl."
    echo "-------------------------------------------------------"
    echo "Would you like to update to the latest version? [Y/N]"
    echo "Bu updating your files will be backed up in /var/www/dashactyl-backup/"
    read UPDATE_OPTION
    echo "-------------------------------------------------------"
    if [ "$UPDATE_OPTION" = "Y" ]; then
    var=`date +"%FORMAT_STRING"`
    now=`date +"%m_%d_%Y"`
    now=`date +"%Y-%m-%d"`
    if [[ ! -e /var/www/dashactyl-backup/ ]]; then
    mkdir /var/www/dashactyl-backup/
    finish_update
    elif [[ ! -d $dir ]]; then
    finish_update
    fi
    else
    echo "Update Aborted"
    echo "Restart the script if this was a misstake."
    echo "-------------------------------------------------------"
    fi
    fi
}
finish_update() {
   tar -czvf "${now}.tar.gz" /var/www/dashactyl/
   mv "${now}.tar.gz" /var/www/dashactyl-backup
   rm -R /var/www/dashactyl/
   file_install
}
install_options
