#!/usr/bin/env bash
# Downloads and installs the pre-built gdk libraries for use by green_ios
set -e

# The version of gdk to fetch and its sha256 checksum for integrity checking
NAME="gdk-iphone"
SHA256="87124be9ca82c9000a5e6e82e17e61ded816a9782f167c1079ea8029e279ba15"

if [[ $1 == "--simulator" ]]; then
    # Get version for iphone simulator
    NAME="gdk-iphone-sim"
    SHA256="041a056e86bb6c6f978d920dfa7138592067100acfed9bfbe4926caba3044d81"
fi

# Setup gdk version and url
VERSION="release_0.0.38"
TARBALL="${NAME}.tar.gz"
URL="https://github.com/Blockstream/gdk/releases/download/${VERSION}/${TARBALL}"

# Pre-requisites
function check_command() {
    command -v $1 >/dev/null 2>&1 || { echo >&2 "$1 not found, exiting."; exit 1; }
}
check_command curl
check_command gzip
check_command shasum

# Find out where we are being run from to get paths right
if [ ! -d "$(pwd)/gaios" ]; then
    echo "Run fetch script from gaios project root folder"
    exit 1
fi

# Clean up any previous install
rm -rf gdk-iphone

# Fetch, validate and decompress gdk
curl -sL -o ${TARBALL} "${URL}"
echo "${SHA256}  ${TARBALL}" | shasum -a 256 --check
tar xf ${TARBALL}
rm ${TARBALL}
if [[ $1 == "--simulator" ]]; then
    mv -f ${NAME} "gdk-iphone"
fi

