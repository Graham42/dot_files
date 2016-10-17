#!/usr/bin/env bash
# Run this once only when setting up a Mac
# install brew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
# update lists
brew update
# install GNU packages because mac defaults are... different
brew install bash coreutils findutils gnu-sed gnu-tar grep
# actually use these instead of defaults
echo Creating ~/.bash_profile
cat >> ~/.bash_profile <<EOF
__GNUPATH=""
__GNUPATH="\$(brew --prefix)/bin:\$__GNUPATH"
__GNUPATH="\$(brew --prefix)/opt/coreutils/libexec/gnubin:\$__GNUPATH"
__GNUPATH="\$(brew --prefix)/opt/findutils/libexec/gnubin:\$__GNUPATH"
__GNUPATH="\$(brew --prefix)/opt/gnu-tar/libexec/gnubin:\$__GNUPATH"
__GNUPATH="\$(brew --prefix)/opt/gnu-sed/libexec/gnubin:\$__GNUPATH"
__GNUPATH="\$(brew --prefix)/opt/grep/bin:\$__GNUPATH"
export PATH="\$__GNUPATH:\$PATH"

__GNUMANPATH=""
__GNUMANPATH="\$(brew --prefix)/opt/coreutils/libexec/gnuman:\$__GNUMANPATH"
__GNUMANPATH="\$(brew --prefix)/opt/findutils/libexec/gnuman:\$__GNUMANPATH"
__GNUMANPATH="\$(brew --prefix)/opt/gnu-tar/libexec/gnuman:\$__GNUMANPATH"
__GNUMANPATH="\$(brew --prefix)/opt/gnu-sed/libexec/gnuman:\$__GNUMANPATH"
__GNUMANPATH="\$(brew --prefix)/opt/grep/share/man:\$__GNUMANPATH"
export MANPATH="\$__GNUMANPATH:\${MANPATH-/usr/share/man}"

if [ -f ~/.bashrc ]; then . ~/.bashrc; fi
EOF
