Update the system

```sh
sudo apt update && sudo apt upgrade -y
```

Bootstrap with software I want for working in the command line.

```sh
# install the 1 dependency
sudo apt install -y git
# clone my config repo to the local machine
git clone https://github.com/Graham42/dot_files.git ~/dot_files
# run the bootstrap script
cd ~/dot_files && ./bootstrap/linux/ubuntu.sh
```

Install shell personalization

```sh
cd ~/dot_files && ./init_all.sh
```

Install claude

```sh
curl -fsSL https://claude.ai/install.sh | bash
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc && source ~/.bashrc
```

# Laptop battery calibration and limits

see ./laptop-battery.md

# items to add to setup scripts

install neovim

- use the official ppa to get a more up to date version

```

```

install gh cli. see https://github.com/cli/cli/blob/trunk/docs/install_linux.md

also see the also readme for candidates.

consider switching software/apt mirrors to be closer for better speed.
