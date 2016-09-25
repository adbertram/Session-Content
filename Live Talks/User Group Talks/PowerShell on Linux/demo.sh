## Bring up a Windows box and an Ubuntu one

cd ~/vagrant
vagrant up

## SSH to Ubuntu

vagrant ssh ansible

## Download PowerShell for Ubuntu
wget https://github.com/PowerShell/PowerShell/releases/download/v6.0.0-alpha.10/powershell_6.0.0-alpha.10-1ubuntu1.14.04.1_amd64.deb

## Install PowerShell

sudo apt-get install libunwind8 libicu52
sudo dpkg -i ~/powershell_6.0.0-alpha.10-1ubuntu1.14.04.1_amd64.deb

## Combining Python and PowerShell commands
powershell
python3 ~/open_files.py | Select-String 'PowerShell'