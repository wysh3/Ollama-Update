#!/bin/bash

# Fetch the latest version from GitHub
LATEST_VERSION=$(curl -s https://api.github.com/repos/ollama/ollama/releases/latest | grep '"tag_name"' | sed -E 's/.*"([^"]+)".*/\1/')
INSTALLED_VERSION=$(ollama --version | awk '{print $NF}')  # Get the installed version correctly

# Remove the 'v' prefix from the latest version if it exists
LATEST_VERSION=${LATEST_VERSION#v}

# Debug: Print the versions to verify
echo "Latest version: $LATEST_VERSION"
echo "Installed version: $INSTALLED_VERSION"

# Check if the installed version matches the latest version
if [ "$LATEST_VERSION" != "$INSTALLED_VERSION" ]; then
    echo "A new version of Ollama is available: $LATEST_VERSION (Installed: $INSTALLED_VERSION)"
    read -p "Would you like to update Ollama? [Y/n]: " update_choice
    # Default to 'y' if no input is provided
    update_choice=${update_choice:-y}
    if [[ "$update_choice" =~ ^[Yy]$ ]]; then
        # Update Ollama
        curl -fsSL https://ollama.com/install.sh | sh
        echo "Ollama updated to version $LATEST_VERSION."
    else
        echo "Ollama update skipped."
    fi
else
    echo "Ollama is already up-to-date (Version: $INSTALLED_VERSION)."
fi

# After Ollama update prompt, ask whether to update models
read -p "Would you like to update all models now? [Y/n]: " model_choice
# Default to 'y' if no input is provided
model_choice=${model_choice:-y}
if [[ "$model_choice" =~ ^[Yy]$ ]]; then
    # Use the updated command to update models
    ollama list | awk 'NR>1 {print $1}' | xargs -I {} sh -c 'echo "Updating model: {}"; ollama pull {}; echo "--"'
    echo "All models updated."
else
    echo "Models update skipped."
fi

