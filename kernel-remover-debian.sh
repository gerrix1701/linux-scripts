#!/bin/bash
##
## ++++++++++++++++++++++++++++++++++++++++++++++
## kernel-remover-debian.sh
## ++++++++++++++++++++++++++++++++++++++++++++++
##
## Vers 1.1, Oct 2020, Gerrit <gerrit@funzt.info>
## - replaced apt-get by apt
## - removed support for older Debian versions
## Vers 1.0, June 2012, Gerrit <gerrit@funzt.info>
## - initial version
##
## script removing obsolete kernels from Debian based distros
## (first version tested with Ubuntu 12.04)
## CAUTION: You should know what you're doing!
##
## !! Use at your own risk !!
## 
## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
## GNU GENERAL PUBLIC LICENSE
## Version 3, 29 June 2007
##
## Copyright (C) 2007 Free Software Foundation, Inc. <https://fsf.org/>
## Everyone is permitted to copy and distribute verbatim copies
## of this license document, but changing it is not allowed.
##
## see https://www.gnu.org/licenses/gpl-3.0.txt
## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


## some variables
COL_BLUE="\x1b[34;01m"
COL_RED="\x1b[31;01m"
COL_RESET="\x1b[39;49;00m"


## say hello
echo -e "\n###########################"
echo -e "** Debian kernel-remover **"
echo -e "###########################\n"


## checks
echo -ne "Executing some checks ... "

# check root
ID=`whoami`
if [ "${ID}" != "root" ]; then
	echo -e "\nPlease run this script with 'sudo', exiting now.\n"
	exit 1
fi

# check for dpkg/apt
which dpkg &> /dev/null && which apt &> /dev/null
RT=$?
if [ "${RT}" != "0" ]; then
	echo -e "\nERROR: Couldn't find 'dpkg/apt'..."
	echo -e "Are you sure you are running Debian/Ubuntu?\n"
	exit 1
fi

echo -e "PASSED!\n"

## do kernel stuff
CURRENTKERNEL=`uname -r`
KERNELS_INSTALLED=`dpkg -l | grep linux-image-[0-9] | grep ^ii | awk '{print $2}' | cut -d "-" -f 3-`
KERNELS_TOREMOVE=`echo ${KERNELS_INSTALLED} | sed 's/\ /\n/g' | grep -v ${CURRENTKERNEL}`
KERNEL_DEV_INSTALLED=`dpkg -l | grep linux-headers-[0-9] | awk '{print $2}'`

# say good bye if only one kernel is present
if [ -z "$KERNELS_TOREMOVE" ]; then
	echo -e "\nYou have only one kernel ($COL_BLUE$CURRENTKERNEL$COL_RESET) installed, nothing to remove.\n"
	echo -e "\n** Finished `basename $0` **\n"
	exit 0
fi

# list/remove kernels
echo -e "\n----------------------------------------------------------"
echo -e "You have installed the following kernels on your system:\n"
for i in $KERNELS_INSTALLED; do
	echo -e "$COL_BLUE $i $COL_RESET"
done

echo -e "\nYou are currently running kernel $COL_BLUE$CURRENTKERNEL$COL_RESET, so you may remove:\n"
for i in $KERNELS_TOREMOVE; do
	echo -e "$COL_RED $i $COL_RESET"
done

echo -e "\nHINT: It is advisable to keep at least two working kernels."
echo -e "You may now select kernels you'd like to remove:"

for i in $KERNELS_TOREMOVE; do
	echo -ne "\nRemove kernel$COL_RED $i $COL_RESET[y|n]? "
	read ANSWER
	case "$ANSWER" in
		"Y" | "y" )
			VERS=`echo $i | cut -d "-" -f 1,2`
			echo $KERNEL_DEV_INSTALLED | grep $VERS &> /dev/null
			RT=$?
			if [ "$RT" = 0 ]; then
				echo -e "\nFound$COL_RED linux-headers-${VERS}*$COL_RESET package(s) and will remove it/them as well (and all dependencies)...\n"
				echo -e "PLEASE PAY ATTENTION TO OUTPUT OF 'apt purge' BELOW"
				echo -e "AND CHECK CAREFULLY IF REMOVAL OF PACKAGES IS WHAT YOU WANT!!!\n"
				HEADERS_TO_REMOVE=`echo $KERNEL_DEV_INSTALLED | sed 's/\ /\n/g' | grep $VERS`
				apt purge linux-image-${i} $HEADERS_TO_REMOVE
			else
				echo -e "\nNow removing kernel $COL_RED$i$COL_RESET (and all dependencies)...\n"
				echo -e "PLEASE PAY ATTENTION TO OUTPUT OF 'apt purge' BELOW"
				echo -e "AND CHECK CAREFULLY IF REMOVAL OF PACKAGE(S) IS WHAT YOU WANT!!!\n"
				apt purge linux-image-${i}
			fi
		;;
		"N" | "n" )
			echo -e "\nKeeping kernel $COL_BLUE$i$COL_RESET."
		;;
		* )
			echo -e "\nPlease answer 'y' or 'n'. Exiting now."
			exit 1
		;;
	esac
done

echo -e "\n** Finished `basename $0` **\n"

