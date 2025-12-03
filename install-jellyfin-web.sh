#!/bin/sh

function semverParseInto() {
    local RE='[^0-9]*\([0-9]*\)[.]\([0-9]*\)[.]\([0-9]*\)\([0-9A-Za-z-]*\)'
    #MAJOR
    eval $2=`echo $1 | sed -e "s#$RE#\1#"`
    #MINOR
    eval $3=`echo $1 | sed -e "s#$RE#\2#"`
    #MINOR
    eval $4=`echo $1 | sed -e "s#$RE#\3#"`
    #SPECIAL
    eval $5=`echo $1 | sed -e "s#$RE#\4#"`
}

MAJOR=0
MINOR=0
PATCH=0
SPECIAL=""

semverParseInto $(pacman -Q jellyfin-server | sed "s/jellyfin-server //") MAJOR MINOR PATCH SPECIAL

echo "Installed Jellyfin backend version: $MAJOR.$MINOR"

PROJDIR=$PWD
INSTALL="/usr/share/jellyfin"

echo "Project dir: $PROJDIR"
echo "Installing to: $INSTALL"

cd "$PROJDIR/jellyfin-web" || exit
git fetch || exit
git reset --hard || exit
git restore . || exit
git checkout "release-$MAJOR.$MINOR.z" || exit
git reset origin/"release-$MAJOR.$MINOR.z" --hard || exit
git apply --verbose "$PROJDIR/patches"/* || exit

source /usr/share/nvm/init-nvm.sh
nvm install 20
nvm use 20

npm install || exit

mkdir -p ./src/styles/custom
wget  -O ./src/styles/custom/catppuccin.css 			  https://jellyfin.catppuccin.com/theme.css
wget  -O ./src/styles/custom/catppuccin-macchiato.css  https://jellyfin.catppuccin.com/catppuccin-macchiato.css

wget  -O ./src/styles/custom/noseyrodent.css	https://the.sqky.one/.assets/fonts/noseyrodent.css
mkdir -p ./src/styles/custom/noseyrodent
wget  -O ./src/styles/custom/noseyrodent/noseyrodent-Regular.woff2 https://the.sqky.one/.assets/fonts/noseyrodent/noseyrodent-Regular.woff2
wget  -O ./src/styles/custom/noseyrodent/noseyrodent-Bold.woff2 https://the.sqky.one/.assets/fonts/noseyrodent/noseyrodent-Bold.woff2

sudo npm run build:production || exit
sudo mkdir -p "$INSTALL" || exit
sudo rm -rf "$INSTALL/web" || exit
sudo mv dist "$INSTALL/web" || exit

echo "Successfully installed to $INSTALL."
