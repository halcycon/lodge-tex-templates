# Lodge LaTeX Templates

Central repository of **reusable LaTeX templates** with named variants.

## Template System

Templates are organized as: `<type>/<variant-name>/`

This allows multiple lodges to share a template library while each choosing their preferred style.

## Available Templates

### Summons Templates

#### summons/standard
Simple, clean layout for traditional lodges.
- Traditional appearance
- Minimal styling
- Single-page title layout
- Simple officer tables
- **Used by:** Lodge of Fidelity (L5749)

#### summons/horus
Elaborate Egyptian-themed layout.
- Custom decorative border on every page
- Gold and blue color scheme
- Patron status blocks
- Four-part post-nominals support
- Elaborate title page with crest
- Custom fonts and styling
- **Used by:** The Horus Lodge (L3155)

### Book Templates

#### book/standard
Custom LaTeX class for ritual books.

## Directory Structure

```
lodge-tex-templates/
├── summons/
│   ├── standard/
│   │   ├── summons.tex              # Document structure
│   │   ├── style.sty                # Styling macros
│   │   ├── config.tex.template      # Config with {{PLACEHOLDERS}}
│   │   ├── notices/                 # Standard notices
│   │   └── odes/                    # Opening/closing odes
│   └── horus/
│       ├── summons.tex
│       ├── style.sty
│       ├── config.tex.template
│       ├── page1-vars.tex.template  # Page 1 variables
│       ├── notices/
│       └── odes/
├── book/
│   └── standard/
│       └── lodgebook.cls
└── scripts/
    └── setup-lodge.sh
```

## What's Here

✅ Template `.tex` and `.sty` files
✅ Reusable document structures
✅ Standard notices and odes
✅ Multiple style variants

## What's NOT Here

❌ Lodge-specific data (officers.csv, meetings.csv, past_masters.csv)
❌ Meeting-specific agendas
❌ Build artifacts (*.aux, *.log, *.pdf)
❌ Generated PDFs

Those belong in **lodge repositories**.

## Usage

### 1. Add as Submodule

```bash
cd your-lodge-repo
git submodule add https://github.com/yourorg/lodge-tex-templates.git templates
```

### 2. Select Template in config/lodge.json

```json
{
  "lodge": {
    "name": "The Horus Lodge",
    "number": "3155"
  },
  "templates": {
    "summons": "horus"
  }
}
```

### 3. Set Up Build Directory

```bash
bash templates/scripts/setup-lodge.sh . latex
```

This copies the selected template variant to `latex/` and generates configuration.

### 4. Build Documents

```bash
cd latex
./build.sh 0456  # Builds summons for meeting 0456
```

## Placeholders

Template config files use double-brace placeholders:

| Placeholder | Source | Example |
|-------------|--------|---------|
| `{{LODGE_NAME}}` | lodge.name | The Horus Lodge |
| `{{LODGE_NUMBER}}` | lodge.number | 3155 |
| `{{LODGE_FOUNDED}}` | lodge.founded | 14th May 1906 |
| `{{LODGE_ADDRESS}}` | lodge.address | Freemasons' Hall... |
| `{{LOGO_PATH}}` | branding.logo | /assets/l3155-logo.png |

The setup script replaces these when generating lodge-specific files.

## Adding New Variants

1. Create `summons/<variant-name>/`
2. Add template files with `{{PLACEHOLDERS}}`
3. Document the variant in this README
4. Commit and push
5. Lodges can now select it in their config

## Future: CI/CD Integration

Perfect structure for GitHub Actions:

```yaml
- name: Build summons
  run: |
    cd latex
    xelatex '\def\MeetingNumber{${{ inputs.meeting }}}\input{summons.tex}'
```

## Contributing

Keep templates generic! Lodge-specific customizations belong in lodge repositories.
