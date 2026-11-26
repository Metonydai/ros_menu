#!/bin/sh

echo "Installing Neuron Startup Menu..."

if [ ! -d $HOME/ros_menu ]; then
    if [ -z $MENU_VERSION ]; then
        git clone https://github.com/Metonydai/ros_menu $HOME/ros_menu
    fi
fi
cd $HOME/ros_menu
USE_CONTAINER=$USE_CONTAINER ./install.sh $MENU_CONFIG
cd - > /dev/null
