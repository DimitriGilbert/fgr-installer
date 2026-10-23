# repack

## repack

```
install and run FitGirl-style repacks under Proton via umu-run:
	target: repack subcommand [one of 'id' 'install' 'list' 'rm' 'run' 'tricks' 'id']
Usage :
	repack <target>
```

## repack id

```
repack id command:
	title: game title to look up in the umu-database
Usage :
	bin/id <title>
```

## repack install

```
repack install command:
	source: repack setup.exe or the directory containing it
	games-root: root directory holding installed games
	title: game title, used for GAMEID lookup and install folder
	install-name: folder name under games-root (default: sanitized title), optional
	-p, --proton <proton>: Proton build passed to umu-run, env REPACK_PROTON (default: GE-Proton)
	-g, --gameid <gameid>: force a umu GAMEID and skip the database lookup
	--very-silent|--no-very-silent: run the installer fully headless (/VERYSILENT instead of /SILENT)
Usage :
	bin/install <source> <games-root> <title> [install-name] [--proton <value>] [--gameid <value>] [--[no-]very-silent]
```

## repack list

```
repack list command:
	--json|--no-json: print the raw games.json index
Usage :
	bin/list [--[no-]json]
```

## repack rm

```
repack rm command:
	name: install name of the game
	-f|--force|--no-force: delete without asking
Usage :
	bin/rm <name> [--[no-]force]
```

## repack run

```
repack run command:
	name: install name of the game (see: repack list)
	-e, --exe <exe>: override the recorded main exe (remembered)
Usage :
	bin/run <name> [--exe <value>]
```

## repack tricks

```
repack tricks command:
	name: install name of the game
Usage :
	bin/tricks <name>
```

## bin

### bin/id

```
repack id command:
	title: game title to look up in the umu-database
Usage :
	bin/id <title>
```

### bin/install

```
repack install command:
	source: repack setup.exe or the directory containing it
	games-root: root directory holding installed games
	title: game title, used for GAMEID lookup and install folder
	install-name: folder name under games-root (default: sanitized title), optional
	-p, --proton <proton>: Proton build passed to umu-run, env REPACK_PROTON (default: GE-Proton)
	-g, --gameid <gameid>: force a umu GAMEID and skip the database lookup
	--very-silent|--no-very-silent: run the installer fully headless (/VERYSILENT instead of /SILENT)
Usage :
	bin/install <source> <games-root> <title> [install-name] [--proton <value>] [--gameid <value>] [--[no-]very-silent]
```

### bin/list

```
repack list command:
	--json|--no-json: print the raw games.json index
Usage :
	bin/list [--[no-]json]
```

### bin/rm

```
repack rm command:
	name: install name of the game
	-f|--force|--no-force: delete without asking
Usage :
	bin/rm <name> [--[no-]force]
```

### bin/run

```
repack run command:
	name: install name of the game (see: repack list)
	-e, --exe <exe>: override the recorded main exe (remembered)
Usage :
	bin/run <name> [--exe <value>]
```

### bin/tricks

```
repack tricks command:
	name: install name of the game
Usage :
	bin/tricks <name>
```
