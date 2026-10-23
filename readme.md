# repack

Install and run FitGirl-style repacks under Proton via [umu-run](https://github.com/Open-Wine-Components/umu-launcher).

Built with [parseArger](https://github.com/DimitriGilbert/parseArger) — every command has `--help`.

## Installation

On your gaming machine (needs `umu-run`, `jq`, `curl`, `python3`):

```bash
# download the installer
curl -s https://raw.githubusercontent.com/DimitriGilbert/repack-install/main/utils/get_repack -O;
chmod +x get_repack;
./get_repack --install;   # then: source ~/.bashrc (or your shell rc)
```

Or straight from a clone:

```bash
git clone https://github.com/DimitriGilbert/repack-install
cd repack-install && ./repack --help
```

## Usage

```bash
# look up a game's umu GAMEID first (protonfixes come from this id)
repack id "Grand Theft Auto V"

# install: setup.exe (or its folder), where games live, the game title,
# optional folder name; GAMEID is auto-resolved from the title
repack install ~/Downloads/SomeRepack /data/games "Grand Theft Auto V"
repack install ~/Downloads/SomeRepack /data/games "Tomb Raider" tomb-raider --gameid umu-2478970

# play — only the install name is needed, extra args go to the game
repack run grand-theft-auto-v
repack run grand-theft-auto-v --fullscreen

# everything else
repack list                 # installed games, ids, sizes, last played
repack list --json          # raw index
repack tricks grand-theft-auto-v vcrun2022 dotnet48   # winetricks, via umu-run
repack rm grand-theft-auto-v
```

Options worth knowing (see each command's `--help`):

- `repack install`: `-p/--proton` (default `GE-Proton`), `-g/--gameid` to force an id,
  `--very-silent` for a fully headless installer.
- `repack run`: `-e/--exe` to fix a wrongly detected main exe (remembered).
- Environment: `REPACK_PROTON`, `REPACK_GAMEID` as fallbacks for the options above,
  `REPACK_HOME` (default `~/.config/repack`) for the `games.json` index.

## How it works

- Each game lives in `<games-root>/<install-name>/prefix` — a Proton prefix with the
  game at `C:\games\<Title>`. Deleting that folder (or `repack rm`) is a full uninstall.
- The GAMEID is looked up in the [umu-database](https://github.com/Open-Wine-Components/umu-database)
  (curated: ~1200 games that have fixes). No entry means no protonfixes exist for that
  title, so `umu-default` is correct, not a failure. Ambiguous titles get an interactive
  picker (or `--gameid`).
- The main exe is auto-detected as the biggest exe minus installer junk (`unins*`,
  redists, crash handlers).
- `repack tricks` runs winetricks **through umu-run** so protonfixes state stays
  consistent — do not run plain `winetricks` against the prefix.
- First install downloads Proton + the Steam runtime (~1 GB) via umu-run.

## Development

Regenerate parsing, docs, completion and the HTML form after touching `# @parseArger`
declarations or command bodies:

```bash
make pa-parse      # regenerate argument parsing from declarations
make pa-document   # regenerate documentation.md
make pa-build      # all of the above + completion + form
```

Command bodies live after the `# @parseArger-end` marker in each `bin/*` script;
never edit the generated parsing blocks between the markers.
