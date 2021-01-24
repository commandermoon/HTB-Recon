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
  echo "[*] Starting scans on interface $interface"
  sudo nmap $target -p- -T4 -Pn -sS | grep "open" | cut -d "/" -f 1 > ~/HackSpace/$name/recon/openports.txt
  num_ports=$(cat ~/HackSpace/$name/recon/openports.txt | wc -l)
  echo "[*] $num_ports open tcp ports detected. Scanning now" 
  ports=$(cat ~/HackSpace/$name/recon/openports.txt)
  ports=$(echo $ports | sed -e "s/ /,/g")
  echo "[*] Starting aggressive nmap on $target"
  nmap $target -p $ports -A -T4 -oN recon/fullnmap.txt -Pn
  echo "[*] Nmap complete. Time to bust subs"
  gobuster dns -u http://$target -w /opt/SecLists/Discovery/DNS/fierce-hostlist.txt -o ~/HackSpace/$name/recon/subdomains.txt
  echo "[*] Bust finished. It's fuzz o' clock"
  ffuf -w -u /opt/SecLists/Discovery/Web-Content/raft-small-directories-lowercase.txt http://$target/FUZZ | tee ~/HackSpace/$name/recon/dirs.txt
  echo "[*] It's getting late. Time for nik"
  nikto -h $target -output ~/HackSpace/$name/recon/nikto.txt
  echo "[*] Nik break is over"

  echo "# Info" >> Notes.md 
  echo "* Name: $name" >> Notes.md 
  echo "* IP: $target" >> Notes.md 
  echo "* Box: $box" >> Notes.md 
  echo "* Level: " >> Notes.md

else
  echo "Usage: ./htb-recon.sh <IP> <Name_of_Machine> <OS> "
  echo "Example: ./workspace.sh 10.10.10.180 ServMon Windows"

fi
