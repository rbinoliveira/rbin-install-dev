#!/usr/bin/env bash

# Script to open iTerm2 Preferences at the Working Directory setting
# This helps configure new tabs to open in the same directory

echo "Opening iTerm2 Preferences..."
echo ""
echo "Once Preferences opens:"
echo "1. Go to 'Profiles' tab"
echo "2. Select your profile"
echo "3. Go to 'General' tab"
echo "4. Under 'Working Directory', select 'Reuse previous session's directory'"
echo ""

# Open iTerm2 Preferences
if [ -d "/Applications/iTerm.app" ]; then
  osascript <<'EOF'
tell application "iTerm"
  activate
  delay 0.5
  
  tell application "System Events"
    tell process "iTerm2"
      # Open Preferences
      keystroke "," using command down
      delay 1
      
      # Go to Profiles tab
      try
        click button "Profiles" of toolbar 1 of window 1
        delay 0.5
        
        # Select the first profile (default)
        try
          click row 1 of outline 1 of scroll area 1 of splitter group 1 of tab group 1 of window 1
          delay 0.5
          
          # Go to General tab
          click button "General" of toolbar 1 of window 1
        end try
      end try
    end tell
  end tell
end tell
EOF
  
  echo "✓ iTerm2 Preferences opened"
  echo ""
  echo "Now configure 'Reuse previous session's directory' in the General tab"
else
  echo "❌ iTerm2 not found at /Applications/iTerm.app"
  echo "   Please install iTerm2 first"
  exit 1
fi
