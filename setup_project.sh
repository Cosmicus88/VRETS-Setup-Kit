#!/bin/bash
# Source nvm to ensure it's available in the script
export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm

# Check for nvm and Yarn installation
if ! command -v nvm &> /dev/null; then
    echo -e "\033[1;33m[WARNING] nvm not found. Please install nvm first.\033[0m"
    exit 1
fi
if ! command -v yarn &> /dev/null; then
    echo -e "\033[1;33m[WARNING] Yarn not found. Please install Yarn globally.\033[0m"
    exit 1
fi

# Get the latest LTS versions of Node.js
echo "Retrieving the latest LTS versions of Node.js..."
LTS_VERSIONS=$(nvm ls-remote --lts | grep "(Latest LTS:")

# Check if the command returned any versions
if [ -z "$LTS_VERSIONS" ]; then
    echo -e "\033[1;31m[ERROR] Unable to retrieve LTS versions of Node.js. Please check your nvm installation.\033[0m"
    exit 1
fi

# Display all available LTS versions with the latest label
echo "Latest LTS versions of Node.js available:"
echo "$LTS_VERSIONS"  # This prints all versions marked as latest LTS
echo ""  # Add a new line for better readability

CURRENT_NODE_VERSION=$(node -v | sed 's/^v//')
echo "Currently active Node.js version: $CURRENT_NODE_VERSION"

read -p "Enter the Node.js version you want to use (leave blank for latest): " NODE_VERSION
NODE_VERSION=${NODE_VERSION:-"node"}

# Install and use the specified or latest Node.js version
echo "Installing Node.js version: $NODE_VERSION"
nvm install "$NODE_VERSION"
nvm use "$NODE_VERSION"
INSTALLED_NODE_VERSION=$(node -v | sed 's/^v//')
echo "Node.js version set to $INSTALLED_NODE_VERSION"

# Get and set npm version
LATEST_NPM_VERSION=$(npm show npm version)
read -p "Enter the npm version you want to use (leave blank for latest): " NPM_VERSION
NPM_VERSION=${NPM_VERSION:-"latest"}
npm install -g npm@"$NPM_VERSION"
echo "npm version set to $(npm -v)"

# Get and set Yarn version
LATEST_YARN_VERSION=$(yarn info yarn version --json | jq -r '.data')
read -p "Enter the Yarn version you want to use (leave blank for latest): " YARN_VERSION
if [ -z "$YARN_VERSION" ]; then
    yarn set version stable
elif [ "$YARN_VERSION" == "berry" ]; then
    yarn set version berry
else
    yarn set version "$YARN_VERSION"
fi
echo "Yarn version set to $(yarn --version)"

# Create the Vite project in the current directory
echo "Initializing project with Vite and React template in the current directory..."
yarn create vite . --template react

# Install additional dependencies directly in the current directory
echo "Installing ExpressJS..."
yarn add express

echo "Installing TailwindCSS and PostCSS plugins..."
yarn add tailwindcss postcss autoprefixer
npx tailwindcss init

echo "Installing Sass..."
yarn add sass

# Create main SCSS file with Tailwind imports in the current directory
echo "Creating styles.scss with Tailwind imports..."
cat <<EOT > styles.scss
@import "tailwindcss/base";
@import "tailwindcss/components";
@import "tailwindcss/utilities";
EOT

echo -e "\033[1;32mSetup complete!\033[0m Your project is configured with Yarn, Vite, React, ExpressJS, TailwindCSS, and Sass."