#!/bin/bash

# GitHub Account Switcher Script
# Usage: ./github-switch.sh [personal|work]

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Configuration - MODIFY THESE
PERSONAL_NAME="HatriGt"
PERSONAL_EMAIL="hatrigt@gmail.com"
PERSONAL_GITHUB_USER="HatriGt"

WORK_NAME="hatrigt-atom"
WORK_EMAIL="a.ravichandran@atomdn.com"
WORK_GITHUB_USER="hatrigt-atom"
WORK_GITHUB_ORG="atom-insurance"  # Add organization name here

# Set default repo name for work projects if no remote exists
DEFAULT_WORK_REPO="default_branch_name_here.git"

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

# Get project name from directory
PROJECT_NAME=$(basename "$REPO_ROOT")

# Function to switch to personal account
switch_to_personal() {
  echo -e "${BLUE}Switching to personal GitHub account...${NC}"
  
  # Configure git user for this repository
  git config user.name "$PERSONAL_NAME"
  git config user.email "$PERSONAL_EMAIL"
  
  # Get the current remote URL
  REMOTE_URL=$(git remote get-url origin 2>/dev/null)
  REMOTE_EXISTS=$?
  
  # If remote exists, update it to use personal account
  if [ $REMOTE_EXISTS -eq 0 ]; then
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
  else
    # If no remote exists, add one based on current directory name
    echo -e "${YELLOW}No remote origin found. Adding based on current directory...${NC}"
    NEW_URL="https://github.com/$PERSONAL_GITHUB_USER/$PROJECT_NAME.git"
    git remote add origin $NEW_URL
  fi
  
  # Use the GitHub CLI if available to authenticate
  if command -v gh &>/dev/null; then
    echo -e "${BLUE}Authenticating with GitHub CLI...${NC}"
    gh auth login -h github.com -s "repo,read:org" -w
  else
    echo -e "${YELLOW}GitHub CLI not found. Manual authentication may be required.${NC}"
    echo -e "${YELLOW}Install with: brew install gh${NC}"
  fi
  
  # Verify remote URL was set successfully
  CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)
  if [ $? -eq 0 ] && [ -n "$CURRENT_REMOTE" ]; then
    echo -e "${GREEN}Successfully switched to personal GitHub account!${NC}"
    echo -e "User: ${BLUE}$PERSONAL_NAME${NC}"
    echo -e "Email: ${BLUE}$PERSONAL_EMAIL${NC}"
    echo -e "Remote URL: ${BLUE}$CURRENT_REMOTE${NC}"
  else
    echo -e "${RED}Error: Failed to set remote URL.${NC}"
    exit 1
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
  REMOTE_EXISTS=$?
  
  # If remote exists, update it to use work organization account
  if [ $REMOTE_EXISTS -eq 0 ]; then
    echo -e "${BLUE}Updating existing remote URL...${NC}"
    # Extract repository name from the URL
    if [[ $REMOTE_URL == git@github.com* ]]; then
      # For SSH URLs
      REPO_NAME=$(echo $REMOTE_URL | sed 's/.*\/\([^\/]*\)$/\1/')
      # Use organization in the URL instead of username
      NEW_URL="git@github.com:$WORK_GITHUB_ORG/$REPO_NAME"
      git remote set-url origin $NEW_URL
    elif [[ $REMOTE_URL == https://github.com* ]]; then
      # For HTTPS URLs
      REPO_NAME=$(echo $REMOTE_URL | sed 's/.*\/\([^\/]*\)$/\1/')
      # Use organization in the URL instead of username
      NEW_URL="https://github.com/$WORK_GITHUB_ORG/$REPO_NAME"
      git remote set-url origin $NEW_URL
    else
      # If URL format is not recognized
      echo -e "${YELLOW}Unrecognized remote URL format. Setting default work repository URL...${NC}"
      NEW_URL="https://github.com/$WORK_GITHUB_ORG/$DEFAULT_WORK_REPO"
      git remote set-url origin $NEW_URL
    fi
  else
    # If no remote exists, add one with organization
    echo -e "${YELLOW}No remote origin found. Adding default work repository...${NC}"
    # If project name is not empty, use it, otherwise use default
    if [ -n "$PROJECT_NAME" ]; then
      NEW_URL="https://github.com/$WORK_GITHUB_ORG/$PROJECT_NAME.git"
    else
      NEW_URL="https://github.com/$WORK_GITHUB_ORG/$DEFAULT_WORK_REPO"
    fi
    git remote add origin $NEW_URL
  fi
  
  # Use the GitHub CLI if available to authenticate
  if command -v gh &>/dev/null; then
    echo -e "${BLUE}Authenticating with GitHub CLI...${NC}"
    gh auth login -h github.com -s "repo,read:org" -w
  else
    echo -e "${YELLOW}GitHub CLI not found. Manual authentication may be required.${NC}"
    echo -e "${YELLOW}Install with: brew install gh${NC}"
  fi
  
  # Verify remote URL was set successfully
  CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null)
  if [ $? -eq 0 ] && [ -n "$CURRENT_REMOTE" ]; then
    echo -e "${GREEN}Successfully switched to work GitHub account!${NC}"
    echo -e "User: ${BLUE}$WORK_NAME${NC}"
    echo -e "Email: ${BLUE}$WORK_EMAIL${NC}"
    echo -e "Remote URL: ${BLUE}$CURRENT_REMOTE${NC}"
  else
    echo -e "${RED}Error: Failed to set remote URL.${NC}"
    exit 1
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
  else
    echo -e "Remote URL: ${YELLOW}Not configured${NC}"
  fi
  
  exit 1
fi

# Return to the original directory
cd "$CURRENT_DIR"
