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


#Subfinder function
function subfinder {
    echo -e "${RED} [+] Launching subfinder ... ${RESET}"
    subfinder -d $domain > $subdomain_path/found.txt 
}
subfinder

#assetfinder function
function assetfinder {
    echo -e "${RED} [+] Launching assetfinder ... ${RESET}"
    assetfinder $domain | grep $domain >> $subdomain_path/found.txt
}
assetfinder

#amass function
function amass {
    sudo apt-get install amass -y
    echo -e "${RED} [+] Launching amass ... ${RESET}"
    amass enum -d $domain >> $subdomain_path/found.txt
}
amass

#httpprobe function
function httpprobe {
    echo -e "${RED} [+] Finding alive subdomains ... ${RESET}"
    cat $subdomain_path/found.txt | grep $domain | sort -u  | httpprobe -prefer-https | grep https | sed 's/https\?:\///' | tee -a $subdomain_path/alive.txt 
}
httpprobe
#gowitness function
function gowitness {
    sudo apt-get install gowitness -y
    echo -e "${RED} [+] Taking screenshots of alive subdomains ... ${RESET}"
    gowitness file -f $subdomain_path/alive.txt -P $screenshot_path/ --no-http
}
gowitness
#nmap function 
function nmap {
    echo -e "${RED} [+] Running nmap on alive subdomains ... ${RESET}"
    nmap -iL $subdomain_path/alive.txt -T4 -A -p- -oN $scan_path/nmap.txt
}
nmap
