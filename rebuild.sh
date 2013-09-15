#!/bin/bash
set -e
VERSION=1.0
echo -e "[\e[32mrebuild.sh\e[00m] Installing required packages..."
sudo apt-get install git debhelper pbuilder dh-make debootstrap devscripts
if [ ! -d glxosd-$VERSION-orig ] 
then
    echo -e "[\e[33mrebuild.sh\e[00m] glxosd-$VERSION-orig missing, cloning..."
    git clone -b development https://github.com/nickguletskii/GLXOSD
    mv GLXOSD glxosd-$VERSION-orig
fi
echo -e "[\e[32mrebuild.sh\e[00m] Cleaning..."
rm -rf glxosd-$VERSION
rm -f glxosd_$VERSION*.build
rm -f glxosd_$VERSION*.orig.tar.gz
rm -f glxosd_$VERSION*.debian.tar.gz
rm -f glxosd_$VERSION*.dsc
rm -f glxosd_$VERSION*.deb
rm -f glxosd_$VERSION*.changes
rm -rf result
echo -e "[\e[32mrebuild.sh\e[00m] Copying sourcecode into work directory..."
rsync -abrv --progress --delete glxosd-$VERSION-orig/* glxosd-$VERSION/
cd glxosd-$VERSION/
echo -e "[\e[32mrebuild.sh\e[00m] Making original tgz..."
yes | dh_make --createorig -s
echo -e "[\e[32mrebuild.sh\e[00m] Copying Debian control files..."
rsync -abrv --progress --delete ../debian .
mkdir ../result
RESULT=../result
echo -e "[\e[32mrebuild.sh\e[00m] Building amd64 version..."
pdebuild --architecture amd64 --buildresult $RESULT --pbuilderroot "sudo DIST=precise ARCH=amd64"
echo -e "[\e[32mrebuild.sh\e[00m] Building i386 version..."
pdebuild --architecture i386 --buildresult $RESULT --pbuilderroot "sudo DIST=precise ARCH=i386"
for f in $RESULT/*.deb
do
    echo -e "[\e[32mrebuild.sh\e[00m] Checking " $f "..."
    lintian $f
done
echo -e "[\e[32mrebuild.sh\e[00m] \e[32mSuccess!\e[00m"
