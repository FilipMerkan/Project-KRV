# Project Submission - Slovenian zxcvbn Extension

## Contents

This submission includes:
- `main.pdf` - Project report
- `demo.html` - Interactive demo application
- `zxcvbn/` - Enhanced zxcvbn library with Slovenian support

## Running the Demo

1. **Start a local web server** from the directory containing `demo.html`:
   ```bash
   python3 -m http.server 8000
   ```

2. **Open in your browser**:
   ```
   http://localhost:8000/demo.html
   ```

3. **Note**: The demo requires an internet connection to load the original zxcvbn from CDN for comparison.

## What the Demo Shows

The demo provides a side-by-side comparison of:
- **Left side**: Original zxcvbn (English only)
- **Right side**: Slovenian-enhanced zxcvbn

### Example Passwords to Try

The demo includes example buttons for passwords mentioned in the report:
- **Words & Names**: geslo123, ljubljana2024, filipmerkan, slovenija, slovenija2024, geslo2024
- **Keyboard Patterns**: qwertz, asdfgh, yxcvbn
- **Dates & Leet Speak**: 25.06.1991, sl0v3n1j4

### Features

- Real-time password strength analysis
- Dictionary match detection (shows which dictionaries detected patterns)
- Language selector for feedback (English/Slovenian)
- Detailed metrics (score, guesses, crack times)

## Project Structure

```
.
├── demo.html             # Demo application
├── zxcvbn/               # Enhanced zxcvbn library
│   ├── dist/
│   │   └── zxcvbn.js     # Built library with Slovenian support
│   ├── src/              # Source code (CoffeeScript)
│   └── data/             # Frequency lists
├── main.pdf              # Project report
└── README.md             # This document
```

## Technical Details

The enhanced zxcvbn includes:
- 30,000 Slovenian words from text collections
- 4,902 Slovenian male names
- 4,861 Slovenian female names
- 33,493 Slovenian surnames
- 30,000 common Slovenian passwords
- QWERTZ keyboard layout support
- Slovenian date format recognition (DD.MM.YYYY)
- Localized feedback in Slovenian

## Requirements

- Python 3 (for http.server)
- Modern web browser with JavaScript enabled
- Internet connection (for loading original zxcvbn from CDN)
