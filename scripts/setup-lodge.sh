#!/usr/bin/env bash
set -euo pipefail

LODGE_DIR="${1:-.}"
BUILD_DIR_NAME="${2:-latex}"
BUILD_DIR="$LODGE_DIR/$BUILD_DIR_NAME"

echo "=== Setting up LaTeX build directory: $BUILD_DIR_NAME ==="

CONFIG="$LODGE_DIR/config/lodge.json"
if [[ ! -f "$CONFIG" ]]; then
  echo "Error: config/lodge.json not found"
  exit 1
fi

if ! command -v jq &> /dev/null; then
  echo "Error: jq required but not installed"
  exit 1
fi

SUMMONS_VARIANT=$(jq -r '.templates.summons // "standard"' "$CONFIG")
echo "→ Selected template: summons/$SUMMONS_VARIANT"

SUMMONS_SRC="$LODGE_DIR/templates/summons/$SUMMONS_VARIANT"

if [[ ! -d "$SUMMONS_SRC" ]]; then
  echo "Error: Template 'summons/$SUMMONS_VARIANT' not found"
  echo "Available variants:"
  ls -1 "$LODGE_DIR/templates/summons/" 2>/dev/null
  exit 1
fi

mkdir -p "$BUILD_DIR"/{data,agenda,build}

echo "→ Copying template files..."
cp "$SUMMONS_SRC/summons.tex" "$BUILD_DIR/"
cp "$SUMMONS_SRC/style.sty" "$BUILD_DIR/"
[[ -d "$SUMMONS_SRC/notices" ]] && cp -r "$SUMMONS_SRC/notices" "$BUILD_DIR/"
[[ -d "$SUMMONS_SRC/odes" ]] && cp -r "$SUMMONS_SRC/odes" "$BUILD_DIR/"

echo "→ Generating config.tex from template..."
if [[ -f "$SUMMONS_SRC/config.tex.template" ]]; then
  LODGE_NAME=$(jq -r '.lodge.name // "Lodge Name"' "$CONFIG")
  LODGE_NUMBER=$(jq -r '.lodge.number // "0000"' "$CONFIG")
  LODGE_FOUNDED=$(jq -r '.lodge.founded // "1900"' "$CONFIG")
  LODGE_ADDRESS=$(jq -r '.lodge.address // "Address"' "$CONFIG")
  LOGO_PATH=$(jq -r '.branding.logo // "/assets/logo.png"' "$CONFIG")
  
  sed \
    -e "s|{{LODGE_NAME}}|$LODGE_NAME|g" \
    -e "s|{{LODGE_NUMBER}}|$LODGE_NUMBER|g" \
    -e "s|{{LODGE_FOUNDED}}|$LODGE_FOUNDED|g" \
    -e "s|{{LODGE_ADDRESS}}|$LODGE_ADDRESS|g" \
    -e "s|{{LOGO_PATH}}|$LOGO_PATH|g" \
    "$SUMMONS_SRC/config.tex.template" > "$BUILD_DIR/config.tex"
fi

# Copy other template files
for tpl in "$SUMMONS_SRC"/*.template; do
  [[ -f "$tpl" ]] && [[ "$tpl" != *"config.tex.template" ]] && cp "$tpl" "$BUILD_DIR/$(basename "$tpl" .template)"
done

echo "→ Creating sample data files (if needed)..."
[[ ! -f "$BUILD_DIR/data/officers.csv" ]] && cat > "$BUILD_DIR/data/officers.csv" <<'CSV'
role,name,email,phone
Worshipful Master,John Smith,wm@example.com,01234567890
Senior Warden,Jane Doe,sw@example.com,01234567891
Secretary,Alice Johnson,sec@example.com,01234567893
CSV

[[ ! -f "$BUILD_DIR/data/meetings.csv" ]] && cat > "$BUILD_DIR/data/meetings.csv" <<'CSV'
meeting_number,meeting_date,tyling,venue,notes
0001,2025-01-15,18:30,Main Temple,Regular Meeting
CSV

[[ ! -f "$BUILD_DIR/data/past_masters.csv" ]] && cat > "$BUILD_DIR/data/past_masters.csv" <<'CSV'
year,name
2024,W.Bro. Past Master
CSV

cat > "$BUILD_DIR/.gitignore" <<'EOF'
*.aux
*.log
*.out
*.synctex.gz
*.toc
*.xdv
build/*.pdf
entry.tex
EOF

cat > "$BUILD_DIR/build.sh" <<'EOFBUILD'
#!/usr/bin/env bash
set -euo pipefail
MEETING="${1:-0001}"
mkdir -p build
echo "Building summons for meeting $MEETING..."
xelatex -jobname=summons -output-directory=build -interaction=nonstopmode "\def\MeetingNumber{$MEETING}\input{summons.tex}"
[[ $? -eq 0 ]] && echo "✓ build/summons.pdf" || echo "✗ Build failed"
EOFBUILD

chmod +x "$BUILD_DIR/build.sh"

echo ""
echo "✅ Build directory ready: $BUILD_DIR"
echo "   Template: summons/$SUMMONS_VARIANT"
echo ""
echo "Next: cd $BUILD_DIR && ./build.sh 0001"
