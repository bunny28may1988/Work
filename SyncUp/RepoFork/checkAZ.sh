#!/bin/bash
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

OS=$(uname -s)

echo "Checking for Azure CLI and Azure DevOps CLI extensions..."

if ! command_exists az; then
    echo "Azure CLI (az) is not installed. Installing..."
    if [ "$OS" == "Linux" ]; then
        curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
    elif [ "$OS" == "Darwin" ]; then

        brew update && brew install azure-cli
    else
        echo "Unsupported operating system: $OS"
        exit 1
    fi
else
    echo "Azure CLI (az) is already installed."
fi

if ! az extension show --name azure-devops >/dev/null 2>&1; then
    echo "Azure DevOps CLI extension is not installed. Installing..."
    az extension add --name azure-devops
else
    echo "Azure DevOps CLI extension is already installed."
fi

echo "Azure CLI and Azure DevOps CLI extension are ready to use."