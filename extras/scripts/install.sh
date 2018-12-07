#!/usr/bin/env bash
ORI_PATH="$(pwd)"

if [[ -f /etc/fake-wsl-release ]]; then
	echo "You are using fake WSL Environment. This is for building and testing only."
elif [[ ! -f /proc/sys/fs/binfmt_misc/WSLInterop ]]; then
	echo "Your distro do not support WSL Interopability. Installation Aborted."
	exit 1
fi

cat << EOF
wslu installation for developers
---------------------------------
This is not a installer for normal user.
It provides completed development envir-
-onment of wslu, procede with caution. 
EOF

distro="$(cat /etc/os-release | head -n1 | sed -e 's/NAME="//g')"
if [[ "$distro" == *WLinux* ]]; then
	distro="wlinux"
elif [[ "$distro" == Ubuntu* ]]; then
	distro="ubuntu"
elif [[ "$distro" == *Debian* ]]; then
	distro="debian"
elif [[ "$distro" == *Kali* ]]; then
	distro="kali"
elif [[ "$distro" == openSUSE* ]]; then
	distro="opensuse"
elif [[ "$distro" == SLES* ]]; then
	distro="sles"
fi

echo "You are using: $distro"

echo "Installing dependencies...."
case "$distro" in
	'ubuntu'|'debian'|'kali'|'wlinux')
		sudo apt purge -y wlinux-wslu wslu
		sudo apt install -y git build-essential bc wget unzip make ruby-ronn imagemagick
		;;
	'opensuse'|'sles')
		sudo zypper -n rm wslu
		sudo zypper -n install git bc wget unzip make rubygem-ronn imagemagick
		;;
esac
if [[ ! -f /etc/fake-wsl-release ]]; then
	echo -e "\nWSL Interopability\n*********************"
	cat /proc/sys/fs/binfmt_misc/WSLInterop
	echo ""
fi

echo -e "\ntesting powershell.exe..."
powershell.exe -NoProfile -NonInteractive -Command Get-History
if [[ $? -eq 0 ]]; then
	echo "powershell.exe can be invoked."
else
	echo "powershell.exe failed to launch."
	exit 1
fi
ppep="`powershell.exe Get-ExecutionPolicy 2>&1 | tail -n1 | sed 's/\r$//'`"
echo -e "Powershell Execution Policy: $ppep"
if [[ "$ppep" = "Restricted" ]]; then
	cat << EOF
***************************************
               WARNING
***************************************
The execution policy for powershell.exe
should not be Restricted. You should se
t Powershell Execution Policy to Unrest
ricted with a Powershell Prompt with Ad
ministrator right:

   Set-ExecutionPolicy Unrestricted

Due to the limitation, it is not possib
le to invoke this command from WSL.
EOF
fi

if [ `pwd | grep wslu` ]; then
	cd ../../
	CURRENT_PATH="$(pwd)"
else
	git clone https://github.com/patrick330602/wslu.git
	cd wslu
	git checkout develop
	CURRENT_PATH="$(pwd)"
fi

make
chmod +x $CURRENT_PATH/out/*

PATH="$CURRENT_PATH/src:$CURRENT_PATH/out:$PATH"
git submodule init
git submodule update
extras/bats/libexec/bats tests/header.bats tests/wslsys.bats tests/wslusc.bats tests/wslupath.bats tests/wslfetch.bats tests/wslview.bats
PATH=$(getconf PATH)

for f in out/wsl*; do
	bname="$(basename $f)"
	sudo ln -s $CURRENT_PATH/$f /usr/bin/$bname
	echo "exec $f linked to /usr/bin/$bname"
done

sudo cp $CURRENT_PATH/src/mime/wslview /usr/lib/mime/packages/wslview
echo "mime file copied"
[ -d /usr/share/wslu ] || sudo mkdir /usr/share/wslu
sudo cp $CURRENT_PATH/src/etc/* /usr/share/wslu

sudo update-mime
sudo update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/wslview 10
sudo update-alternatives --install /usr/bin/www-browser www-browser /usr/bin/wslview 10

cat <<EOF
Installation Completed. Development environment is set up for wslu.
EOF

cd $ORI_PATH