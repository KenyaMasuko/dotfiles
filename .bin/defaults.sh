#!/bin/bash

if [ "$(uname)" != "Darwin" ] ; then
	echo "Not macOS!"
	exit 1
fi

# Show bluetooth in the menu bar
defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true

# Avoid creating `.DS_Store` files on network volumes
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# Show the full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Show Tab bar in Finder
defaults write com.apple.finder ShowTabView -bool true

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable live conversion
defaults write com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey -bool false

# Display battery level in the menu bar
defaults write com.apple.menuextra.battery ShowPercent -string "YES"

# Display date, day, and time in the menu bar
defaults write com.apple.menuextra.clock DateFormat -string 'EEE d MMM HH:mm'

# Increase keyboard initial delay
defaults write -g InitialKeyRepeat -int 15

# Increase keyboard repeat rate
defaults write -g KeyRepeat -int 2

# Increase mouse speed
defaults write -g com.apple.mouse.scaling 1.5

# Use the Fn key as a standard function key
defaults write -g com.apple.keyboard.fnState -bool true

# Increase trackpad speed
defaults write -g com.apple.trackpad.scaling 3

# Show files with all extensions
defaults write -g AppleShowAllExtensions -bool true

# Enable switching to ABC input mode with Caps Lock key
defaults write com.apple.inputmethod.Kotoeri JIMPrefCapsLockSwitchesInputMode -bool true

# Set display to turn off after 30 minutes when on battery
sudo pmset -b displaysleep 30

# Set display to turn off after 30 minutes when connected to power adapter
sudo pmset -c displaysleep 30

# Set Japanese - Romaji input to Windows-style key operations
defaults write com.apple.inputmethod.Kotoeri JIMPrefLiveConversionKey -bool false
defaults write com.apple.inputmethod.Kotoeri JIMPrefShiftKeyAction -int 1
defaults write com.apple.inputmethod.Kotoeri JIMPrefCtrlKeyAction -int 1

# Disable correction of typing mistakes in Japanese - Romaji input
defaults write com.apple.inputmethod.Kotoeri JIMPrefAutoCorrect -bool false

## Enable three fingers dnd
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad TrackpadThreeFingerDrag -bool true
defaults write com.apple.AppleMultitouchTrackpad TrackpadThreeFingerDrag -bool true

# Hot corners
# Possible values:
#  0: no-op
#  2: Mission Control
#  3: Show application windows
#  4: Desktop
#  5: Start screen saver
#  6: Disable screen saver
#  7: Dashboard
# 10: Put display to sleep
# 11: Launchpad
# 12: Notification Center
# Top left screen corner → Launchpad
defaults write com.apple.dock wvous-tl-corner -int 11
defaults write com.apple.dock wvous-tl-modifier -int 0
# Top right screen corner → Notification Center
defaults write com.apple.dock wvous-tr-corner -int 12
defaults write com.apple.dock wvous-tr-modifier -int 0
# Bottom left screen corner → Put display to sleep
defaults write com.apple.dock wvous-bl-corner -int 10
defaults write com.apple.dock wvous-bl-modifier -int 0
# Bottom right screen corner → Show application windows
defaults write com.apple.dock wvous-br-corner -int 3
defaults write com.apple.dock wvous-br-modifier -int 0

# Automatically hide or show the Dock
defaults write com.apple.dock autohide -bool true
# Wipe all app icons from the Dock
defaults write com.apple.dock persistent-apps -array
# Set the icon size
defaults write com.apple.dock tilesize -int 55
# Magnificate the Dock
defaults write com.apple.dock magnification -bool true

# Enable `Tap to click`
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

for app in "Dock" \
	"Finder" \
	"SystemUIServer"; do
	killall "${app}" &> /dev/null
done
