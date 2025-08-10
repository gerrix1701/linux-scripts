# linux_scripts
Just some scripts for Linux - might be useful, might be not - just for the fun of it :-)

Some small scripts, no big deal.
I do take care when writing scripts, however please don't blame me if anything get's messed up...


## kernel-remover-debian.sh
Script for Debian based distros to remove obsolete kernel packages which tend to pile up over time. It will ask before actually removing anything and of course will not touch the running kernel - at least it isn't supposed to.

## new_jekyll_post.sh
Very simple script to generate a new template for a Jekyll post. Run: `$ ./new_jekyll_post.sh "New blog title"`

## http_monitor.sh
Monitor http services and send a message to XMPP room

## aur-brave.sh
Arch Linux: build updated `brave-bin` from AUR without having to rely on any AUR helper. The script will:
- check if new version of Brave Browser is available in AUR
- download the snapshot from AUR
- download sha256sum files from Brave's GitHub repo and verify the signature
- compare sha256sum from Brave's GitHub repo with the one in PKGFILE
- build brave-bin ARCH package (will *not* be installed automatically!)
**Requirements:**
- `wget`, `curl` and `gnupg`
- import Brave's gpg keys from here first: https://brave.com/signing-keys/#checksums-release-channel
