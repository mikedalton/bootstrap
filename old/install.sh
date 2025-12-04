#!/bin/zsh
xcode-select --install
sudo xcodebuild -license
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"