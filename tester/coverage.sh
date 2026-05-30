#!/bin/bash
# coverage.sh — Grov täckningsmätning för ett TADS3-projekt
#
# Extraherar metod-/funktionsnamn ur lib-filerna och kollar vilka
# som anropas (som namn följt av '(') i testfilerna.
# Ger en per-klass-rapport samt totalsummering.
#
# Användning: bash coverage.sh [--verbose] [LIB_DIR [TEST_DIR]]
#   LIB_DIR   katalog med *.t lib-filer  (default: skriptets ..lib/swedish)
#   TEST_DIR  katalog med *.t testfiler  (default: skriptets egen katalog)

set -euo pipefail

VERBOSE=0
ZERO=0
ARGS=()
for arg in "$@"; do
    [[ "$arg" == "--verbose" ]] && VERBOSE=1 \
    || [[ "$arg" == "--zero" ]] && ZERO=1 \
    || ARGS+=("$arg")
done

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LIB_DIR="${ARGS[0]:-$SCRIPT_DIR/../lib/swedish}"
TEST_DIR="${ARGS[1]:-$SCRIPT_DIR}"
TMPDIR_COV=$(mktemp -d)
trap 'rm -rf "$TMPDIR_COV"' EXIT

# ---------------------------------------------------------------------------
# Nyckelord och macros att exkludera
# ---------------------------------------------------------------------------

SKIP_RE='^(if|for|while|switch|foreach|else|return|try|catch|finally'
SKIP_RE+='|throw|new|local|inherited|delegated|defined'
SKIP_RE+='|dataType|dataTypeXlat|toString|tadsSay|tadsWrite'
SKIP_RE+='|forEachInstance|rexMatch|rexSearch|rexGroup|rexReplace'
SKIP_RE+='|objOfKind|say|setMethod|getMethod|valToList|getTokVal'
SKIP_RE+='|DefineIAction|DefineLangDir|DefineLiteralAction|DefineSystemAction'
SKIP_RE+='|DefineTAction|DefineTopicAction|DefMood|DefStance|VerbRule'
SKIP_RE+='|defDigit|defOrdinal|defTeen|defTens)$'

# ---------------------------------------------------------------------------
# 1. Extrahera Class.method-par från alla lib-filer
# ---------------------------------------------------------------------------

LIB_PAIRS="$TMPDIR_COV/lib_pairs.txt"
> "$LIB_PAIRS"

for f in "$LIB_DIR"/*.t; do
    awk -v skip="$SKIP_RE" '
    /^class [A-Za-z_]/ {
        line = $0; sub(/^class +/, "", line); sub(/[: ;].*/, "", line); ctx = line
    }
    /^modify [A-Za-z_]/ {
        line = $0; sub(/^modify +/, "", line); sub(/[ ;].*/, "", line)
        ctx = "modify:" line
    }
    /^[A-Za-z_][A-Za-z0-9_]*: / && !/^(class|modify)/ {
        line = $0; sub(/:.*/, "", line); ctx = line
    }
    # Metoder i klasser (4+ mellanslag)
    /^ {4,}[A-Za-z_][A-Za-z0-9_]* *\(/ {
        if ($0 ~ /^ *(\/\/|\/\*)/) next
        line = $0
        sub(/^ +/, "", line); sub(/\(.*/, "", line); gsub(/ /, "", line)
        if (line ~ skip) next
        if (ctx != "" && line != "") print ctx "." line
    }
    # Top-level funktioner (ej klass/modify-deklarationer)
    /^[A-Za-z_][A-Za-z0-9_]* *\(/ {
        if ($0 ~ /^\s*(\/\/|\/\*)/) next
        line = $0; sub(/\(.*/, "", line); gsub(/ /, "", line)
        if (line ~ skip) next
        if (line !~ /^(class|modify|object|function)$/) print "toplevel." line
    }
    ' "$f" >> "$LIB_PAIRS"
done

sort -u "$LIB_PAIRS" -o "$LIB_PAIRS"

# ---------------------------------------------------------------------------
# 2. Alla funktions-/metodanrop i testfilerna (namn följt av '(')
# ---------------------------------------------------------------------------

TEST_CALLS="$TMPDIR_COV/test_calls.txt"
grep -h -oE '[A-Za-z_][A-Za-z0-9_]+[[:space:]]*\(' "$TEST_DIR"/*.t | \
    sed 's/[( ]//g' | sort -u > "$TEST_CALLS"

# ---------------------------------------------------------------------------
# 3. Rapport
# ---------------------------------------------------------------------------

printf "\n%s\n" "======================================================================"
printf " Coverage-rapport — %s\n" "$(date '+%Y-%m-%d')"
printf " Lib: %s\n" "$LIB_DIR"
printf " Tester: %s/*.t\n" "$TEST_DIR"
printf "%s\n\n" "======================================================================"

TOTAL=0; COVERED=0

# Behandla par i sorterad ordning (per klass)
CUR_CLASS=""
CLASS_TOTAL=0; CLASS_COV=0
CLASS_MISSING=()

flush_class() {
    [ -z "$CUR_CLASS" ] && return
    local pct=0
    [ "$CLASS_TOTAL" -gt 0 ] && pct=$(( CLASS_COV * 100 / CLASS_TOTAL ))
    [ "$ZERO" -eq 1 ] && [ "$CLASS_COV" -gt 0 ] && return
    printf "  %-40s %3d/%-3d  (%d%%)\n" "$CUR_CLASS" "$CLASS_COV" "$CLASS_TOTAL" "$pct"
    if [ "${#CLASS_MISSING[@]}" -gt 0 ] && [ "$VERBOSE" -eq 1 -o "$CLASS_COV" -eq 0 ]; then
        for m in "${CLASS_MISSING[@]}"; do
            printf "      - %s\n" "$m"
        done
    elif [ "${#CLASS_MISSING[@]}" -gt 0 ] && [ "$VERBOSE" -eq 0 ]; then
        printf "      (--verbose för att se %d saknade)\n" "${#CLASS_MISSING[@]}"
    fi
}

while IFS= read -r pair; do
    cls="${pair%%.*}"
    method="${pair##*.}"

    if [ "$cls" != "$CUR_CLASS" ]; then
        flush_class
        CUR_CLASS="$cls"
        CLASS_TOTAL=0; CLASS_COV=0; CLASS_MISSING=()
    fi

    CLASS_TOTAL=$(( CLASS_TOTAL + 1 ))
    TOTAL=$(( TOTAL + 1 ))

    if grep -qxF "$method" "$TEST_CALLS" 2>/dev/null; then
        CLASS_COV=$(( CLASS_COV + 1 ))
        COVERED=$(( COVERED + 1 ))
    else
        CLASS_MISSING+=("$method")
    fi
done < "$LIB_PAIRS"
flush_class

printf "\n%s\n" "======================================================================"
printf " Totalt lib-metoder/funktioner: %d\n" "$TOTAL"
printf " Refererade i tester:           %d\n" "$COVERED"
printf " Ej refererade:                 %d\n" "$(( TOTAL - COVERED ))"
[ "$TOTAL" -gt 0 ] && printf " Täckning (namn-baserad):        %d%%\n" "$(( COVERED * 100 / TOTAL ))"
printf "%s\n\n" "======================================================================"
printf " OBS: Namn-baserad täckning — ett namn som förekommer i tester\n"
printf " räknas som täckt oavsett om alla grenar exekveras.\n"
printf " Kör med --verbose för att se alla saknade metoder per klass.\n"
printf " Kör med --zero för att bara visa klasser med 0%% täckning.\n\n"
