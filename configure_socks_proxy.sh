#!/usr/bin/env bash

set -e

# This script configures the SOCKS proxy for the current user.
# Created with ❤️ by Raphaël MANSUY

# Set the default domain name that we want to use the socks proxy for
domain_name=""
# Set the default network interface that we want to use the socks proxy for
network_interface="WI-FI"
# Set the socks proxy address and port
proxy_address="127.0.0.1"
proxy_port="1080"

# Terminal colors
red="\033[0;31m"
green="\033[0;32m"
yellow="\033[0;33m"
blue="\033[0;34m"

# Terminal colors reset
reset="\033[0m"

# function color 
function color  {
    echo "$1$2$reset"
}

# log function
function info {
    echo -e "$1"
}

function error {
    echo -e "$(color $red "$1")"
}

function warn {
    echo -e "$(color $yellow "$1")"
}

function success {
    echo -e "$(color $green "$1")"
}


# An help function
function help {
    # get basename of the script
    local script_name=$(basename "$0")
    # Print the help message
    info ""
    info "Usage: $script_name [options]"
    info ""
    info ""
    info "Options:"
    info ""
#    info "  -d, --domain  Domain name to use the socks proxy for"
    info "   -i, --interface  Network interface to use the socks proxy for"
    info "   -proxy       Socks proxy address and port such as 127.0.0.0:8080"
    info "   -h, --help    Print this help message"
    info "   --remove      Remove the configuration for the specified domain name"
    info "   --help        Display this help message"
    # Display an example for openai.com domain and proxy address 127.0.0.0:8080
    info ""
    info " 👉 Example set proxy configuration:"
    info "" 
    info "  ./configure_socks_proxy.sh -proxy 127.0.0.0:8080"
    info ""
    info " 👉 Example remove proxy configuration:"
    info ""
    info "  ./configure_socks_proxy.sh --remove"    
}

list_network_services() {
    # List all the network services
    networksetup -listallnetworkservices
}

# Process the command-line arguments manually
while [ $# -gt 0 ]; do
  # Check if the --help flag is specified
  if [ "$1" = "--help" ]; then
    # Print the help message
    help
    # Exit the script
    exit 0
  fi

  # Check if the --remove flag is specified
  if [ "$1" = "--remove" ]; then
    # Remove the configuration for the specified domain name
    networksetup -setsocksfirewallproxystate "Wi-Fi" off
    # Print a message to indicate that the configuration has been removed
    success "Removed configuration for network interface: $network_interface"
    # Exit the script without running the rest of the code
    exit 0
  fi

  # Check if the proxy argument is specified
  if [ "$1" = "-proxy" ]; then
    # Set the proxy address and port
    proxy_address=$(echo "$2" | cut -d ":" -f 1)
    proxy_port=$(echo "$2" | cut -d ":" -f 2)
    # Shift the arguments to the left by 2
    shift 2
    # Continue to the next iteration of the loop
    continue
  fi 

  # Check if the network interface argument is specified
  if [ "$1" = "-i" ] || [ "$1" = "--interface" ]; then
    # Set the network interface
    network_interface="$2"
    # Shift the arguments to the left by 2
    shift 2
    # Continue to the next iteration of the loop
    continue
  fi

  # Check if the -d flag is specified
  if [ "$1" = "-d" ] || [ "$1" = "--domain" ]; then
    # Set the domain name to the value specified after the -d flag
    domain_name="$2"
    # Shift the arguments so that the next argument is processed
    shift 2
  else
    # Print an error message if an invalid option is specified
    error "🔥 Invalid option: $1"
    exit 1
  fi
done

# Check if the domain name is empty
#if [ -z "$domain_name" ]; then
#  help
#  echo ""
  # Print an error message if the domain name is empty
#  error "Domain name is empty" 
#  exit 1
#fi

# Display the proxy address and port that will be used
echo ""
info "👉 Using proxy address: $proxy_address:$proxy_port"
info "👉 Using network interface: $network_interface"

# Configure the network settings on the Mac to use the socks proxy for the specified domain name
networksetup -setsocksfirewallproxy $network_interface $proxy_address $proxy_port $domain_name

# Restart the network service to apply the changes
networksetup -setnetworkserviceenabled $network_interface off
networksetup -setnetworkserviceenabled $network_interface on

echo ""

# Print a message to indicate that the socks proxy has been configured
success "✅ Socks proxy configured for network interface: $network_interface"
success "✅ Using proxy address: $proxy_address:$proxy_port"
