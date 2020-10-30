#!/bin/bash

set -e
#############################################################################
#                                                                           #
# Github Project 'dashactyl-installer'                                    #
# By _Josh_#0086                                                            #
#                                                                           #
# Copyright (C) 2018 - 2020, _Josh_#0086.                                   #
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
    echo "-------------------------------------------------------"
    read choice
    case $choice in
        1 ) installoption=1
            dependercy_install
            file_install
            settings_configuration
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
        * ) output "You did not enter a valid selection."
            install_options
    esac
}

dependercy_install() {
    echo "------------------------------------------------------"
    echo "Starting Dependercy install."
    echo "------------------------------------------------------"
    sudo apt-get install nodejs
    sudo apt install npm
    sudo apt-get install git
    sudo apt update
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
install_options
