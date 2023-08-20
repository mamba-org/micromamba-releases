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
BIN_FOLDER="${BIN_FOLDER:-${HOME}/.local/bin}"
PREFIXLOCATION="${PREFIXLOCATION:-${HOME}/micromamba}"
INIT_YES="${INIT_YES:-yes}"
CONDA_FORGE_YES="${CONDA_FORGE_YES:-no}"

# Computing artifact location
case "`uname`" in
  Linux)
    PLATFORM="linux" ;;
  Darwin)
    PLATFORM="osx" ;;
  *NT*)
    PLATFORM="win" ;;
esac

ARCH="`uname -m`"
case "$ARCH" in
  aarch64|ppc64le|arm64) ;;
  *)
    ARCH="64" ;;
esac

case "$PLATFORM-$ARCH" in
  linux-aarch64|linux-ppc64le|linux-64|osx-arm64|osx-64|win-64) ;;
  *)
    echo "Failed to detect your OS" >&2
    exit 1
    ;;
esac

if [[ "${VERSION:-}" == "" ]]; then
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-${PLATFORM}-${ARCH}"
else
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/download/micromamba-${VERSION}/micromamba-${PLATFORM}-${ARCH}"
fi


# Downloading artifact
mkdir -p "${BIN_FOLDER}"
curl "${RELEASE_URL}" -o "${BIN_FOLDER}/micromamba" -fsSL --compressed ${CURL_OPTS:-}
chmod +x "${BIN_FOLDER}/micromamba"


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


# Initializing conda-forge
if [[ "$CONDA_FORGE_YES" == "" || "$CONDA_FORGE_YES" == "y" || "$CONDA_FORGE_YES" == "Y" || "$CONDA_FORGE_YES" == "yes" ]]; then
  "${BIN_FOLDER}/micromamba" config append channels conda-forge
  "${BIN_FOLDER}/micromamba" config append channels nodefaults
  "${BIN_FOLDER}/micromamba" config set channel_priority strict
fi
