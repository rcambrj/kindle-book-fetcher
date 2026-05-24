# Book Fetcher

KUAL extension for a jailbroken Kindle. It manually fetches ebook files from a
simple HTTP directory listing and saves them to the Kindle documents folder.

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

## Configuration

Create `extensions/book-fetcher/settings.sh` on the Kindle, next to `fetch-books.sh`:

```sh
# Mandatory. Use a trailing slash. Don't use HTTPS
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

The script logs to screen and to `fetch-books.log`.

## Filename Rules

Keep server filenames simple:

- Use ASCII names.
- Prefer letters, numbers, dots, dashes, and underscores.
- Avoid nested directories.
- Avoid query-string links or custom index pages.

### Hosting Suggestions

You could host a web page with nginx, Apache or similar on your own computer, or you could use a hosting providers. Here's a list of hosting providers which should allow directory listing (enabling the web page which lists all the files in a directory):

- [NearlyFreeSpeech.NET](https://www.nearlyfreespeech.net/)
- [HelioHost](https://heliohost.org/)
- [Freehosting.host](https://freehosting.host/)
- [InfinityFree](https://www.infinityfree.com/)
- [x10Hosting](https://x10hosting.com/)
- [AwardSpace](https://www.awardspace.com/)
- [ProFreeHost](https://profreehost.com/)

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