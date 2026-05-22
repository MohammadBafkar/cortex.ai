#!/usr/bin/env bash
# cas.sh — write/read content-addressed artifacts.
#
# Usage:
#   cas.sh put <file>               -> prints SHA-256 id (hex)
#   cas.sh get <id>                 -> writes content to stdout
#   cas.sh put-ref <name> <id>      -> writes mutable reference
#   cas.sh resolve <name>           -> resolves mutable reference to id
#   cas.sh list-refs                -> prints all known references
#
# Storage layout (default $HOME/.claude-plugin/cas/):
#   objects/<sha256>      content-addressed immutable blobs
#   refs/<name>           single-line file containing the current id
#
# CAS_ROOT env var overrides the default location (used in tests).

set -euo pipefail

CAS_ROOT="${CAS_ROOT:-$HOME/.claude-plugin/cas}"
mkdir -p "$CAS_ROOT/objects" "$CAS_ROOT/refs"

usage() {
  sed -n '2,15p' "$0" | sed 's/^# \{0,1\}//'
  exit 2
}

sha256() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$1" | awk '{print $1}'
  else
    echo "cas.sh: neither sha256sum nor shasum available" >&2
    exit 1
  fi
}

cmd="${1:-}"
case "$cmd" in
  put)
    [[ $# -ge 2 ]] || usage
    src="$2"
    [[ -f "$src" ]] || { echo "cas.sh: file not found: $src" >&2; exit 1; }
    id="$(sha256 "$src")"
    dest="$CAS_ROOT/objects/$id"
    if [[ ! -f "$dest" ]]; then
      cp "$src" "$dest"
    fi
    echo "$id"
    ;;
  get)
    [[ $# -ge 2 ]] || usage
    id="$2"
    src="$CAS_ROOT/objects/$id"
    [[ -f "$src" ]] || { echo "cas.sh: object not found: $id" >&2; exit 1; }
    cat "$src"
    ;;
  put-ref)
    [[ $# -ge 3 ]] || usage
    name="$2"
    id="$3"
    [[ -f "$CAS_ROOT/objects/$id" ]] || { echo "cas.sh: object not found: $id" >&2; exit 1; }
    printf '%s\n' "$id" > "$CAS_ROOT/refs/$name"
    echo "$name -> $id"
    ;;
  resolve)
    [[ $# -ge 2 ]] || usage
    name="$2"
    ref="$CAS_ROOT/refs/$name"
    [[ -f "$ref" ]] || { echo "cas.sh: ref not found: $name" >&2; exit 1; }
    cat "$ref"
    ;;
  list-refs)
    if [[ -d "$CAS_ROOT/refs" ]]; then
      for f in "$CAS_ROOT/refs"/*; do
        [[ -f "$f" ]] || continue
        printf '%s\t%s\n' "$(basename "$f")" "$(cat "$f")"
      done
    fi
    ;;
  ""|-h|--help)
    usage
    ;;
  *)
    echo "cas.sh: unknown command: $cmd" >&2
    usage
    ;;
esac
