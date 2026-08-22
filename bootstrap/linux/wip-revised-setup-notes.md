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
