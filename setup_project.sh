#!/bin/bash

# Source nvm to ensure it's available in the script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Colors for output
GREEN="\033[1;32m"
YELLOW="\033[1;33m"
RED="\033[1;31m"
CYAN="\033[0;36m"
RESET="\033[0m"
YELLOWBACK="\033[43m"
BLUE="\033[0;34m"
BLUEBACK="\033[44m"
MAGENTABACK="\033[45m"

# Check for nvm and Yarn installation
if ! command -v nvm &> /dev/null; then
    echo -e "${YELLOW}[WARNING] nvm not found. Please install nvm first.${RESET}"
    exit 1
fi

if ! command -v yarn &> /dev/null; then
    echo -e "${YELLOW}[WARNING] Yarn not found. Please install Yarn globally.${RESET}"
    exit 1
fi

# Get the latest LTS versions of Node.js
echo ""
echo -e "${GREEN}Retrieving the latest LTS versions of Node.js...${RESET}"
echo ""
LTS_VERSIONS=$(nvm ls-remote --lts | grep "(Latest LTS:")

# Check if the command returned any versions
if [ -z "$LTS_VERSIONS" ]; then
    echo -e "${RED}[ERROR] Unable to retrieve LTS versions of Node.js. Please check your nvm installation.${RESET}"
    exit 1
fi

# Display all available LTS versions with the latest label
echo -e "${BLUEBACK}Latest LTS versions of Node.js available:${RESET}"
echo ""
echo -e "${YELLOW}$LTS_VERSIONS${RESET}"
echo ""  # Added spacing

CURRENT_NODE_VERSION=$(node -v | sed 's/^v//')
echo -e "\033[0;36mCurrently active Node.js version: ${MAGENTABACK}$CURRENT_NODE_VERSION${RESET}"
echo ""  # Added spacing

# Prompt for Node.js version
read -p "$(echo -e "${GREEN}Enter the Node.js version you want to use (leave blank for latest): ${RESET}") " NODE_VERSION
echo ""
NODE_VERSION=${NODE_VERSION:-"node"}

# Check if the specified Node.js version is already installed
if nvm ls "$NODE_VERSION" &> /dev/null; then
    INSTALLED_NODE_VERSION=$(nvm version "$NODE_VERSION" | sed 's/^v//')
    echo -e "${GREEN}Node.js version $INSTALLED_NODE_VERSION is already installed.${RESET}"
    echo ""  # Added spacing
    echo -e "\033[0;36mCurrently active Node.js version: ${MAGENTABACK}$CURRENT_NODE_VERSION${RESET}"  # Added this line
else
    # Install and use the specified or latest Node.js version
    echo -e "${GREEN}Installing Node.js version: $NODE_VERSION...${RESET}"
    nvm install "$NODE_VERSION"
    echo ""
    INSTALLED_NODE_VERSION=$(node -v | sed 's/^v//')
    echo -e "${GREEN}Node.js version set to $INSTALLED_NODE_VERSION${RESET}"
fi

echo ""  # Added spacing

# Get and set npm version
LATEST_NPM_VERSION=$(npm show npm version)
read -p "$(echo -e "${GREEN}Enter the npm version you want to use (leave blank for latest): ${RESET}") " NPM_VERSION
NPM_VERSION=${NPM_VERSION:-"latest"}
npm install -g npm@"$NPM_VERSION"
echo -e "${GREEN}npm version set to $(npm -v)${RESET}"
echo ""  # Added spacing

# Get and set Yarn version
LATEST_YARN_VERSION=$(yarn info yarn version --json | jq -r '.data')
read -p "$(echo -e "${GREEN}Enter the Yarn version you want to use (leave blank for latest): ${RESET}") " YARN_VERSION
if [ -z "$YARN_VERSION" ]; then
    yarn set version stable
elif [ "$YARN_VERSION" == "berry" ]; then
    yarn set version berry
else
    yarn set version "$YARN_VERSION"
fi
echo -e "${GREEN}Yarn version set to $(yarn --version)${RESET}"
echo ""  # Added spacing

# Create the Vite project in the current directory
echo -e "${GREEN}Initializing project with Vite and React template in the current directory...${RESET}"
yarn create vite . --template react
echo ""  # Added spacing

# Install additional dependencies directly in the current directory
echo -e "${GREEN}Installing ExpressJS...${RESET}"
yarn add express
echo ""  # Added spacing

echo -e "${GREEN}Installing TailwindCSS and PostCSS plugins...${RESET}"
yarn add tailwindcss postcss autoprefixer
npx tailwindcss init
echo ""  # Added spacing

# Install Sass
echo -e "${GREEN}Installing Sass...${RESET}"
yarn add sass
echo ""  # Added spacing

# Create main SCSS file with Tailwind imports in the current directory
echo -e "${GREEN}Creating styles.scss with Tailwind imports...${RESET}"
cat <<EOT > styles.scss
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";
EOT
echo ""  # Added spacing

# Final setup message
echo -e "${GREEN}Setup complete!${RESET}"
echo -e "${CYAN}Your project is configured with Yarn, Vite, React, ExpressJS, TailwindCSS, and Sass.${RESET}"