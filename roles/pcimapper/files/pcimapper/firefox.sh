#!/bin/bash
set -euo pipefail
SUFFIX="snap/firefox/common/.mozilla/firefox"
SRC="/media/ingo/34fe1c69-7ee9-46a4-bd7a-f471e6cfa45f/home/ingo/${SUFFIX}/"
TARGET="${HOME}/${SUFFIX}"

export () {
  # Check if the profile directory exists
  if [ ! -d "$SRC" ]; then
      echo "Firefox profile directory not found."
      exit 1
  fi
  
  # Get the name of the default profile (assumes the first one is the desired profile)
  PROFILE_NAME=$(grep 'Path=' "$SRC/profiles.ini" | head -n 1 | cut -d= -f2)
  
  # Create a backup of the profile directory
  echo "Backing up Firefox profile $PROFILE_NAME..."
  mkdir -p "$TARGET/firefox-profile-backup"
  cp -r "$SRC/$PROFILE_NAME" "$TARGET/firefox-profile-backup/"
  
  # Copy the profiles.ini file to the backup location
  cp "$SRC/profiles.ini" "$TARGET/firefox-profile-backup/"
  
  echo "Profile backup completed. Files are in $TARGET/firefox-profile-backup/"
}

import() 
{
  mkdir -p "$TARGET"
  
  # Restore the profile and profiles.ini
  if [ -d "$SRC" ]; then
      echo "Restoring Firefox profile from backup..."
      cp -r "$SRC/"* "$TARGET/"
  else
      echo "Backup directory not found. Exiting."
      exit 1
  fi
  
  # Get the name of the backed-up profile
  PROFILE_NAME=$(grep 'Path=' "$SRC/profiles.ini" | head -n 1 | cut -d= -f2)
  echo "Exporting Profile: ${PROFILE_NAME}"
  
  # Modify profiles.ini to use the restored profile
  echo "Setting the restored profile as default..."
  sed -i "s|Path=.*|Path=$PROFILE_NAME|" "$TARGET/profiles.ini"
  
  echo "Firefox profile restoration complete. Launch Firefox to verify."

}

#export
import
