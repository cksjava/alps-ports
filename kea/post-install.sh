#!/bin/bash
# AryaLinux post-install
# kea — Kea 3.0.2 DHCP Server
# Run after the package is installed. The build directory is already gone.
set -euo pipefail

if [[ -r /etc/aryalinux-build.conf ]]; then
    # shellcheck disable=SC1091
    source /etc/aryalinux-build.conf
elif [[ -n "${ARYA_CONFIG:-}" && -r "$ARYA_CONFIG" ]]; then
    # shellcheck disable=SC1091
    source "$ARYA_CONFIG"
fi

cat > /etc/kea/kea-ctrl-agent.conf << "EOF"
// Begin /etc/kea/kea-ctrl-agent.conf
{
  // This is a basic configuration for the Kea Control Agent.
  // The RESTful interface will be available at http://127.0.0.1:8000/
  "Control-agent": {
    "http-host": "127.0.0.1",
    "http-port": 8000,
    "control-sockets": {
      "dhcp4": {
        "socket-type": "unix",
        "socket-name": "/run/kea/kea4-ctrl-socket"
      },
      "dhcp6": {
        "socket-type": "unix",
        "socket-name": "/run/kea/kea6-ctrl-socket"
      },
      "d2": {
        "socket-type": "unix",
        "socket-name": "/run/kea/kea-ddns-ctrl-socket"
      }
    },

    "loggers": [
      {
        "name": "kea-ctrl-agent",
        "output_options": [
          {
            "output": "/var/log/kea/kea-ctrl-agent.log",
            "pattern": "%D{%Y-%m-%d %H:%M:%S.%q} %-5p %m\n"
          }
        ],
        "severity": "INFO",
        "debuglevel": 0
      }
    ]
  }
}
// End /etc/kea/kea-ctrl-agent.conf
EOF
cat > /etc/kea/kea-dhcp4.conf << "EOF"
// Begin /etc/kea/kea-dhcp4.conf
{
  "Dhcp4": {
    // Add names of your network interfaces to listen on.
    "interfaces-config": {
      "interfaces": [ "eth0", "eth2" ]
    },

    "control-socket": {
      "socket-type": "unix",
      "socket-name": "/run/kea/kea4-ctrl-socket"
    },

    "lease-database": {
      "type": "memfile",
      "lfc-interval": 3600,
      "name": "/var/lib/kea/kea-leases4.csv"
    },

    "expired-leases-processing": {
      "reclaim-timer-wait-time": 10,
      "flush-reclaimed-timer-wait-time": 25,
      "hold-reclaimed-time": 3600,
      "max-reclaim-leases": 100,
      "max-reclaim-time": 250,
      "unwarned-reclaim-cycles": 5
    },

    "renew-timer": 900,
    "rebind-timer": 1800,
    "valid-lifetime": 3600,

    // Enable DDNS - Kea will dynamically update the BIND DNS server
    "ddns-send-updates" : true,
    "ddns-qualifying-suffix": "your.domain.tld",
    "dhcp-ddns" : {
      "enable-updates": true
    },

    "subnet4": [
      {
        "id": 1001,   // Each subnet requires a unique numeric id
        "subnet": "192.168.56.0/24",
        "pools": [ { "pool": "192.168.56.16 - 192.168.56.254" } ],
        "option-data": [
          {
            "name": "domain-name",
            "data": "your.domain.tld"
          },
          {
            "name": "domain-name-servers",
            "data": "192.168.56.2, 192.168.3.7"
          },
          {
            "name": "domain-search",
            "data": "your.domain.tld"
          },
          {
            "name": "routers",
            "data": "192.168.56.2"
          }
        ]
      }
    ],

    "loggers": [
      {
        "name": "kea-dhcp4",
        "output_options": [
          {
            "output": "/var/log/kea/kea-dhcp4.log",
            "pattern": "%D{%Y-%m-%d %H:%M:%S.%q} %-5p %m\n"
          }
        ],
        "severity": "INFO",
        "debuglevel": 0
      }
    ]
  }
}
// End /etc/kea/kea-dhcp4.conf
EOF
cat > /etc/kea/kea-dhcp-ddns.conf << "EOF"
// Begin /etc/kea/kea-dhcp-ddns.conf
{
  "DhcpDdns": {
    "ip-address": "127.0.0.1",
    "port": 53001,
    "control-socket": {
      "socket-type": "unix",
      "socket-name": "/run/kea/kea-ddns-ctrl-socket"
    },

    "tsig-keys": [
      {
        "name"      : "rndc-key",
        "algorithm" : "hmac-sha256",
        "secret"    : "1FU5hD7faYaajQCjSdA54JkTPQxbbPrRnzOKqHcD9cM="
      }
    ],

    "forward-ddns" : {
      "ddns-domains" : [
        {
          "name" : "your.domain.tld.",
          "key-name": "rndc-key",
          "dns-servers" : [
            {
              "ip-address" : "127.0.0.1",
              "port" : 53
            }
          ]
        }
      ]
    },

    "reverse-ddns" : {
      "ddns-domains" : [
        {
          "name" : "56.168.192.in-addr.arpa.",
          "key-name": "rndc-key",
          "dns-servers" : [
            {
              "ip-address" : "127.0.0.1",
              "port" : 53
            }
          ]
        }
      ]
    },

    "loggers": [
      {
        "name": "kea-dhcp-ddns",
        "output_options": [
          {
            "output": "/var/log/kea/kea-ddns.log",
            "pattern": "%D{%Y-%m-%d %H:%M:%S.%q} %-5p %m\n"
          }
        ],
        "severity": "INFO",
        "debuglevel": 0
      }
    ]
  }
}
// End /etc/kea/kea-dhcp-ddns.conf
EOF

