#!/bin/bash

echo "#############################################################"
echo " WARNING WARNING WARNING"
echo "#############################################################"
echo "Removing ANY changes that you made and downloading latest version from the internet!"
echo
echo " * press <ctrl>+c to cancel"
echo " * press <enter> to continue"
read

git clean -df
git checkout origin/master -- .
git pull origin master
