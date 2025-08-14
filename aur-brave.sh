#!/usr/bin/bash
##############################################
#
# aur-brave.sh
#
# Get updates from AUR for "brave-bin"
#
# Requires wget, curl and gnupg
# Import Brave's gpg keys from here: 
# https://brave.com/signing-keys/#checksums-release-channel
#
# Set $STAGEDIR before running!
#
# V0.1, Gerrit <gerrit'at'funzt.one>, Aug. 2025
# - initial release
# V0.2, Gerrit <gerrit'at'funzt.one>, Aug. 2025
# - fixed package path for installation
# - update latest version in version file
# V0.3, Gerrit <gerrit'at'funzt.one>, Aug. 2025
# - added timeout for connections
#
##############################################

# variables
STAGEDIR=/path/to/your/build/directory  # where to build the new PKG, adjust this to your desired setup

## do not change anything below this line ##
PKGNAME=brave-bin  # AUR package name
BUILD=false
LVERS=`curl --connect-timeout 7 -s https://aur.archlinux.org/packages/${PKGNAME} | grep "Package Details" | awk '{print $4}' | cut -d "<" -f 1 | cut -d ":" -f 2`
BINVERS=`echo ${LVERS} | cut -d "-" -f 1`
DLURL="https://aur.archlinux.org/cgit/aur.git/snapshot/${PKGNAME}.tar.gz"
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
COLRESET='\033[0m'

# functions
error () {
  echo -e "${RED}ERROR: ${1}${COLRESET}"
  exit 1
}

# main
if [ -f ${STAGEDIR}/brave-vers.txt ]; then
  PREVERS=`head -1 ${STAGEDIR}/brave-vers.txt`
else
  echo "${LVERS}" > ${STAGEDIR}/brave-vers.txt
  PREVERS=${LVERS}
  BUILD=true
fi

if [ "${LVERS}" != "${PREVERS}" ]; then
  echo "${LVERS}" > ${STAGEDIR}/brave-vers.txt
  BUILD=true
fi

if [ "${BUILD}" = "true" ]; then
  # Download snapshot
  echo ""
  echo -e "${GREEN}INFO: Downloading snapshot of ${PKGNAME} ...${COLRESET}"
  wget --timeout 7 ${DLURL} -O ${STAGEDIR}/${PKGNAME}.tar.gz || error "Failed to download snapshot from AUR."

  # Unpack archive and delete archive file
  echo ""
  echo -e "${GREEN}INFO: Unpacking archive and moving to new name...${COLRESET}"
  tar -C ${STAGEDIR} -xvf ${STAGEDIR}/${PKGNAME}.tar.gz || error "Failed to unpack archive."
  mv ${STAGEDIR}/${PKGNAME} ${STAGEDIR}/${PKGNAME}_${LVERS} || error "Could not rename directory."
  rm ${STAGEDIR}/${PKGNAME}.tar.gz || echo -e "${YELLOW}WARNING: Could not remove ${STAGEDIR}/${PKGNAME}.tar.gz.${COLRESET}"
  
  # switch to unpacked snapshot
  cd ${STAGEDIR}/${PKGNAME}_${LVERS} || error "Could not switch to new working directory."
  
  # get signed checksums
  echo ""
  echo -e "${GREEN}INFO: Downloading sha256sums ...${COLRESET}"
  wget --timeout 7 https://github.com/brave/brave-browser/releases/download/v${BINVERS}/brave-browser-${BINVERS}-linux-amd64.zip.sha256.asc || error "Failed to download signature file"
  wget --timeout 7 https://github.com/brave/brave-browser/releases/download/v${BINVERS}/brave-browser-${BINVERS}-linux-amd64.zip.sha256 || error "Failed to download checksum file."

  # verify checksum file via gpg
  echo ""
  echo -e "${GREEN}INFO: Verifying gpg signature ...${COLRESET}"
  gpg --verify brave-browser-${BINVERS}-linux-amd64.zip.sha256.asc || error "Verification of checksum signature failed!"
  
  # check if sha256sums are identical
  echo ""
  CHKSUMGIT=`grep linux-amd64 brave-browser-${BINVERS}-linux-amd64.zip.sha256 | awk '{print $1}'`
  CHKSUMARC1=`grep sha256sums_x86_64 PKGBUILD | cut -d "'" -f 2`
  CHKSUMARC2=`grep sha256sums_x86_64 .SRCINFO | awk '{print $3}'`
  if [ "${CHKSUMGIT}" = "${CHKSUMARC1}" ] && [ "${CHKSUMGIT}" = "${CHKSUMARC2}" ]; then
    echo -e "${GREEN}INFO: Found correct checksum in PKGBUILD + .SRCINFO files.${COLRESET}"
  else
    error "Checksums do not match! Exiting."
  fi
  
  # if we end up here, all seems fine - build the package now
  echo ""
  echo -e "${GREEN}INFO: Now building package ...${COLRESET}"
  /usr/bin/makepkg
  RET=$?
  if [ ${RET} == 0 ]; then
    echo ""
    echo -e "${GREEN}INFO: makepkg succeeded. You can install the package by executing:${COLRESET}"
    echo "$ sudo pacman -U ${STAGEDIR}/${PKGNAME}_${LVERS}/brave-bin-1:${LVERS}-x86_64.pkg.tar.zst"
  else
    echo ""
    error "makepkg failed to build the package."
  fi
  
  echo ""

else
  echo ""
  echo -e "${GREEN}INFO: Latest version already present, nothing to do.${COLRESET}"
  echo ""
fi
