#!/bin/bash

# ----------------------------
# Usage Function
# ----------------------------

function print_usage() {
    echo "Usage: $0 -a <registry_address> [-p <registry_port>]"
    echo
    echo "Options:"
    echo "  -a  Registry address (e.g. keycloak.fck8slab.local)"
    echo "  -p  Registry port (default: 443)"
    echo "  -h  Show this help message"
    exit 1
}

# ----------------------------
# Parse Arguments
# ----------------------------

REGISTRY_PORT=443

while getopts "a:p:h" opt; do
    case ${opt} in
        a ) REGISTRY_ADDRESS=$OPTARG ;;
        p ) REGISTRY_PORT=$OPTARG ;;
        h ) print_usage ;;
        * ) print_usage ;;
    esac
done

if [[ -z "$REGISTRY_ADDRESS" ]]; then
    echo "[!] Error: Registry address is required."
    print_usage
fi

# ----------------------------
# Detect OS
# ----------------------------

function detect_os() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        if [ -f /etc/os-release ]; then
            . /etc/os-release
            case "$ID" in
                ubuntu) OS="ubuntu" ;;
                rhel|centos|rocky|almalinux) OS="rhel" ;;
                *) OS="linux" ;;
            esac
        fi
    elif [[ "$OSTYPE" == "darwin"* ]]; then
        OS="mac"
    else
        OS="unknown"
    fi
}

# ----------------------------
# Fetch and Trust Certificate
# ----------------------------

function fetch_cert() {
    echo "[*] Fetching certificate from $REGISTRY_ADDRESS:$REGISTRY_PORT..."

    CERT_PATH="/tmp/${REGISTRY_ADDRESS//./_}_ca.crt"

    echo | openssl s_client -showcerts -connect $REGISTRY_ADDRESS:$REGISTRY_PORT 2>/dev/null \
        | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > "$CERT_PATH"

    if [ ! -s "$CERT_PATH" ]; then
        echo "[!] Failed to fetch certificate. Check the address and port."
        exit 1
    fi

    echo "[+] Certificate saved to $CERT_PATH"
}

function trust_cert() {
    echo "[*] Trusting certificate on $OS..."

    case "$OS" in
        ubuntu)
            cp "$CERT_PATH" "/usr/local/share/ca-certificates/${REGISTRY_ADDRESS}.crt"
            update-ca-certificates
            ;;
        rhel)
            cp "$CERT_PATH" "/etc/pki/ca-trust/source/anchors/${REGISTRY_ADDRESS}.crt"
            update-ca-trust extract
            ;;
        mac)
            sudo security add-trusted-cert -d -r trustRoot -k /Library/Keychains/System.keychain "$CERT_PATH"
            ;;
        *)
            echo "[!] Unsupported OS. Manual trust may be required."
            exit 1
            ;;
    esac

    echo "[+] Certificate trusted on $OS"
}

# ----------------------------
# Main Execution
# ----------------------------

detect_os
fetch_cert
trust_cert

echo "[✅] Done."

