# Use Gnome Tweak to swap Capslock to Backspace, so no need to use xkbcomp custom mappings
#xhost +si:localuser:root
#xkbcomp -w0 -I$HOME/.xkb ~/.xkb/keymap/mykbd $DISPLAY

# Enable repeating of Backspace once Capslock has been swapped to Backspace
xset r 66
