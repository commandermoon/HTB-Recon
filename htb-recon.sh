#!/bin/bash

target=$1
name=$2
box=$3

if (($#==3));
then

  ## Create directory
  mkdir -p ~/HackSpace/$name
  mkdir -p ~/HackSpace/$name/recon
  mkdir -p ~/HackSpace/$name/loot
  mkdir -p ~/HackSpace/$name/exploits

  ## Create session
  cd ~/HackSpace/$name
  export target
  export box
  export name

  ## Tunnel Check
  tun_check=$(ip addr | grep tun0)
  if [ -z "$tun_check" ];
  then
          eth_check=$(ip addr | grep eth1)
          if [ -z "$eth_check" ];
          then
                  interface=eth0
          else
                  interface=eth1
          fi
  else 
        interface=tun0
  fi

  ## Running Commands
  nmap -sC -sV -oN recon/initial_nmap.txt -v -Pn $target 
  sudo masscan -p 1-65535,U:1-65535 -e $interface -oL recon/allports.txt --rate=1000 -vv -Pn $target
  gobuster dir -u http://$target -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -o recon/dirscan.txt
  ffuf -w /usr/share/wordlists/dirb/big.txt -u http://$target/FUZZ | tee recon/ffuf.txt 

  echo "# Info" >> Notes.md 
  echo "* Name: $name" >> Notes.md 
  echo "* IP: $target" >> Notes.md 
  echo "* Box: $box" >> Notes.md 
  echo "* Level: " >> Notes.md

else
  echo "Usage: ./htb-recon.sh <IP> <Name_of_Machine> <OS> "
  echo "Example: ./workspace.sh 10.10.10.180 ServMon Windows"

fi
