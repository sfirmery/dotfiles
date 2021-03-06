#!/bin/bash

set -e
set -o pipefail

cd "$(dirname "$0")" || exit
dot_path=$(pwd -P)
date=$(date +%Y%m%d-%H%M%S)

link_file() {
  local src=$1
  local dest=$2
  local skip=0
  if [ -a "$dest" ] || [ -h "$dest" ]; then
    if [ -h "$dest" ] && [ "z$(readlink "$dest")" == "z${src}" ]; then
      skip=1
    else
      echo "Backuping file $dest to ${dest}.${date}"
      mv "$dest" "${dest}.${date}"
    fi
  fi
  if [ $skip == 0 ]; then
    echo "Linking $src to $dest"
    ln -s "$src" "$dest"
  fi
}

# install homebrew
if [ "$(uname)" == "Darwin" ] && [ ! -f "$(command -v brew)" ]; then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# update homebrew and upgrade/install apps
#if [ "$(uname)" == "Darwin" ]; then
#  brew update
#  brew upgrade
#  brew bundle
#fi

# install for Debian
if [ "$(uname)" == "Linux" ] && [ -f "$(command -v apt)" ]; then
  sudo apt update && sudo apt install shellcheck silversearcher-ag exuberant-ctags
fi

# Install fzf for linux
if [ "$(uname)" == "Linux" ] && [ ! -e "$HOME/.fzf" ]; then
    git clone --depth 1 https://github.com/junegunn/fzf.git "$HOME/.fzf"
    "$HOME/.fzf/install" --bin
fi

# install or upgrade prezto
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  echo "Installing prezto"
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
else
  cd "${ZDOTDIR:-$HOME}/.zprezto" && git pull && git submodule update --init --recursive
  cd "${dot_path}" || exit
fi

# set default user for zsh
if [ ! -f "${HOME}/.zsh-default_user" ] && [ ! -h "${HOME}/.zsh-default_user" ]; then
  echo "export DEFAULT_USER=\"$(whoami)\"" >"${HOME}"/.zsh-default_user
fi

# install fonts
if [[ $(uname) == 'Darwin' ]]; then
  # MacOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="$HOME/.local/share/fonts"
  mkdir -p "$font_dir"
fi
new_font=0
find fonts -maxdepth 1 -name \*.otf | while read -r font_file; do
  if [ ! -f "${font_dir}/$(basename "${font_file}")" ]; then
    echo "Installing ${font_file} in ${font_dir}"
    cp "${font_file}" "${font_dir}/"
    global new_font=1
  fi
done
if [ "$new_font" -gt 0 ] && command -v fc-cache @ >/dev/null; then
  echo "Resetting font cache, this may take a moment..."
  fc-cache -f "$font_dir"
fi

# set default shell to zsh
zsh_path=$(command -v zsh)
if [ "$(basename "$SHELL")" != "zsh" ] && [ -x "${zsh_path}" ]; then
  # on osx zsh is in /usr/local/bin, we need to add it in /etc/shells
  if [ "$(uname)" == "Darwin" ] && [ "$(grep -c "${zsh_path}" /etc/shells)" -eq 0 ]; then
    echo "Adding ${zsh_path} to /etc/shells"
    sudo sh -c "echo '${zsh_path}' >> /etc/shells"
  fi
  echo "Switching shell to zsh"
  chsh -s "${zsh_path}"
fi

# linking dot files
echo "Linking dot files"
find "$dot_path" -path "${dot_path}/.git" -prune -o -name \*.symlink -print | while read -r src; do
  link_file "$src" "$HOME/$(basename "${src%.*}")"
  echo "$HOME/$(basename "${src%.*}")" linked to "$src"
done

if [ ! -e "$HOME/.tmux/plugins/tpm" ]; then
  printf "WARNING: Cannot found TPM (Tmux Plugin Manager) \
 at default location: \$HOME/.tmux/plugins/tpm.\\n"
  git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

if [ -e "$HOME/.tmux.conf" ] && [ ! -h "$HOME/.tmux.conf" ]; then
  printf "Found existing .tmux.conf in your \$HOME directory. Will create a backup at %s/.tmux.conf.bak\\n" "$HOME"
  cp -f "$HOME/.tmux.conf" "$HOME/.tmux.conf.bak" 2>/dev/null || true
fi
ln -sf .tmux/tmux.conf "$HOME"/.tmux.conf

# Install TPM plugins.
# TPM requires running tmux server, as soon as `tmux start-server` does not work
# create dump __noop session in detached mode, and kill it when plugins are installed
printf "Install TPM plugins\\n"
tmux new -d -s __noop >/dev/null 2>&1 || true
tmux set-environment -g TMUX_PLUGIN_MANAGER_PATH "$HOME/.tmux/plugins"
"$HOME"/.tmux/plugins/tpm/bin/install_plugins || true
tmux kill-session -t __noop >/dev/null 2>&1 || true

# python
sudo pip3 install --upgrade -r requirements.txt

# node.js
if [ -e "$(command -v npm)" ]; then
  echo "Installing node.js packages"
  npm_pkgs=(
    bash-language-server
    prettier # js and yaml formatter
  )
  sudo npm install -g "${npm_pkgs[@]}"
#   sudo npm install -g tern nodemon azure-cli
fi

# VIM
vim -u NONE -c "helptags ALL" -c q

# Atom packages
#if [ -e "$(which apm)" ]; then
#  apm install --check
#  echo "Installing Atom packages"
#  atom_packages=$(comm -23 <(cat atom/Atom.packages | sort) <(apm list --installed --bare | cut -d@ -f1 | sort) | grep -v "^$")
#  if [ "$(echo -n ${atom_packages} | wc -l)" -gt 0 ]; then
#    apm install --packages-file <(echo ${atom_packages})
#  fi
#
#  # upgrade Atom packages
#  apm upgrade -c=false
#fi
