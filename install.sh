#!/bin/bash

set -eu

ARCH=$(uname -m)
OS=$(uname)

if [[ "$OS" == "Linux" ]]; then
  PLATFORM="linux"
  if [[ "$ARCH" == "aarch64" ]]; then
    ARCH="aarch64"
  elif [[ $ARCH == "ppc64le" ]]; then
    ARCH="ppc64le"
  else
    ARCH="64"
  fi    
elif [[ "$OS" == "Darwin" ]]; then
  PLATFORM="osx"
  if [[ "$ARCH" == "arm64" ]]; then
    ARCH="arm64"
  else
    ARCH="64"
  fi
elif [[ "$OS" =~ "NT" ]]; then
  PLATFORM="win"
  ARCH="64"
else
  echo "Failed to detect your OS" >&2
  exit 1
fi

if [[ "${VERSION:-}" == "" ]]; then
  RELEASE_URL=https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-$PLATFORM-$ARCH
else
  RELEASE_URL=https://github.com/mamba-org/micromamba-releases/releases/download/micromamba-$VERSION/micromamba-$PLATFORM-$ARCH
fi

BIN_FOLDER=~/.local/bin
mkdir -p $BIN_FOLDER
curl $RELEASE_URL -o $BIN_FOLDER/micromamba -fsSL --compressed ${CURL_OPTS:-}
chmod +x $BIN_FOLDER/micromamba

if [ -t 0 ] ; then
  printf "Init shell? [Y/n] "
  read YES
  printf "Prefix location? [~/micromamba] "
  read PREFIXLOCATION
else
  YES="yes"
fi

if [[ "${PREFIXLOCATION:-}" == "" ]]; then
  PREFIXLOCATION="~/micromamba"
fi

if [[ "$YES" == "" || "$YES" == "y" || "$YES" == "Y" || "$YES" == "yes" ]]; then
  $BIN_FOLDER/micromamba shell init -p "$PREFIXLOCATION"

  echo "Please restart your shell to activate micromamba or run the following:\n"
  echo "  source ~/.bashrc (or ~/.zshrc, ...)"
fi