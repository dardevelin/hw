#!/bin/bash
# Remove debug logging from uChat.pas while keeping ARM64 fixes
sed -i '' '/AddFileLog.*\[DEBUG/d' hedgewars/uChat.pas
sed -i '' '/WriteLnToConsole.*\[DEBUG/d' hedgewars/uChat.pas

# Remove debug logging from hwengine.pas  
sed -i '' '/AddFileLog.*\[DEBUG/d' hedgewars/hwengine.pas
sed -i '' '/WriteLnToConsole.*\[DEBUG/d' hedgewars/hwengine.pas

echo "✅ Debug logging removed while keeping ARM64 fixes"
