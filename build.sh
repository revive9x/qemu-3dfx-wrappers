export SUID_BIN="sudo"

if [ $(id -u) = 0 ]; then
    echo "This script cannot run as root."
    echo "Create a user with sudo permissions and rerun this script."
    echo ""
    exit 1
fi

echo "This script will install alot of dependencies."
echo "It is recommended you run this script in a container."

read -p "Continue? (y/n) " response
while true; do
 case $response in
   [Yy]* ) break;;
   [Nn]* ) exit;;
   * ) echo "Please answer yes or no.";;
 esac
 read -p "Continue? (y/n) " response
done

echo "- Setting up pacman.."
$SUID_BIN pacman-key --init
$SUID_BIN pacman -Syyu --noconfirm

echo "- Installing dependencies.."
$SUID_BIN pacman -S base-devel time mingw-w64 unzip perl git --noconfirm
export PATH=$PATH:/usr/bin/core_perl/:/opt/watcom/binl/

echo "- Installing required AUR dependencies.."

echo "- Installing openwatcom compiler.."
git clone https://aur.archlinux.org/openwatcom-v2.git
cd openwatcom-v2
makepkg -si --noconfirm
cd ..

echo "- Installing mingw-w64-tools.."
echo "- Workaround: Adding GPG-key manually.."
$SUID_BIN gpg --keyserver hkps://keyserver.ubuntu.com:443 --recv-key 93BDB53CD4EBC740
git clone https://aur.archlinux.org/mingw-w64-tools.git
cd mingw-w64-tools
makepkg -si --noconfirm
cd ..

echo "- Compiling djgpp cross compiler.."
git clone https://github.com/revive9x/build-djgpp
cd build-djgpp
if [ ! -d "i686" ]; then
    DJGPP_PREFIX=`pwd`/i686 time -p bash build-djgpp.sh 12.1.0-i686
fi
export PATH=$PATH:$(pwd)/i686/bin:$(pwd)/i686/i686-pc-msdosdjgpp/bin
cd ..

cd wrappers/3dfx
mkdir build || true
cd build 
bash ../../../scripts/conf_wrapper
$SUID_BIN make && $SUID_BIN make clean
cd ../../../

cd wrappers/mesa
mkdir build || true
cd build
bash ../../../scripts/conf_wrapper
$SUID_BIN make && $SUID_BIN make clean
cd ../../../

echo "Build complete!"
echo "Build output is available in: ./wrappers/3dfx/build and ./wrappers/mesa/build"