#!/usr/bin/env bash

set -eu


# Parsing arguments
if [ -t 0 ] ; then
  printf "Micromamba binary folder? [~/.local/bin] "
  read BIN_FOLDER
  printf "Prefix location? [~/micromamba] "
  read PREFIXLOCATION
  printf "Init shell? [Y/n] "
  read INIT_YES
  printf "Configure conda-forge? [Y/n] "
  read CONDA_FORGE_YES
fi


# Fallbacks
BIN_FOLDER="${PREFIXLOCATION:-${HOME}/.local/bin}"
PREFIXLOCATION="${PREFIXLOCATION:-${HOME}/micromamba}"
INIT_YES="${INIT_YES:-yes}"
CONDA_FORGE_YES="${CONDA_FORGE_YES:-no}"

# Computing artifact location
ARCH="$(uname -m)"
OS="$(uname)"

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
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-${PLATFORM}-${ARCH}"
else
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/download/micromamba-${VERSION}/micromamba-${PLATFORM}-${ARCH}"
fi


# Downloading artifact
mkdir -p "${BIN_FOLDER}"
curl "${RELEASE_URL}" -o "${BIN_FOLDER}/micromamba" -fsSL --compressed ${CURL_OPTS:-}
chmod +x "${BIN_FOLDER}/micromamba"


# Initializing conda-forge
if [[ "$CONDA_FORGE_YES" == "" || "$CONDA_FORGE_YES" == "y" || "$CONDA_FORGE_YES" == "Y" || "$CONDA_FORGE_YES" == "yes" ]]; then
  "${BIN_FOLDER}/micromamba" config append channels conda-forge
  "${BIN_FOLDER}/micromamba" config append channels nodefaults
  "${BIN_FOLDER}/micromamba" config set channel_priority strict
fi


# Initializing shell
if [[ "$INIT_YES" == "" || "$INIT_YES" == "y" || "$INIT_YES" == "Y" || "$INIT_YES" == "yes" ]]; then
  case "$("${BIN_FOLDER}/micromamba" --version)" in
    1.*|0.*)
      "${BIN_FOLDER}/micromamba" shell init -p "${PREFIXLOCATION}"
      ;;
    *)
      "${BIN_FOLDER}/micromamba" shell init --root-prefix "${PREFIXLOCATION}"
      ;;
  esac

  echo "Please restart your shell to activate micromamba or run the following:\n"
  echo "  source ~/.bashrc (or ~/.zshrc, ...)"
fi
