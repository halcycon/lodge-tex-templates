# Data Files for Horus Template

This directory contains example data files that demonstrate the expected CSV format for the Horus summons template.

## File Descriptions

### officers.csv
Contains current lodge officers with their roles and contact information.

**Columns:**
- `role`: Officer position (e.g., "Worshipful Master", "Senior Warden", "Secretary")
- `name`: Full name with post-nominals
- `email`: Email address
- `phone`: Phone number

**Example:**
```csv
role,name,email,phone
Worshipful Master,W. Bro. John Smith,wm@example.com,555-0101
Senior Warden,Bro. James Brown,sw@example.com,555-0102
Junior Warden,Bro. Robert Jones,jw@example.com,555-0103
```

### meetings.csv
Lists meeting schedule with dates, times, and venues.

**Columns:**
- `meeting_number`: Sequential meeting identifier (e.g., "0344")
- `meeting_date`: Date of meeting (format: "1st January 2025")
- `tyling`: Time meeting begins (e.g., "6:30 PM")
- `venue`: Location name
- `notes`: Optional additional information

**Example:**
```csv
meeting_number,meeting_date,tyling,venue,notes
0344,15th January 2025,6:30 PM,Grand Temple,Regular Meeting
0345,19th February 2025,6:30 PM,Grand Temple,Installation
```

### past_masters.csv
Historical record of Past Masters.

**Columns:**
- `year`: Year served as Worshipful Master
- `name`: Full name with post-nominals

**Example:**
```csv
year,name
2024,W. Bro. David Wilson PAGDC
2023,W. Bro. Michael Taylor
2022,W. Bro. Christopher Davis
```

### honorary_members.csv
List of honorary members with their affiliations.

**Columns:**
- `name`: Full name with post-nominals and affiliations

**Example:**
```csv
name
R.W. Bro. Thomas Anderson PSGW
V.W. Bro. Richard Martinez PGStdB
W. Bro. Charles Garcia
```

## Usage

1. Copy these example files to your working directory (e.g., `horus/data/`)
2. Remove the `.example` extension
3. Replace the example data with your lodge's actual information
4. Ensure CSV formatting is preserved (use quotes for fields containing commas)
5. Use UTF-8 encoding for all CSV files

## Privacy Note

**Never commit actual member data to version control.** The working directory containing real CSV data should be excluded via `.gitignore`. These example files demonstrate format only and contain no real personal information.
