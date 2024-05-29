#!/bin/bash
while [[ "$#" -gt 0 ]]; do
    case $1 in
        -i|--ip-address) ip_address="$2"; shift ;;
        -m|--netmask) netmask="$2"; shift ;;
        -g|--gateway) gateway="$2"; shift ;;
        -n|--hostname) hostname="$2"; shift ;;
        -d|--dns) dns="$2"; shift ;;
        *) echo "Unknown parameter: $1"; exit 1 ;;
    esac
    shift
done

ip_prefix=$(ipcalc -nb 1.1.1.1 $netmask | sed -n '/Netmask/s/^.*=[ ]/\//p')
ip=$(echo "$ip_address\\$ip_prefix" | tr -d ' ')

#echo "update ip"
sed -i "s/^ip_address.*/ip_address: $ip/" unattended_ubuntu_vars.yml
#echo "update dns"
sed -i "s/^nameserver_address.*/nameserver_address: \"[$dns]\"/" unattended_ubuntu_vars.yml
#echo "update route"
sed -i "s/^default_route.*/default_route: $gateway/" unattended_ubuntu_vars.yml
#echo "update hostname"
sed -i "s/^hostname.*/hostname: $hostname/" unattended_ubuntu_vars.yml

sed -i "s/^iso_autoinstall.*/iso_autoinstall: $hostname/" unattended_ubuntu_vars.yml


ansible-playbook -i unattended_ubuntu.ini -e "@unattended_ubuntu_vars.yml" unattended_ubuntu.yml


