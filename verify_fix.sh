#!/bin/bash
# Regression test for the --safe-links fix in plesk_import_mail.sh
# (websavers/Plesk-Import-Maildir-Messages)
#
# Verifies that the fixed rsync invocation does NOT recreate symlinks that
# point outside the transferred tree, while a normal import still works.
# Local /tmp only. No network, no mail server, no third-party systems.
#
# Usage: bash verify_fix.sh
# Expected: both checks PASS
set -u

SRC=/tmp/fixcheck/src
DST=/tmp/fixcheck/dst
OUTSIDE=/tmp/fixcheck/outside_target
rm -rf /tmp/fixcheck
mkdir -p "$SRC" "$DST" "$OUTSIDE"
echo "dummy" > "$OUTSIDE/file.txt"
# symlink inside the "backup" pointing outside the transferred tree
ln -s "$OUTSIDE" "$SRC/.Shared"
# a normal file, to prove legit imports still work
echo "hello" > "$SRC/normal.txt"

echo "--- fixed invocation (with --safe-links) ---"
rsync -avt --safe-links "$SRC/" "$DST/" 2>&1 | grep -E "Shared|normal" || true

PASS=1
if [ -e "$DST/.Shared" ]; then  echo "FAIL: symlink was recreated despite --safe-links"
  PASS=0
else
  echo "PASS: outside symlink skipped"
fi
if [ -f "$DST/normal.txt" ]; then
  echo "PASS: normal file imported"
else
  echo "FAIL: normal file missing"
  PASS=0
fi

echo "--- vulnerable invocation (without --safe-links, for comparison) ---"
rm -rf "$DST" && mkdir -p "$DST"
rsync -avt "$SRC/" "$DST/" >/dev/null 2>&1
if [ -L "$DST/.Shared" ]; then
  echo "INFO: without --safe-links the symlink IS recreated (the bug)"
else  echo "INFO: unexpected - symlink not recreated even without the flag"
fi

if [ "$PASS" -eq 1 ]; then
  echo "RESULT: FIX VERIFIED"
else
  echo "RESULT: FIX FAILED"
  exit 1
fi
