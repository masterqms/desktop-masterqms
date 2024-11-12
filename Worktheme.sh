#!/bin/bash

#############################
##   Upgrade and install   ##
#############################
USER=$(whoami)

# Update the system
sudo -E apt update -y
sudo -E apt upgrade -y

# Install required packages
sudo -E apt install google-chrome-stable wget putty-tools filezilla putty -y

## Install Visual Studio Code
echo "code code/add-microsoft-repo boolean true" | sudo -E debconf-set-selections
sudo -E apt install gpg -y
wget -qO- https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > packages.microsoft.gpg
install -D -o root -g root -m 644 packages.microsoft.gpg /etc/apt/keyrings/packages.microsoft.gpg
echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/packages.microsoft.gpg] https://packages.microsoft.com/repos/code stable main" | sudo -E tee /etc/apt/sources.list.d/vscode.list > /dev/null
rm -f packages.microsoft.gpg
sudo -E apt install apt-transport-https -y
sudo -E apt update -y
sudo -E apt install code -y

## Install snap packages
sudo -E snap install postman
sudo -E snap install antares

#############################
##   Install Docker Engine   ##
#############################
# Remove existing Docker packages if installed
for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do 
    sudo -E apt-get remove $pkg -y
done

# Install Docker dependencies
sudo -E apt-get install ca-certificates curl -y
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc

# Add Docker repository
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo -E tee /etc/apt/sources.list.d/docker.list > /dev/null

# Update apt and install Docker
sudo -E apt-get update -y
sudo -E apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y

## Post-install Docker configuration
# Create Docker group if it doesn't exist
sudo -E getent group docker || sudo -E groupadd docker

# Add the current user to the Docker group
sudo -E usermod -aG docker $USER

# Enable Docker and containerd services to start on boot
sudo -E systemctl enable docker.service
sudo -E systemctl enable containerd.service

#############################
##   Setup GNOME desktop    ##
#############################
# Center the icons in the navbar
gsettings set org.gnome.shell.extensions.dash-to-dock always-center-icons true

# Push the app icon so there is no space between icons and the app icon
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-always-in-the-edge false

# Makes the menu bar fit the length of all icons
gsettings set org.gnome.shell.extensions.dash-to-dock extend-height false

# Set the app icon on the right side of the menu icons
gsettings set org.gnome.shell.extensions.dash-to-dock show-apps-at-top true

# Set the menu bar at the bottom of the screen
gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'

# Set the standard favorite short-cuts
gsettings set org.gnome.shell favorite-apps "['snap-store_snap-store.desktop', 'firefox_firefox.desktop', 'google-chrome.desktop', 'org.gnome.Terminal.desktop', 'code.desktop', 'putty.desktop', 'postman_postman.desktop', 'filezilla.desktop', 'org.gnome.Nautilus.desktop']"

#############################
## End of script            ##
#############################
