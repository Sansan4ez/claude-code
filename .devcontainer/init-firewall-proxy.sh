#!/bin/bash
set -euo pipefail

echo "Configuring firewall for proxy environment..."

# Flush existing rules and delete existing ipsets
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
ipset destroy allowed-domains 2>/dev/null || true

# First allow DNS and localhost before any restrictions
iptables -A OUTPUT -p udp --dport 53 -j ACCEPT
iptables -A INPUT -p udp --sport 53 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 22 -m state --state ESTABLISHED -j ACCEPT
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Create ipset
ipset create allowed-domains hash:net

# Add proxy server first
echo "Adding proxy server 168.81.66.89"
ipset add allowed-domains "168.81.66.89"

# Add essential domains manually (no GitHub API call)
echo "Adding essential IPs..."
# npm registry
ipset add allowed-domains "104.16.16.35"
ipset add allowed-domains "104.16.17.35"
# Anthropic API
ipset add allowed-domains "54.230.180.0/24"
# api.myip.com
ipset add allowed-domains "8.47.69.6"
ipset add allowed-domains "8.6.112.6"

# Get host IP
HOST_IP=$(ip route | grep default | cut -d" " -f3)
HOST_NETWORK=$(echo "$HOST_IP" | sed "s/\.[0-9]*$/.0\/24/")
echo "Host network: $HOST_NETWORK"

# Allow host network
iptables -A INPUT -s "$HOST_NETWORK" -j ACCEPT
iptables -A OUTPUT -d "$HOST_NETWORK" -j ACCEPT

# Allow proxy server on all common ports
iptables -A OUTPUT -d 168.81.66.89 -j ACCEPT
iptables -A INPUT -s 168.81.66.89 -j ACCEPT

# Set restrictive policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT DROP

# Allow established connections
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
iptables -A OUTPUT -m state --state ESTABLISHED,RELATED -j ACCEPT

# Allow traffic to allowed domains
iptables -A OUTPUT -m set --match-set allowed-domains dst -j ACCEPT

echo "Proxy-friendly firewall configuration complete"