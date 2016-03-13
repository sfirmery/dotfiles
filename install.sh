#!/bin/bash

cd $(dirname $0)
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
if [ "$(uname)" == "Darwin" ] && [ ! -f $(which brew) ]; then
  echo "Installing Homebrew"
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# update homebrew and install apps
brew update
brew bundle

# install oh-my-zsh
if [ ! -d "${HOME}/.oh-my-zsh" ]; then
  echo "Installing oh-my-zsh"
  git clone git://github.com/robbyrussell/oh-my-zsh.git ${HOME}/.oh-my-zsh
fi

# set default user for zsh
if [ ! -f "${HOME}/.zsh-default_user" ] && [ ! -h "${HOME}/.zsh-default_user" ]; then
  echo "export DEFAULT_USER=\"$(whoami)\"" > ${HOME}/.zsh-default_user
fi

# install powerline fonts
if [[ `uname` == 'Darwin' ]]; then
  # MacOS
  font_dir="$HOME/Library/Fonts"
else
  # Linux
  font_dir="$HOME/.local/share/fonts"
  mkdir -p $font_dir
fi
if [ ! -f "${font_dir}/Meslo LG S Regular for Powerline.otf" ]; then
  echo "Installing powerline font in ${font_dir}"
  cp "Meslo LG S Regular for Powerline.otf" "$font_dir/"
  # Reset font cache on Linux
  if command -v fc-cache @>/dev/null ; then
      echo "Resetting font cache, this may take a moment..."
      fc-cache -f $font_dir
  fi
fi

# set default shell to zsh
if [ $(basename $SHELL) != "zsh" ] &&  [ -x /usr/local/bin/zsh ]; then
  if [ $(grep -c /usr/local/bin/zsh /etc/shells) -eq 0 ]; then
    echo "Adding /usr/local/bin/zsh to /etc/shells"
    sudo sh -c "echo '/usr/local/bin/zsh' >> /etc/shells"
  fi
  echo "Switching shell to zsh"
  chsh -s /usr/local/bin/zsh
fi

# linking dot files
echo "Linking dot files"
for src in $(find $dot_path -name \*.symlink); do
  link_file $src "$HOME/$(basename "${src%.*}")"
  echo "$HOME/$(basename "${src%.*}")" linked to $src
done

# linking zsh configuration files

# Atom part
apm install --check
echo "Installing Atom packages"
apm install --packages-file atom/package.json
