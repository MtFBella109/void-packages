# Cosmic on Void
Big thanks to [Calandracas606](https://github.com/Calandracas606), I used their work as a base

## Table of Contents

- [Install](#install-cosmic)
  - [Install via Repository](#install-via-repository)
  - [Install and build via xbps-src](#install-and-build-via-xbps-src)
- [Enable Services](#enable-services)
- [List of all components](#components)
- [Information about Cosmic Greeter](#cosmic-greeter)
- [Start Cosmic Desktop](#start-cosmic-session)

## Install Cosmic
### Install via Repository
> There is only a Repo for x86_64 Systems
1. If you haven't installed mesa-dri, please do it with: `sudo xbps-install -S mesa-dri`. *ATTENTION: If you have a NVIDIA Graphic card, you need mesa-dri too, cosmic doesn't start, without mesa-dri, you can of course install also the nvidia driver, that isn't a Problem*
2.  Add Reposiotry
   - glibc: `echo 'repository=https://bellawagner.de/repo/x86_64' | sudo tee /etc/xbps.d/59-cosmic.conf`
   - musl: `echo 'repository=https://bellawagner.de/repo/x86_64-musl' | sudo tee /etc/xbps.d/59-cosmic.conf`
4. Update Package list: `sudo xbps-install -S`
5. Install single components with `sudo xbps-install -S <package_name>` or install all components, with `sudo xbps-install -S cosmic-desktop-full`
6. Optional, but recomended install firefox and sddm with `sudo xbps-install -S firefox sddm`

## Install and build via xbps-src
1. If you haven't install graphic drivers on your system do `sudo xbps-install -S nvidia mesa-dri` for nvidia and `sudo xbps-install -S mesa-dri` for other GPU's
2. `git clone --depth 1 https://github.com/MtFBella109/void-packages.git`
3. `cd void-packages`
4. `./xbps-src binary-bootstrap`
5. You can build single components with `./xbps-src pkg <package_name>` or build every component with `./xbps-src pkg cosmic-desktop-full`
6. Install the package with `xi <package_name>` or with `xbps-install --repository hostdir/binpkgs <package_name>`
   > Note: You get the xi command with the package xtools
7. Optional, but recomended install firefox and sddm with `sudo xbps-install -S firefox sddm`

## Enable Services
1. You need to enable dbus, if you enable it, you need to do a restart, before you can start cosmic
2. For all settings in Power&Battery you need to enable also the profile-power-daemon

## Components
All packages:
- cosmic-applets
- cosmic-applibrary
- cosmic-bg
- cosmic-comp
- cosmic-desktop-full (Metapackage)
- cosmic-edit
- cosmic-files
- cosmic-greeter
- cosmic-icons
- cosmic-idle
- cosmic-initial-setup
- cosmic-launcher
- cosmic-notifications
- cosmic-osd
- cosmic-panel
- cosmic-player
- cosmic-randr
- cosmic-screenshot
- cosmic-session
- cosmic-settings
- cosmic-settings-daemon
- cosmic-term
- cosmic-theme-editor
- cosmic-wallpapers
- cosmic-workspaces-epoch
- xdg-desktop-portal-cosmic
- pop-launcher

## Cosmic-greeter
Cosmic-greeter worked for some time, is broka again. It will take some tme till I will look into it.

## Start cosmic session
You can use sddm or other graphical Login Manager or you can start it manually:
1. Login as your user
2. Type `start-cosmic`
> Note: The user, that runs start-cosmic, is automatically the user which is sgined in, in cosmic desktop
