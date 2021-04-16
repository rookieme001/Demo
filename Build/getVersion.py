#!/usr/bin/python

import sys
import plistlib

if len( sys.argv ) >= 2 :
	pl_path = sys.argv[1]
else :
	pl_path = "Info.plist"

pl = plistlib.readPlist(pl_path)
print pl["CFBundleShortVersionString"]
