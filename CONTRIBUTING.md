# Contributing to Satsuma

Satsuma is MIT-licensed and welcomes contributions of any size — bug reports, docs fixes, a whole new wheel. The flow is standard GitHub.

## Quick start

```sh
# 1. Fork the repo on github.com/russonf/satsuma (click Fork, top right)
# 2. Clone your fork
git clone https://github.com/<your-username>/satsuma.git
cd satsuma

# 3. Install the one build tool we use
brew install xcodegen

# 4. Generate the Xcode project and open it
xcodegen generate
open Satsuma.xcodeproj
```

Hit ⌘R in Xcode to build and run. On first launch Satsuma asks for Accessibility (to detect modifier keys during a drag) and Full Disk Access (to read/write files). Grant both.

## Code layout

```
Satsuma/
├── SatsumaApp.swift          app entry + AppDelegate + menu bar
├── Core/                     overlay, drag detection, modifiers, toast, theme
├── Wheels/                   RadialMenu + the 5 wheel definitions
├── Converters/               image / video / audio / archive / document
├── Actions/                  tools, file actions, editors (crop/redact/annotate/resize/add-bg)
├── Settings/                 one SwiftUI view per settings tab
└── Preferences/              UserDefaults-backed stores (recipes, folders, favourites, launch at login)
```

Adding a new wheel segment is usually three edits:
1. Add an action function somewhere in `Actions/`.
2. Add a `WheelSegment(...)` entry in the relevant `*Wheel.swift`.
3. If it's user-configurable, surface it in a settings tab.

## Submitting a change

```sh
git checkout -b my-feature
# edit, commit as you go
git push origin my-feature
```

Then open a pull request on github.com against `main`. Keep PRs focused — one feature or fix per PR is easier to review than a mega-PR.

## What makes a good PR

- Builds cleanly in Xcode (no new warnings)
- Changes are scoped — don't reformat unrelated files
- UI changes include a before/after screenshot in the PR description
- If adding a new conversion, update `CompatibilityCatalog.swift` so the Settings matrix stays truthful
- Honest about limitations — if a new format can't do X, note it in the toast and the README

## Reporting bugs

Open an issue. Include:
- macOS version
- Satsuma version (About tab)
- What you dragged + which modifier + which segment
- Expected vs actual
- Any Console output from `log stream --predicate 'process == "Satsuma"'`

## Ideas we won't merge

- Analytics / tracking of any kind
- Nag screens, upsell banners, in-app purchases
- Anything that phones home
- Dependencies that pull in large frameworks (keep it native)

Satsuma stays free, local-only, and small. Keep that spirit and your PR has a good chance.
