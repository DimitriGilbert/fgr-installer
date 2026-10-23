# repack shared library — sourced by bin/* commands.
# Relies on die()/log() from the parseArger skeleton of the calling script.

REPACK_DB_URL="${REPACK_DB_URL:-https://raw.githubusercontent.com/Open-Wine-Components/umu-database/main/umu-database.csv}"
REPACK_DB_CACHE="${XDG_CACHE_HOME:-$HOME/.cache}/repack/umu-database.csv"
REPACK_STATE="${REPACK_HOME:-${XDG_CONFIG_HOME:-$HOME/.config}/repack}"
REPACK_INDEX="$REPACK_STATE/games.json"
REPACK_PROTON_DEFAULT="GE-Proton"
# non-game exes that can be bigger than the real binary (installer leftovers)
REPACK_EXE_JUNK='(unins|setup|crash|dxsetup|vc_?redist|dotnetfx?|physx|directx|windowsmedia)'

rp_warn() { log "repack: warning: $*" -1; }

need_umu() {
	command -v umu-run >/dev/null 2>&1 || die "umu-run not found — pipx install umu-run (or dnf install umu-launcher)"
}

need_index_deps() {
	command -v jq >/dev/null 2>&1 || die "missing dependency 'jq' (dnf install jq)"
}

sanitize() { printf '%s' "$1" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9' '-' | sed -e 's:^-*::' -e 's:-*$::'; }
winname()  { printf '%s' "$1" | sed -e 's:[<>:"\\|?*/]::g' -e 's:[[:space:]]\+: :g' -e 's:^ ::' -e 's: $::'; }

index_load() { [[ -f $REPACK_INDEX ]] && cat "$REPACK_INDEX" || echo '{}'; }
index_get()  { index_load | jq -e --arg k "$1" '.[$k] // empty'; }
index_set()  { # <key> <json>
	mkdir -p "$REPACK_STATE"
	local t; t=$(mktemp)
	jq --arg k "$1" --argjson v "$2" '.[$k] = $v' <(index_load) >"$t" && mv "$t" "$REPACK_INDEX"
}
index_del()  { jq --arg k "$1" 'del(.[$k])' <(index_load) >"$REPACK_INDEX.tmp" && mv "$REPACK_INDEX.tmp" "$REPACK_INDEX"; }

fetch_db() { # keeps a 1-day cache
	if [[ ! -s $REPACK_DB_CACHE || -n $(find "$REPACK_DB_CACHE" -mmin +1440 -print -quit 2>/dev/null) ]]; then
		mkdir -p "$(dirname "$REPACK_DB_CACHE")"
		curl -fsSL "$REPACK_DB_URL" -o "$REPACK_DB_CACHE" || { [[ -s $REPACK_DB_CACHE ]] && rp_warn "db download failed, using stale cache"; return 1; }
	fi
}

# mode=find: prints "id<TAB>store" for a unique match; exit 1 = ambiguous
# (candidates on stderr), 2 = no match. mode=list: prints all matches.
find_id() { # <mode> <title>
	python3 - "$REPACK_DB_CACHE" "$1" "$2" <<'PY'
import csv, sys
path, mode, title = sys.argv[1], sys.argv[2], sys.argv[3].strip().lower()
rows = list(csv.DictReader(open(path, encoding="utf-8")))
exact = [r for r in rows if r["TITLE"].strip().lower() == title]
sub   = [r for r in rows if title in r["TITLE"].strip().lower()]
if mode == "list":
    for r in exact: print(f"* {r['UMU_ID']:<14} store={r['STORE']:<10} {r['TITLE']}")
    for r in sub:
        if r not in exact: print(f"  {r['UMU_ID']:<14} store={r['STORE']:<10} {r['TITLE']}")
    sys.exit(0)
pool = exact or sub
if exact:  # a repack is a standalone installer; prefer store=none entries
    standalone = [r for r in exact if r["STORE"].strip().lower() == "none"]
    pool = standalone or exact
ids = {}
for r in pool: ids.setdefault(r["UMU_ID"], r["STORE"])
if not ids: sys.exit(2)
if len(ids) == 1:
    i, s = next(iter(ids.items())); print(f"{i}\t{s}"); sys.exit(0)
for r in pool: print(f"  candidate: {r['UMU_ID']} (store={r['STORE']}) {r['TITLE']}", file=sys.stderr)
sys.exit(1)
PY
}

resolve_gameid() { # <title> [forced-id]; sets gameid/store; never aborts the install
	gameid=umu-default store=none
	if [[ -n ${2:-} ]]; then gameid=$2; echo "game id: $gameid (forced)"; return; fi
	fetch_db || { rp_warn "umu database unavailable, using $gameid"; return; }
	local cand; cand=$(mktemp)
	local out rc=0
	out=$(find_id find "$1" 2>"$cand") || rc=$?
	if (( rc == 0 )); then
		gameid=${out%%$'\t'*}; store=${out#*$'\t'}
		echo "game id: $gameid (store=$store, from umu-database)"
		rm -f "$cand"; return
	fi
	if (( rc == 2 )); then
		rp_warn "no umu-database entry for '$1' — using umu-default (no protonfixes)"
		rm -f "$cand"; return
	fi
	cat "$cand" >&2
	if [[ -t 0 ]]; then
		local ids; ids=$(grep -oP 'candidate: \K\S+' "$cand" | sort -u)
		local PS3='pick a number> ' pick
		select pick in umu-default $ids; do
			[[ -n ${pick:-} ]] || { echo "invalid choice"; continue; }
			if [[ $pick != umu-default ]]; then
				gameid=$pick
				store=$(grep -F "candidate: $pick " "$cand" | head -1 | grep -oP 'store=\K[^)]*' || echo none)
			fi
			break
		done
	else
		rp_warn "ambiguous matches — using umu-default; rerun with --gameid <id> if this is wrong"
	fi
	rm -f "$cand"
}
