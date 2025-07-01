# Cosmic on Void
Big thanks to [Calandracas606](https://github.com/Calandracas606), I used their work as a base
## Install Cosmic
1. `git clone --depth 1 https://github.com/MtFBella109/void-packages.git`
2. `cd void-packages`
3. `./xbps-src binary-bootstrap`
4. You can either install every component with or you use the Metapackage cosmic-desktop. Cosmic-desktop installs you all components and everything you need to run it.
5. If you want to use the all settings in Power&Battery, you need to enable power-profile daemon with this command: `sudo ln -s /etc/sv/power-profiles-daemon /var/service/`

## Components
All packages:
- cosmic-applets
- cosmic-applibrary
- cosmic-bg
- cosmic-comp
- cosmic-desktop (Metapackage)
- cosmic-edit
- cosmic-files
- cosmic-greeter❌ Does not work (see below)
- cosmic-icons
- cosmic-idle
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
Cosmic-greeter doesn't work. I couldn't figure out why, for me It seems like, that it has something to with pam and/or elogind. Unfortunately I don't have enough knowledge on how to debug or fix this.
The cosmic-greeter Package is becasue of that marked as broke and isn't on the cosmic-desktop metapackage for now

## Start cosmic session
1. Login as your user
2. Type `start-cosmic`
*Note: The user, that runs start-cosmic, is automatically the user which is sgined in, in cosmic desktop*
