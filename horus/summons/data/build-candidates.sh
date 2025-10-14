#!/usr/bin/env bash
set -euo pipefail

JSON_FILE="candidates.json"
OUT_FILE="candidates.csv"

cd "$(dirname "$0")"

if ! command -v jq >/dev/null 2>&1; then
  echo "Error: jq is required (sudo apt-get install -y jq)" >&2
  exit 1
fi

if [[ ! -f $JSON_FILE ]]; then
  echo "Missing $JSON_FILE" >&2
  exit 1
fi

trap 'rm -f "$OUT_FILE.tmp" 2>/dev/null || true' EXIT

# Header
printf '%s\n' 'title|first_names|surname|rank|date_of_birth|home_address|job_title|employer|employer_address|proposed_by_title|proposed_by_first_names|proposed_by_surname|proposed_by_rank|seconded_by_title|seconded_by_first_names|seconded_by_surname|seconded_by_rank|lodge_memberships|proposed_date' > "$OUT_FILE.tmp"

# Rows (use --arg for delimiter to avoid shell quoting issues)
jq -r --arg delim "; " '.[] | [
  .title,
  .first_names,
  .surname,
  (.rank // ""),
  .date_of_birth,
  .home_address,
  .job_title,
  .employer,
  .employer_address,
  .proposed_by.title,
  .proposed_by.first_names,
  .proposed_by.surname,
  (.proposed_by.rank // ""),
  .seconded_by.title,
  .seconded_by.first_names,
  .seconded_by.surname,
  (.seconded_by.rank // ""),
  (.lodge_memberships | join($delim)),
  .proposed_date
] | @tsv' "$JSON_FILE" | tr '\t' '|' >> "$OUT_FILE.tmp"

mv "$OUT_FILE.tmp" "$OUT_FILE"
trap - EXIT
echo "Wrote $OUT_FILE from $JSON_FILE"