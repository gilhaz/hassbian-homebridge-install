#!/bin/bash

echo "
Homebridge install script for Hassbian
"

if [ "$(id -u)" != "0" ]; then
   echo "This script must be run with sudo. Use \"sudo ${0} ${*}\"" 1>&2
   exit 1
fi

echo "
  Running apt-get preparation"
apt-get update
sudo apt-get install -y libavahi-compat-libdnssd-dev

echo "
  Getting node.js setup source.
  Be patient, working..."
curl -sL https://deb.nodesource.com/setup_7.x | sudo -E bash -
sudo apt-get install -y nodejs

echo "
  Install mp2 to manage autostart on boot for homebridge"
sudo npm install pm2 -g

# mast run this to not get this error when trying to run pm2: '/usr/bin/env: node: No such file or directory'
echo "
  Make a symlink to nodejs"
sudo ln -s /usr/bin/nodejs /usr/bin/node

echo "
  Installing homebridge with npm"
sudo npm install -g --unsafe-perm homebridge

echo "
  Installing homebridge-homeassistant with npm"
sudo npm install -g homebridge-homeassistant

echo "
  Adding homebridge configuration directory and adding HomeAssistant to config.json"

sudo mkdir ~/.homebridge
echo -n "
  ~~~~~~~~~~~~~~~~~~~~~~~~~~~~< HOST IP >~~~~~~~~~~~~~~~~~~~~~~~~~~~~
~ Enter Home Assistant address.
~ Example: '192.168.1.10:8123' or 'hassbian.local:8123'
Enter Host IP > " 
read -r host_ip

echo -n "
  ~~~~~~~~~~~~~~~~~~~~~~~~~< HOST PASSWORD >~~~~~~~~~~~~~~~~~~~~~~~~~
~ Enter the Home Assistant login password.
~ If you dont use a login password just press Enter to skip.
~ (you can always edit the 'config.json' yourself later)
Enter Login Pass > " 
read -r host_pass

if [ "$host_pass" = 0 ]
  then
    unset host_pass
  else 
    :
fi
cat >> ~/.homebridge/config.json <<EOF
{
   "bridge":{
      "name":"Homebridge",
      "username":"CC:22:3D:E3:CE:30",
      "port":51826,
      "pin":"031-45-154"
   },
   "platforms":[
      {
         "platform":"HomeAssistant",
         "name":"HomeAssistant",
         "host":"http://$host_ip",
         "password": "$host_pass",
         "supported_types":[
            "binary_sensor",
            "climate",
            "cover",
            "device_tracker",
            "fan",
            "group",
            "input_boolean",
            "light",
            "lock",
            "media_player",
            "scene",
            "sensor",
            "switch"
         ],
         "logging":true
      }
   ]
}
EOF

echo "
  Set homebridge to start on boot and restart on crash"
  pm2 start homebridge
  pm2 save
sudo env"PATH=$PATH:" pm2 startup -u pi --hp /home/pi

echo "
  Installation done.
  
  Configuration! homebridge is now install and Running. :)
  config.json available at ~/.homebridge/config.json

  You can use restart/stop/start homebridge like this Example:
  pm2 restart homebridge
"
