#!/bin/bash

###################################################################
#Script Name    : tool_builder.sh
#Description    : pentesting tool management for kali/deb boxes
#Version        : .01
#Author         : Scott
#Twitter        : @hellor00t
#Notes          : Binaries installed to /usr/bin or linked, wordlists or other tools in ~/tools
###################################################################

#### Functions

installBasic() {
        sudo apt install -y golang jq fzf bat
        echo "export GOROOT=/usr/lib/go" >> ~/.zshrc
        echo "export GOPATH=$HOME/go" >> ~/.zshrc
        echo "export PATH=$GOPATH/bin:$GOROOT/bin:$PATH" >> ~/.zshrc
        source ~/.bashrc
        # Install tomnomnom glory
        go get github.com/tomnomnom/waybackurls
        go get go get -u github.com/ffuf/ffuf
        go get -u github.com/tomnomnom/assetfinder
        go get https://github.com/tomnomnom/anew
        go get -u github.com/tomnomnom/qsreplace
        go get -u github.com/tomnomnom/gf
        go get -u github.com/tomnomnom/meg
        # Install Ferroxbuster
        # FERROXBUSTER=$(curl -sL https://api.github.com/repos/epi052/feroxbuster/releases/latest | jq -r ".assets[].browser_download_url" | grep x86_64-linux-feroxbuster.tar.gz)
        wget -q `curl -sL https://api.github.com/repos/epi052/feroxbuster/releases/latest | jq -r ".assets[].browser_download_url" | grep x86_64-linux-feroxbuster.tar.gz`
        tar -xvf x86_64-linux-feroxbuster.tar.gz
        rm x86_64-linux-feroxbuster.tar.gz
        mv feroxbuster /usr/bin/
        chmod 755 /usr/bin/feroxbuster
        # Clone SecLists
        git clone https://github.com/danielmiessler/SecLists ~/tools/SecLists
        go install -v github.com/projectdiscovery/httpx/cmd/httpx@latest
        npm install -g fx
}

installFull() {
        installBasic
        git clone https://github.com/wallarm/jwt-secrets ~/tools/jwt-secrets
        git clone https://github.com/BBhacKing/jwt_secrets.git ~/tools/jwt_secrets
        # Install Nucleai
        GO111MODULE=on go get -v github.com/projectdiscovery/nuclei/v2/cmd/nuclei
        nuclei -ut
        https://github.com/geeknik/the-nuclei-templates ~/nuclei-templates/the-nuclei-templates
        
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