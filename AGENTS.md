# Specification

## Goal

Provide a minimal KUAL extension that lets a user manually fetch ebooks from a known HTTP directory listing on a jailbroken Kindle Paperwhite 1st gen.

## Target Device

- Kindle Paperwhite 1st gen.
- Jailbroken.
- KUAL installed.
- BusyBox-style shell environment.

## KUAL Integration

The extension is installed at:

```text
/mnt/us/extensions/book-fetcher
```

Required KUAL files:

- `config.xml` registers the extension.
- `menu.json` defines the menu item.

KUAL action:

```text
./fetch-books.sh
```

KUAL runs actions with `/bin/ash` from the directory containing `menu.json`.

## Fetch Behavior

Default source URL:

```text
http://192.168.1.10:8000/kindle/
```

The URL must return a server-generated directory listing from Apache `Options +Indexes` or Nginx `autoindex on`.

The script must not require a manifest file.

The script must not depend on GNU Wget recursive features.

Allowed file extensions:

- `.mobi`
- `.azw`
- `.azw3`

Destination:

```text
/mnt/us/documents/Downloaded
```

## Parsing Rules

The first version supports a flat directory listing.

Accepted links:

- Relative links from `href="..."` or `href='...'`.
- Links whose path ends in `.mobi`, `.azw`, or `.azw3`, case-insensitive.

Rejected links:

- Parent directory links.
- Absolute paths.
- Absolute URLs.
- Nested paths containing `/`.
- Links with query strings or fragments.

## Kindle Feedback

The script logs to:

```text
/mnt/us/extensions/book-fetcher/fetch-books.log
```

If `eips` exists, the script also writes short status messages to the Kindle screen.

After downloads, if `lipc-set-prop` exists, the script requests a document rescan:

```sh
lipc-set-prop -- com.lab126.scanner doFullScan 1
```

## Non-Goals

- No daemon mode.
- No scheduled sync.
- No authentication.
- No recursive directory traversal.
- No dependency on Python, Bash, curl, GNU Wget, jq, or external packages.
