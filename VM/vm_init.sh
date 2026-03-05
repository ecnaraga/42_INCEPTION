#!/bin/sh

export DEBIAN_FRONTEND=noninteractive

sudo su
apt-get update

# --------------------------------------------------
# GRAPHIC INTALLATION
# --------------------------------------------------
# apt-get install task-gnome-desktop -y

if ! cat /etc/passwd | grep $1 > /dev/null ; then
    echo "Creating user $1..."
    # Crypte le password
    PASS=$(openssl passwd -6 $2)
    # Create a user + sudo rights
    useradd -m -p $PASS $1
    # To force user to change his passwd at first connexion
    passwd -e $1
    # To give sudo rigths
    usermod -aG sudo $1
fi

apt-get update && apt-get upgrade -y

# --------------------------------------------------
# SSH
# --------------------------------------------------
if [ ! -f /home/$1/.ssh/id_rsa.pub ]; then
    echo "Installing  SSH..."
    # Create and manage owner and rights on .ssh directory
    mkdir -p /home/$1/.ssh
    chown -R $1:$1 /home/$1/.ssh
    chmod 700 /home/$1/.ssh
    # Generate ssh key
    ssh-keygen -t rsa -b 4096 -C $4 -f /home/$1/.ssh/id_rsa -N ""
    # Manage owner and rights on id_rsa files
    chown -R $1:$1 /home/$1/.ssh/id_rsa
    chown -R $1:$1 /home/$1/.ssh/id_rsa.pub
    chmod 600 /home/$1/.ssh/id_rsa
    chmod 644 /home/$1/.ssh/id_rsa.pub
fi

# --------------------------------------------------
# INSTALL BASIC TOOLS
# --------------------------------------------------
install_if_missing () {
    if ! command -v "$1" > /dev/null 2>&1; then
        echo "Installing $1..."
        sudo apt-get install -y "$1"
    else
        echo "$1 already installed"
    fi
}

install_if_missing git
install_if_missing make
install_if_missing gpg
install_if_missing curl
install_if_missing vim
install_if_missing firefox-esr
install_if_missing xauth # for X11 forwarding (protocole d'affichage graphique de Linux)

# --------------------------------------------------
# GIT CLI INSTALLATION
# --------------------------------------------------
if ! command -v gh > /dev/null ; then
    echo "\nInstalling GIT CLI... "
    apt-get install gh
    # Authentificate to github account through classic token
    echo $3 | gh auth login --with-token
    # Adding ssh_key to github account
    gh ssh-key add /home/$1/.ssh/id_rsa.pub --title "$1"
    # To be able to add, commit, push => config avec l utilisateur
    sudo -u $1 git config --global user.email "$4"
    sudo -u $1 git config --global user.name "$5"
fi

# --------------------------------------------------
# Docker
# --------------------------------------------------
if ! command -v docker > /dev/null ; then
    echo "\nInstalling DOCKER..."
    sudo apt-get remove $(dpkg --get-selections docker.io docker-compose docker-doc podman-docker containerd runc | cut -f1)
    # Add Docker's official GPG key:
    sudo apt-get update
    sudo apt-get install ca-certificates curl
    install -m 0755 -d /etc/apt/keyrings
    sudo curl -fsSL https://download.docker.com/linux/debian/gpg -o /etc/apt/keyrings/docker.asc
    sudo chmod a+r /etc/apt/keyrings/docker.asc
    # Add the repository to Apt sources:
    sudo tee /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/debian
Suites: $(. /etc/os-release && echo "$VERSION_CODENAME")
Components: stable
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    sudo apt-get update
    # Install docker
    sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
fi

# --------------------------------------------------
# Ajouter ton user au groupe docker
# --------------------------------------------------
sudo usermod -aG docker $1
newgrp docker

# --------------------------------------------------
# Vscode
# --------------------------------------------------
if ! command -v code > /dev/null ; then
    echo "Installing VSCODE..."
    wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
    install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
    echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" |sudo tee /etc/apt/sources.list.d/vscode.list > /dev/null
    rm -f packages.microsoft.gpg
    apt-get install apt-transport-https
    apt-get update
    apt-get install code -y
fi

# --------------------------------------------------
# Bash
# --------------------------------------------------
echo "Setting bash as shell"
chsh -s /bin/bash $1

# --------------------------------------------------
# Clone the repository
# --------------------------------------------------
if [ ! -d /home/$1/$6 ] ; then
    sudo -u $1 git clone https://$3@github.com/ecnaraga/42_INCEPTION.git /home/$1/$6
fi

# --------------------------------------------------
# Create .env file
# --------------------------------------------------
touch /home/$1/$6/srcs/.env
echo "
MYUSER=$1
NGINX_HOST=$7
WP_DB_HOST=$8
WP_DB_NAME=$9
WP_SITEPATH=${10}
WP_SITEURL=${11}
WP_HOME=${12}
WP_ADMIN_USER=${13}
WP_ADMIN_PASSWORD=${14}
WP_ADMIN_MAIL=${15}
MARIADB_USER=${16}
MARIADB_PASSWORD=${17}
MARIADB_ROOT_PASSWORD=${18}
MARIADB_DATABASE=${19}" > /home/$1/$6/srcs/.env

chown $1:$1 /home/$1/$6/srcs/.env

touch /home/.secrets.txt
echo "
MYUSER $1" > /home/.secrets.txt

# --------------------------------------------------
# Modify /etc/hosts
# --------------------------------------------------
if ! cat /etc/hosts | grep $7 > /dev/null ; then
    echo "Adding hosts for p2..."
    sudo echo "127.0.0.1 $7" >> /etc/hosts
fi

# --------------------------------------------------
# Modify /etc/ssh/sshd_config
# --------------------------------------------------
sudo sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config
sudo sed -i 's/UsePAM no/UsePAM yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
reboot