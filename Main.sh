#!/bin/bash

domain=$1
RED="\033[1;31m"
RESET="\033[0m"

subdomain_path=$domain/subdomains 
screenshot_path=$domain/screenshots
scan_path=$domain/scans

if [ ! -d "$domain" ]; then 
    mkdir $domain 
fi 

if [ ! -d "$subdomain_path" ]; then 
    mkdir $domain 
fi 

if [ ! -d "$screenshot_path" ]; then 
    mkdir $domain 
fi 

if [ ! -d "$scan_path" ]; then 
    mkdir $domain 
fi 

#Subfinder
echo -e "${RED} [+] Launching subfinder ... ${RESET}"
subfinder -d $domain > $subdomain_path/found.txt 

#assetfinder
echo -e "${RED} [+] Launching assetfinder ... ${RESET}"
assetfinder $domain | grep $domain >> $subdomain_path/found.txt

#amass
sudo apt-get install amass -y
echo -e "${RED} [+] Launching amass ... ${RESET}"
amass enum -d $domain >> $subdomain_path/found.txt

echo -e "${RED} [+] Finding alive subdomains ... ${RESET}"
cat $subdomain_path/found.txt | grep $domain | sort -u  | httpprobe -prefer-https | grep https | sed 's/https\?:\///' | tee -a $subdomain_path/alive.txt 

#gowitness
sudo apt-get install gowitness -y
echo -e "${RED} [+] Taking screenshots of alive subdomains ... ${RESET}"
gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http

#nmap
echo -e "${RED} [+] Running nmap on alive subdomains ... ${RESET}"
nmap -iL $subdomain_path/alive.txt -T4 -A -p- -oN $scan_path/nmap.txt

