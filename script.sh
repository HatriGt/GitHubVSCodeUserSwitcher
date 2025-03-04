#!/bin/bash

# GitHub Account Switcher Script
# Usage: ./github-switch.sh [personal|work]

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration - MODIFY THESE
PERSONAL_NAME="HatriGt"
PERSONAL_EMAIL="hatrigt@gmail.com"
PERSONAL_GITHUB_USER="HatriGt"

WORK_NAME="hatrigt-atom"
WORK_EMAIL="a.ravichandran@atomdn.com"
WORK_GITHUB_USER="hatrigt-atom"

# Store current directory to return to it
CURRENT_DIR=$(pwd)

# Determine if we're in a git repository
if ! git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
  echo -e "${YELLOW}Error: Not in a git repository.${NC}"
  exit 1
fi

# Get the repository root
REPO_ROOT=$(git rev-parse --show-toplevel)
cd "$REPO_ROOT"

# Function to switch to personal account
switch_to_personal() {
  echo -e "${BLUE}Switching to personal GitHub account...${NC}"
  
  # Configure git user for this repository
  git config user.name "$PERSONAL_NAME"
  git config user.email "$PERSONAL_EMAIL"
  
  # Get the current remote URL
  REMOTE_URL=$(git remote get-url origin 2>/dev/null)
  
  # If remote exists, update it to use personal account
  if [ $? -eq 0 ]; then
    # Check if it's an SSH URL
    if [[ $REMOTE_URL == git@github.com* ]]; then
      # Extract repo path (username/repo.git)
      REPO_PATH=$(echo $REMOTE_URL | sed 's/git@github.com://g')
      # If it's an organization repo, we need to extract just the repo name
      REPO_NAME=$(echo $REPO_PATH | sed 's/.*\///g')
      # Set new URL with personal username
      NEW_URL="git@github.com:$PERSONAL_GITHUB_USER/$REPO_NAME"
      git remote set-url origin $NEW_URL
    # Check if it's an HTTPS URL
    elif [[ $REMOTE_URL == https://github.com* ]]; then
      # Extract repo name
      REPO_NAME=$(echo $REMOTE_URL | sed 's/.*github.com\/.*\///g')
      # Set new URL with personal username
      NEW_URL="https://github.com/$PERSONAL_GITHUB_USER/$REPO_NAME"
      git remote set-url origin $NEW_URL
    fi
  fi
  
  # Use the GitHub CLI if available to authenticate
  if command -v gh &>/dev/null; then
    gh auth login -h github.com -s "repo,read:org" -w
  else
    echo -e "${YELLOW}GitHub CLI not found. Manual authentication may be required.${NC}"
    echo -e "${YELLOW}Install with: brew install gh${NC}"
  fi
  
  echo -e "${GREEN}Successfully switched to personal GitHub account!${NC}"
  echo -e "User: ${BLUE}$PERSONAL_NAME${NC}"
  echo -e "Email: ${BLUE}$PERSONAL_EMAIL${NC}"
  
  if [ $? -eq 0 ]; then
    echo -e "Remote URL: ${BLUE}$(git remote get-url origin 2>/dev/null)${NC}"
  fi
}

# Function to switch to work account
switch_to_work() {
  echo -e "${BLUE}Switching to work GitHub account...${NC}"
  
  # Configure git user for this repository
  git config user.name "$WORK_NAME"
  git config user.email "$WORK_EMAIL"
  
  # Get the current remote URL
  REMOTE_URL=$(git remote get-url origin 2>/dev/null)
  
  # If remote exists, update it to use work account
  if [ $? -eq 0 ]; then
    # For work accounts, we may want to keep the original organization name
    # This is just an example, you might need to adjust based on your org structure
    
    # Check if it's an SSH URL
    if [[ $REMOTE_URL == git@github.com* ]]; then
      # Extract repo name
      REPO_NAME=$(echo $REMOTE_URL | sed 's/.*\///g')
      # Set new URL with work organization
      NEW_URL="git@github.com:$WORK_GITHUB_USER/$REPO_NAME"
      git remote set-url origin $NEW_URL
    # Check if it's an HTTPS URL
    elif [[ $REMOTE_URL == https://github.com* ]]; then
      # Extract repo name
      REPO_NAME=$(echo $REMOTE_URL | sed 's/.*github.com\/.*\///g')
      # Set new URL with work organization
      NEW_URL="https://github.com/$WORK_GITHUB_USER/$REPO_NAME"
      git remote set-url origin $NEW_URL
    fi
  fi
  
  # Use the GitHub CLI if available to authenticate
  if command -v gh &>/dev/null; then
    gh auth login -h github.com -s "repo,read:org" -w
  else
    echo -e "${YELLOW}GitHub CLI not found. Manual authentication may be required.${NC}"
    echo -e "${YELLOW}Install with: brew install gh${NC}"
  fi
  
  echo -e "${GREEN}Successfully switched to work GitHub account!${NC}"
  echo -e "User: ${BLUE}$WORK_NAME${NC}"
  echo -e "Email: ${BLUE}$WORK_EMAIL${NC}"
  
  if [ $? -eq 0 ]; then
    echo -e "Remote URL: ${BLUE}$(git remote get-url origin 2>/dev/null)${NC}"
  fi
}

# Check which account to switch to
if [ "$1" == "personal" ]; then
  switch_to_personal
elif [ "$1" == "work" ]; then
  switch_to_work
else
  echo -e "${YELLOW}Usage: ./github-switch.sh [personal|work]${NC}"
  echo -e "Current config:"
  echo -e "User: ${BLUE}$(git config user.name)${NC}"
  echo -e "Email: ${BLUE}$(git config user.email)${NC}"
  
  if git remote get-url origin > /dev/null 2>&1; then
    echo -e "Remote URL: ${BLUE}$(git remote get-url origin)${NC}"
  fi
  
  exit 1
fi

# Return to the original directory
cd "$CURRENT_DIR"
