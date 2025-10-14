# Candidates Data Workflow

Maintain candidate details in `candidates.json` (structured & easier to edit). Generate the pipe‑delimited `candidates.csv` consumed by LaTeX before compiling the Summons.

## Files
- `candidates.json` – authoritative source (array of objects)
- `build-candidates.sh` – transforms JSON -> `candidates.csv`
- `candidates.csv` – generated (pipe `|` delimited) used by `\CandidatesTable`

## Add / Update a Candidate
1. Edit `candidates.json` – add a new object with required fields:
   - `title`, `first_names`, `surname`, `rank` (optional)
   - `date_of_birth` (DD/MM/YYYY)
   - `home_address`
   - `job_title`, `employer`, `employer_address`
   - `proposed_by` / `seconded_by` objects with: `title`, `first_names`, `surname`, `rank` (rank optional)
   - `lodge_memberships` (array of strings)
   - `proposed_date`

2. Run the build script (from this directory):
   ```bash
   ./build-candidates.sh
   ```
   Requires `jq` installed.

3. Recompile the summons LaTeX document. The new candidate(s) appear on the Candidates page.

## Notes
- The CSV uses `|` as a separator to avoid quoting addresses containing commas.
- Lodge memberships are joined with a semicolon+space `; `.
- The LaTeX macro prints: Name / DOB line, Address, Occupation + Employer sentence, Proposer/Seconder line, Memberships, Proposed date, and a horizontal rule.
- To suppress the horizontal rule after the final candidate, we could add a post‑processing hook—ask if you’d like that tweak.

## Troubleshooting
- If no candidates appear: ensure `candidates.csv` regenerated and contains at least one data row.
- If you see ZERO ROWS message, the separator or header likely mismatched. Re-run the script.
