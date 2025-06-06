#!/bin/sh
#
# reload-groovy.sh
#   Copy updated Groovy scripts into the live instance and hot-reload them.
#
#   Adjust SRC if your mount path is different.

set -euo pipefail

SRC="/opt/staging/pd.profile/server-root/pre-setup/"   # live-edit bind mount on the host
DST="/opt/out/instance/lib/groovy-scripted-extensions"

echo "🛈  Copying Groovy scripts from $SRC to $DST …"
mkdir -p "$DST"
find "$SRC" -maxdepth 1 -type f -name '*.groovy' -print0 \
  | while IFS= read -r -d '' file; do
        echo "   ↳ $(basename "$file")"
        cp -f "$file" "$DST/"
        chmod +x "$DST/$(basename "$file")"
  done

echo "🛈  Forcing hot-reload of all Groovy-scripted plug-ins …"
# List only groovy-scripted plugins
plugins=$(dsconfig list-plugins --no-prompt |grep groovy-scripted)
for p in $plugins; do
  echo "   ↻  $p"
  dsconfig set-plugin-prop --plugin-name "$p" \
          --set enabled:false --no-prompt
  dsconfig set-plugin-prop --plugin-name "$p" \
          --set enabled:true  --no-prompt
done

echo "✓  Reload complete."