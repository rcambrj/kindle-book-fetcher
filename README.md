# Book Fetcher

KUAL extension for a jailbroken Kindle Paperwhite 1st gen. It manually fetches
ebook files from a simple HTTP directory listing and saves them to the Kindle
documents folder.

Supported file extensions:

- `.mobi`
- `.azw`
- `.azw3`

## Kindle Install

Copy the `extensions` directory to the Kindle over USB:

Open KUAL and choose:

```text
Book Fetcher -> Fetch books
```

Books are downloaded to the `documents` directory.

The script writes logs to stderr, `extensions/book-fetcher/fetch-books.log`, and a compact on-screen `eips` viewport when available.

## Server Setup

The server only needs a normal HTTP directory listing.

Apache example:

```apache
Options +Indexes
```

Nginx example:

```nginx
autoindex on;
```

## Configuration

Create `extensions/book-fetcher/settings.sh` on the Kindle, next to `fetch-books.sh`:

```sh
# Mandatory. Use a trailing slash.
BASE_URL="http://my-website.com/kindle-books/"
# Optional. Where the books will be downloaded. `/mnt/us` is the root which you see over USB
DOWNLOAD_DIR="/mnt/us/documents"
# Optional. Defaults to the directory containing fetch-books.sh.
LOG_FILE="/mnt/us/extensions/book-fetcher/fetch-books.log"
# Optional. Screen log settings.
SHOW_SCREEN=1
EIPS_LOG_COL=5
EIPS_LOG_ROW=15
EIPS_LOG_COLS=38
EIPS_LOG_ROWS=11
```

`settings.sh` is intentionally not included so local Kindle-specific settings do not need to be tracked.

The on-screen log uses the vertical middle third and the full safe text width centered for a Paperwhite 1. Full details go to stderr and remain in `fetch-books.log`.

## Filename Rules

Keep server filenames simple:

- Use ASCII names.
- Prefer letters, numbers, dots, dashes, and underscores.
- Avoid nested directories.
- Avoid query-string links or custom index pages.

The script decodes a few common URL escapes for local filenames, including `%20`, `%28`, `%29`, `%5B`, `%5D`, `%2C`, and `%27`.

## Why Not Recursive Wget?

Kindles commonly ship BusyBox `wget`, not GNU Wget. BusyBox `wget` is enough for direct downloads but does not reliably support GNU recursive options like `-r`, `-l`, `-A`, or `-nd`.

This extension fetches the generated directory listing, extracts matching ebook links, and downloads each file directly.
