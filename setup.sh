#!/bin/bash

echo "#######  Purging unrequired packages ########"
yes | sudo apt-get remove --purge wolfram-engine scratch nuscratch sonic-pi idle3 smartsim penguinspuzzle java-common minecraft-pi python-minecraftpi python3-minecraftpi
yes | sudo apt-get autoremove
yes | sudo apt-get autoclean

echo "########  Updating System ########"
yes | sudo apt-get update

echo "########  Installing Rasberry keyboard ########"
yes | sudo apt-get install matchbox-keyboard

echo "########  Installing Chromium Browser ########"
yes | sudo apt-get install chromium-browser

echo "########  Installing EOG ########"
yes | sudo apt-get install eog

echo "########  Installing Chromium Virtual Keyboard Extension ########"
EXTENSION_INSTALLATION_PATH="/usr/lib/chromium-browser/extensions"
CHROME_VIRUAL_KEYBOARD_EXTENSION_ID="lfaiipcbbikbnfcgcmaldlacamgekmnb"
FILENAME="$CHROME_VIRUAL_KEYBOARD_EXTENSION_ID.json"
cd "$EXTENSION_INSTALLATION_PATH"
echo '{"external_update_url":"https://clients2.google.com/service/update2/crx"}' > $FILENAME
chmod 755 $FILENAME

echo "########  Boot cfg settings for HDMI scaling ########"
sudo sed -i.bak 's/\#disable_overscan/disable_overscan/' /boot/config.txt
sudo sed -i 's/\#hdmi_force_hotplug=1/hdmi_force_hotplug=1/' /boot/config.txt
sudo sed -i 's/\#hdmi_group=1/hdmi_group=1/' /boot/config.txt
sudo sed -i 's/\#hdmi_mode=1/hdmi_mode=16/' /boot/config.txt
sudo sed -i 's/\#hdmi_drive=2/hdmi_drive=2/' /boot/config.txt
sudo sed -i 's/\#config_hdmi_boost=4/config_hdmi_boost=4/' /boot/config.txt

echo "########  Setting raspberrypi in Kiosk Mode  ########"
AUTOSTART_FILE="/home/pi/.config/lxsession/LXDE-pi/autostart"
echo "@lxpanel --profile LXDE-pi
@pcmanfm --desktop --profile LXDE-pi
@xscreensaver -no-splash
@point-rpi
@chromium-browser docon.tv --start-fullscreen
@xset s noblank
@xset s off
@xset -dpms
@unclutter -idle 0.1 -root" > $AUTOSTART_FILE

echo "########  Creating desktop shortcut  ########"
echo "chromium-browser docon.tv --start-fullscreen" > ~/Desktop/tv.sh
sudo chmod ugo+x ~/Desktop/tv.sh

echo "########  Setting cron to prevent Chromium Restore dialog on every ungraceful reboot ########"
echo "sudo sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/' ~/.config/chromium/Default/Preferences
sudo sed -i 's/\"exit_type\":\"Crashed\"/\"exit_type\":\"Normal\"/' ~/.config/chromium/Default/Preferences
sudo sed -i 's/\"exited_cleanly\":false/\"exited_cleanly\":true/' ~/.config/chromium/Local\ State " > ~/Downloads/clear_chromium_prefs.sh

echo "######## Disabling undesirable extensions <uBlock blocks GA by default> ########"
sudo rm -rf ~/.config/chromium/Default/Extensions/cjpalhdlnbpafiamejdnhcphjbkeiagm
sudo rm -rf ~/.config/chromium/Default/Extensions/aleakchihdccplidncghkekgioiakgal

echo "######## Setting date via internet ########"
echo "sudo date -s \"\$(wget -qSO- --max-redirect=0 google.com 2>&1 | grep Date: | cut -d' ' -f5-8)Z\"" > ~/Downloads/I_got_a_date.sh 

echo "######## Setting reboot crons ########"
crontab -r
crontab -l | { cat; echo "@reboot bash ~/Downloads/clear_chromium_prefs.sh"; } | crontab -
crontab -l | { cat; echo "@reboot sleep 10 && bash ~/Downloads/I_got_a_date.sh"; } | crontab -
crontab -l | { cat; echo "@reboot sleep 10 && bash ~/Downloads/poller.sh"; } | crontab -

echo "######## Setting swapsize to 2GB ########"
sudo sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=2048/' /etc/dphys-swapfile

echo "######## Setting timezone ########"
sudo rm /etc/localtime
sudo ln -s /usr/share/zoneinfo/Asia/Kolkata /etc/localtime
sudo rm /etc/timezone
echo "Asia/Kolkata" | sudo tee /etc/timezone 

echo "######## Killing EOG ########"
pkill eog

echo "######## REBOOTING ########"
sudo reboot
