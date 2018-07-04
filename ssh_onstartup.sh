#!/bin/bash

WHOAMI=`whoami`
STARTUP_FILE="/mnt/c/Users/$WHOAMI/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/ssh.vbs"
STARTUP_BAT="/mnt/c/Users/$WHOAMI/AppData/Roaming/Microsoft/Windows/Start Menu/Programs/Startup/ssh.bat"
STARTUP_BAT_WIN="C:"${STARTUP_BAT//\//\\}
STARTUP_BAT_WIN=${STARTUP_BAT_WIN/\\mnt\\c/}
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

read -e -p "SSH Port: " -i "22" SSH_PORT

echo "Adding sshd to the sudoers file...... o_0"
echo "%sudo ALL=NOPASSWD: /usr/sbin/sshd" | sudo tee --append /etc/sudoers

echo "Uninstalling/Reinstalling openssh"
sudo apt remove openssh-server
sudo apt install openssh-server

echo "Configuring /etc/ssh/sshd_config"
sudo sed -i "s/Port.*/Port $SSH_PORT/g" /etc/ssh/sshd_config
sudo sed -i "s/UsePrivilegeSeparation.*/UsePrivilegeSeparation no/g" /etc/ssh/sshd_config
sudo sed -i "s/PasswordAuthentication.*/PasswordAuthentication yes/g" /etc/ssh/sshd_config

echo "Restarting SSH"
sudo service ssh --full-restart

echo "Creating Startup Files..."
echo "Set WinScriptHost = CreateObject(\"WScript.Shell\")
WinScriptHost.Run Chr(34) & \""$STARTUP_BAT_WIN"\" & Chr(34), 0
Set WinScriptHost = Nothing
" > "$STARTUP_FILE"

echo 'C:\Windows\System32\bash.exe -c "sudo /usr/sbin/sshd -D"' > "$STARTUP_BAT"

echo "All Done! Restart and see if you can ssh!"
