#!/bin/bash

###################################################################
#Script Name    : tool_builder.sh
#Description    : pentesting tool management for ubuntu boxes
#Version        : .01
#Author         : Scott
#Twitter        : @hellor00t
#Notes          : Binaries installed to /usr/bin or linked, wordlists or other tools in ~/tools
###################################################################

#### Functions

installBasic() {
        sudo apt install -y jq fzf bat python3-pip
        sudo rm -rf /usr/local/go
        sudo rm -rf /usr/bin/go
        curl -OL https://go.dev/dl/go1.18.1.linux-amd64.tar.gz
        sudo tar -C /usr/local -xvf go1.18.1.linux-amd64.tar.gz
        echo "export PATH=$PATH:/usr/local/go/bin:/$HOME/go/bin" >> ~/.bashrc
        source ~/.bashrc
        # Install tomnomnom glory
        go get github.com/tomnomnom/waybackurls
        go get -u github.com/ffuf/ffuf
        go get -u github.com/tomnomnom/assetfinder
        go install -v github.com/tomnomnom/anew@latest
        go get -u github.com/tomnomnom/qsreplace
        go get -u github.com/tomnomnom/gf
        go get -u github.com/tomnomnom/meg
        go install github.com/tomnomnom/unfurl@latest
        # Install Ferroxbuster
        wget -q `curl -sL https://api.github.com/repos/epi052/feroxbuster/releases/latest | jq -r ".assets[].browser_download_url" | grep x86_64-linux-feroxbuster.tar.gz`
        tar -xvf x86_64-linux-feroxbuster.tar.gz
        rm x86_64-linux-feroxbuster.tar.gz
        mv feroxbuster /usr/bin/
        chmod 755 /usr/bin/feroxbuster
        # Clone SecLists
        git clone https://github.com/danielmiessler/SecLists ~/tools/SecLists
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
        curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
        sudo apt-get install -y nodejs
        pip3 install updog
}

installFull() {
        installBasic
        git clone https://github.com/wallarm/jwt-secrets ~/tools/jwt-secrets
        git clone https://github.com/BBhacKing/jwt_secrets.git ~/tools/jwt_secrets
        # Install Nucleai
        go install -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei@latest
        mkdir ~/nuclei-templates
        nuclei -ut
        git clone https://github.com/geeknik/the-nuclei-templates ~/nuclei-templates/the-nuclei-templates
        wget -q `curl -sL https://api.github.com/repos/assetnote/kiterunner/releases | jq -r .[0].assets[].browser_download_url | grep linux_amd64`
        export kitepath=`curl -sL https://api.github.com/repos/assetnote/kiterunner/releases | jq -r .[0].assets[].browser_download_url | grep linux_amd64 | awk -F'/' '{print $9}'`
        tar -xvf ${kitepath}
        chmod 755 kr
        sudo mv kr /usr/bin/
}

updateTools() {
        # Update Ferroxbuster
        FERROXBUSTER=$(curl -sL https://api.github.com/repos/epi052/feroxbuster/releases/latest | jq -r ".assets[].browser_download_url" | grep x86_64-linux-feroxbuster.tar.gz)
        wget $FERROXBUSTER
        tar -xvf x86_64-linux-feroxbuster.tar.gz
        rm x86_64-linux-feroxbuster.tar.gz
        mv feroxbuster /usr/bin/
        chmod 755 /usr/bin/feroxbuster
        # Update Git Repos
        # store the current dir
        CUR_DIR=$(pwd)
        echo "[+] Pulling in latest changes for all repositories"
        # Find all git repositories and update it to the master latest revision
        for i in $(find . -name ".git" | cut -c 3-); do
                if [ $i == ".git" ]; then
                        echo ""
                else
                        echo ""
                        echo "[>] $i"
                        # We have to go to the .git parent directory to call the pull command
                        cd "$i"
                        cd ..
                        # finally pull
                        git pull origin master
                        # lets get back to the CUR_DIR
                        cd $CUR_DIR
                fi
        done
        nuclei -update
        nuclei -ut
        echo "[+] Complete!"
}

mkdir /home/$(logname)/tools
cd /home/$(logname)/tools
while getopts iu name; do
        case $name in
        i) full=1 ;;
        u) update=1 ;;
        b) basic=1 ;;
        ?)
                printf "Usage: %s: [-i] Install [-u] Update\n" $0
                exit 2
                ;;
        esac
done
if [ ! -z "$full" ]; then
        printf "[+] Installing tools\n"
        installFull
fi
if [ ! -z "$update" ]; then
        printf "[+] Updating Tools\n"
        updateTools
fi
if [ ! -b "$basic" ]; then
        printf "[+] Install Basic Tools\n"
        installBasic
fi
shift $(($OPTIND - 1))