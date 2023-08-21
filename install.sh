#!/bin/sh

set -eu

# Parsing arguments
if [ -t 0 ] ; then
  printf "Micromamba binary folder? [~/.local/bin] "
  read BIN_FOLDER
  printf "Init shell? [Y/n] "
  read INIT_YES
  printf "Configure conda-forge? [Y/n] "
  read CONDA_FORGE_YES
fi

# Fallbacks
BIN_FOLDER="${BIN_FOLDER:-${HOME}/.local/bin}"
INIT_YES="${INIT_YES:-yes}"
CONDA_FORGE_YES="${CONDA_FORGE_YES:-no}"

# Prefix location is relevant only if we want to call `micromamba shell init`
case "$INIT_YES" in
  y|Y|yes)
    if [ -t 0 ]; then
      printf "Prefix location? [~/micromamba] "
      read PREFIX_LOCATION
    fi
    ;;
esac
PREFIX_LOCATION="${PREFIX_LOCATION:-${HOME}/micromamba}"

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
  aarch64|ppc64le|arm64)
      ;;  # pass
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

if [ "${VERSION:-}" = "" ]; then
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/latest/download/micromamba-${PLATFORM}-${ARCH}"
else
  RELEASE_URL="https://github.com/mamba-org/micromamba-releases/releases/download/micromamba-${VERSION}/micromamba-${PLATFORM}-${ARCH}"
fi


# Downloading artifact
mkdir -p "${BIN_FOLDER}"
if hash curl >/dev/null 2>&1; then
  curl "${RELEASE_URL}" -o "${BIN_FOLDER}/micromamba" -fsSL --compressed ${CURL_OPTS:-}
elif hash wget >/dev/null 2>&1; then
  wget ${WGET_OPTS:-} -qO "${BIN_FOLDER}/micromamba" "${RELEASE_URL}"
else
  echo "Neither curl nor wget was found" >&2
  exit 1
fi
chmod +x "${BIN_FOLDER}/micromamba"


# Initializing shell
case "$INIT_YES" in
  y|Y|yes)
    case "`"${BIN_FOLDER}/micromamba" --version`" in
      1.*|0.*)
        shell_arg=-s
        prefix_arg=-p
        ;;
      *)
        shell_arg=--shell
        prefix_arg=--root-prefix
        ;;
    esac

    SHELLS=
    [ -e $HOME/.bashrc ] && SHELLS="$SHELLS bash"
    [ -e "${XDG_CONFIG_HOME:-$HOME/.config}/fish" ] && SHELLS="$SHELLS fish"
    [ -e "$HOME/.xonshrc" -o -e "${XDG_CONFIG_HOME:-$HOME/.config}/xonsh" ] && SHELLS="$SHELLS xonsh"
    [ -e "${ZDOTDIR:-$HOME}/.zshrc" ] && SHELLS="$SHELLS zsh"

    for shell in $SHELLS; do
        "${BIN_FOLDER}/micromamba" shell init $shell_arg $shell $prefix_arg "$PREFIX_LOCATION"
    done

    echo "Please restart your shell to activate micromamba or run the following:\n"
    echo "  source ~/.bashrc (or ~/.zshrc, ...)"
    ;;
esac


# Initializing conda-forge
case "$CONDA_FORGE_YES" in
  y|Y|yes)
    "${BIN_FOLDER}/micromamba" config append channels conda-forge
    "${BIN_FOLDER}/micromamba" config append channels nodefaults
    "${BIN_FOLDER}/micromamba" config set channel_priority strict
    ;;
esac
