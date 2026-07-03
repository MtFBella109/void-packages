# Cosmic on Void

## Attention
If you are using the Repository, please note, that the Domain was changed to repo.sys109.de
Please Update your config. the Repository will be available, for a few weeks with the old and the new Domain. After that, the Repository will only be available through the new Domain

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
1.  Add Reposiotry
   - glibc: `echo 'repository=https://repo.sys109.de/repo/x86_64' | sudo tee /etc/xbps.d/59-cosmic.conf`
   - musl: `echo 'repository=https://repo.sys109.de/repo/x86_64-musl' | sudo tee /etc/xbps.d/59-cosmic.conf`
2. Update Package list: `sudo xbps-install -S`
3. Install single components with `sudo xbps-install -S <package_name>` or install all components, with `sudo xbps-install -S cosmic-desktop-full`
4. Optional, but recomended install firefox and sddm with `sudo xbps-install -S firefox sddm`

## Install and build via xbps-src
1. `git clone --depth 1 https://github.com/MtFBella109/void-packages.git`
2. `cd void-packages`
3. `./xbps-src binary-bootstrap`
4. You can build single components with `./xbps-src pkg <package_name>` or build every component with `./xbps-src pkg cosmic-desktop-full`
5. Install the package with `xi <package_name>` or with `xbps-install --repository hostdir/binpkgs <package_name>`
   > Note: The xi command is part of xtools
6. Optional, but recomended install firefox and sddm with `sudo xbps-install -S firefox sddm`

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
- cosmic-launcher
- cosmic-monitor
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
- cosmic-wallpapers
- cosmic-workspaces-epoch
- xdg-desktop-portal-cosmic
- pop-launcher

## Cosmic-greeter
I still didn't found a way, to get cosmic-greeter to working. it seems that elogind doesn't recognize it correctly. I don't know why it behaves that way and doesn't found a fix unfortunately. In the mean Time, I would recommend to use sddm or other Login manager

## Start cosmic session
You can use sddm or other graphical Login Manager or you can start it manually:
1. Login as your user
2. Type `start-cosmic`
> Note: This starts the whole cosmic-session for the user, as which you logged in
