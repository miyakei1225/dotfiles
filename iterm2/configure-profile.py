#!/usr/bin/env python3
"""Set MesloLGS Nerd Font on the default iTerm2 profile in an exported plist."""

import plistlib
import sys
from pathlib import Path


prefs_path = Path(sys.argv[1])
theme_path = Path(sys.argv[2])
with prefs_path.open("rb") as prefs_file:
    prefs = plistlib.load(prefs_file)
with theme_path.open("rb") as theme_file:
    theme = plistlib.load(theme_file)

default_guid = prefs.get("Default Bookmark Guid")
profiles = prefs.get("New Bookmarks", [])
profile = next(
    (item for item in profiles if item.get("Guid", "").lower() == str(default_guid).lower()),
    None,
)
if profile is None:
    raise SystemExit("Could not find the default iTerm2 profile; no changes made.")

current_font = profile.get("Normal Font", "")
font_parts = current_font.rsplit(" ", 1)
font_size = font_parts[1] if len(font_parts) == 2 and font_parts[1].replace(".", "", 1).isdigit() else "12"
profile["Normal Font"] = f"MesloLGSNF-Regular {font_size}"
profile.update(theme)
for key, value in theme.items():
    if key.endswith(" (Dark)"):
        profile[key.removesuffix(" (Dark)")] = value
profile["Use Separate Colors for Light and Dark Mode"] = False

with prefs_path.open("wb") as prefs_file:
    plistlib.dump(prefs, prefs_file)
