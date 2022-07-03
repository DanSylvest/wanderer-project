#### PREPARING SYSTEM
_REMEMBER! This guide will work for Windows 10 or 11 and Ubuntu-22.04_


**NOTE**! Here present **clear** installation _on **fresh system**_

1) Need to install Windows Terminal from Microsoft Store (just search it)
2) After install terminal open and switch to wsl version 2 (in PowerShell tab)
```bash
# It very IMPORTANT (otherwise postgresql will work incorrect)
$ wsl --set-default-version 2
```
3) Install your Ubuntu
4) Version should be 2; Chek it:
```bash
$ wsl -l -v

# output should be like this
  NAME            STATE           VERSION
  Ubuntu-22.04    Running         2
```
5) Open new tab with Ubuntu-22.04 LTS (or other version)

```bash
# update Ubuntu packages
$ sudo apt update

# upgrade Ubuntu
sudo apt -y upgrade

# install git
$ sudo apt install git
```

6) After make clone of wanderer-project
```bash
# in my opinion i creating projects folder in home folder
$ mkdir -p ~/projects/wanderer

# and then
$ cd ~/projects/wanderer
$ git clone https://github.com/DanSylvest/wanderer-project.git
$ cd wanderer-project
$ git checkout installer
$ cd scripts/ubuntu2204
```

7) And run installation

```bash
# give grants for script
$ chmod +x install.sh

# and run
$ ./install.sh
```