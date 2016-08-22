#!/bin/bash

cd "$(dirname $0)" || exit
dot_path=$(pwd -P)
date=$(date +%Y%m%d-%H%M%S)

link_file() {
  local src=$1
  local dest=$2
  local skip=0
  if [ -a $dest ] || [ -h $dest ]; then
    if [ -h $dest ] && [ "z$(readlink $dest)" == "z${src}" ]; then
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
if [ "$(uname)" == "Darwin" ] && [ ! -f "$(which brew)" ]; then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# update homebrew and upgrade/install apps
if [ "$(uname)" == "Darwin" ]; then
  brew update
  brew upgrade
  brew bundle
fi

# install or upgrade prezto
if [ ! -d "${ZDOTDIR:-$HOME}/.zprezto" ]; then
  echo "Installing prezto"
  git clone --recursive https://github.com/sorin-ionescu/prezto.git "${ZDOTDIR:-$HOME}/.zprezto"
else
  cd "${ZDOTDIR:-$HOME}/.zprezto" && git pull && git submodule update --init --recursive
  cd ${dot_path} || exit
fi

# set default user for zsh
if [ ! -f "${HOME}/.zsh-default_user" ] && [ ! -h "${HOME}/.zsh-default_user" ]; then
  echo "export DEFAULT_USER=\"$(whoami)\"" > ${HOME}/.zsh-default_user
fi

# install powerline fonts
# if [[ `uname` == 'Darwin' ]]; then
#   # MacOS
#   font_dir="$HOME/Library/Fonts"
# else
#   # Linux
#   font_dir="$HOME/.local/share/fonts"
#   mkdir -p $font_dir
# fi
# if [ ! -f "${font_dir}/Meslo LG S Regular for Powerline.otf" ]; then
#   echo "Installing powerline font in ${font_dir}"
#   cp "Meslo LG S Regular for Powerline.otf" "$font_dir/"
#   # Reset font cache on Linux
#   if command -v fc-cache @>/dev/null ; then
#       echo "Resetting font cache, this may take a moment..."
#       fc-cache -f $font_dir
#   fi
# fi

# set default shell to zsh
zsh_path=$(which zsh)
if [ "$(basename $SHELL)" != "zsh" ] &&  [ -x ${zsh_path} ]; then
  # on osx zsh is in /usr/local/bin, we need to add it in /etc/shells
  if [ "$(uname)" == "Darwin" ] && [ "$(grep -c ${zsh_path} /etc/shells)" -eq 0 ]; then
    echo "Adding ${zsh_path} to /etc/shells"
    sudo sh -c "echo '${zsh_path}' >> /etc/shells"
  fi
  echo "Switching shell to zsh"
  chsh -s ${zsh_path}
fi

# linking dot files
echo "Linking dot files"
find $dot_path -name \*.symlink | while read src; do
  link_file $src "$HOME/$(basename "${src%.*}")"
  echo "$HOME/$(basename "${src%.*}")" linked to $src
done

# # node.js
# if [ -e "$(which npm)" ]; then
#   echo "Installing node.js packages"
#   sudo npm install -g tern nodemon azure-cli
# fi

# Atom packages
if [ -e "$(which apm)" ]; then
  apm install --check
  echo "Installing Atom packages"
  atom_packages=$(comm -23 <(cat atom/Atom.packages | sort) <(apm list --installed --bare | cut -d@ -f1 | sort) | grep -v "^$")
  if [ "$(echo -n ${atom_packages} | wc -l)" -gt 0 ]; then
    apm install --packages-file <(echo ${atom_packages})
  fi

  # upgrade Atom packages
  apm upgrade -c=false
fi
