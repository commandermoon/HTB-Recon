# HTB-Recon

## Requirements
* Masscan
* Nmap
* Gobuster
* ffuf

## Usage
* ./htb-recon.sh <IP> <Name of box> <OS>
* Example: `./htb-recon.sh 10.10.10.10. ServMon Windows`

## What it does
* Creates a workspace in your home dir.
* Creates different folders to keep things organized.
* Creates a Notes.md file to keep your notes.
* exports the ip to a env variable so you don't have to type it again and again
  , you can access it by `echo $target`

## Contribute
* Feel free to contribute to this repo.
