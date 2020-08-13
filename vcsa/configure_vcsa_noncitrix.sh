#!/bin/bash

function usage {
  echo "USAGE:"
  echo "$(basename $0) [-d domain] [-u username] [-p password] [-s syslogserver]"
  echo
  echo "Where:"
  echo "  -d domain         The domain to join"
  echo "  -u username       The admin username to use to join the domain"
  echo "  -p password       The admin password to use to join the domain"
  echo "  -s syslogserver   The IP address of the syslog target server"
  echo
  echo "The script will prompt for any information not provided via a command"
  echo "line parameter."
  exit 1
}

# Get parameters from the command line, if specified
while getopts "d:u:p:s:h" opt; do
  case $opt in
    d) domain="$OPTARG";;
    u) username="$OPTARG";;
    p) password="$OPTARG";;
    s) syslogserver="$OPTARG";;
    h) usage;;
    *) echo "WARNING: unknown option \"$opt\" - ignoring!";;
  esac
done

# For each parameter not specified on the command line, prompt for the
# required information

if [[ -z $domain ]]; then
  read -p "Domain: " domain
  if [[ -z $domain ]]; then
    echo "ERROR: domain is required!"
    exit 1
  fi
fi

if [[ -z $username ]]; then
  read -p "Domain Administrator Username: " username
  if [[ -z $username ]]; then
    echo "ERROR: username is required!"
    exit 1
  fi
fi

if [[ -z $password ]]; then
  read -s -p "Domain Administrator Password: " password
  echo
  if [[ -z $password ]]; then
    echo "ERROR: password is required!"
    exit 1
  fi
fi

if [[ -z $syslogserver ]]; then
  read -p "Syslog Target Server: " syslogserver
  if [[ -z $syslogserver ]]; then
    echo "ERROR: Syslog Target Server is required!"
    exit 1
  fi
fi
if [[ ! ${syslogserver} =~ ^[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3} ]]; then
  echo "ERROR: syslog target server must be specified as an IP address!"
  exit 1
fi

# Join the VCSA to the domain
/opt/likewise/bin/domainjoin-cli join "${domain}" "$username" "$password"

# Install the TLSReconfigurator package
rpm -Uvh /tmp/VMware-vSphereTlsReconfigurator-6.5.0-5597882.x86_64.rpm

# Add syslog target server to syslog configuration
echo "*.* @@${syslogserver}:601;RSYSLOG_SyslogProtocol23Format" >> /etc/vmware-syslog/syslog.conf

# Reconfigure server for TLS 1.2 
/usr/lib/vmware-vSphereTlsReconfigurator/VcTlsReconfigurator/reconfigureVc update -p TLSv1.2
