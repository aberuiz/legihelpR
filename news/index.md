# Changelog

## legihelpR (development version)

- Compatibility: empty
  [`getMasterListRaw()`](https://aberuiz.github.io/legihelpR/reference/getMasterListRaw.md)
  and
  [`getMonitorListRaw()`](https://aberuiz.github.io/legihelpR/reference/getMonitorListRaw.md)
  results now have typed columns matching their documented API fields,
  rather than zero columns. Use `nrow(x) == 0` to detect no bills;
  `length(x) == 0`, `ncol(x) == 0`, and column-presence checks no longer
  detect emptiness. Nonempty responses and API error handling are
  unchanged.

- Vignette API examples are explicitly unevaluated so extracted code
  does not make live requests during package checks.

- `setlegiKey(install = TRUE)` now separates the new assignment from an
  existing final line without a newline, preserving existing settings
  and ensuring the key is not swallowed by a comment.

- Search functions now collect pages before combining results, avoiding
  repeated copies of previously fetched rows while preserving result
  order and columns.

- Search functions now validate `query`, `page`, and `maxPages` before
  making quota-consuming requests, and session-scoped searches omit
  incompatible state and year filters.

- [`getDataset()`](https://aberuiz.github.io/legihelpR/reference/getDataset.md)
  now supports LegiScan’s `format` parameter; both dataset download
  functions accept `json` or `csv` case-insensitively and reject invalid
  formats before making a request.

- API response and key validation now handle malformed values cleanly
  without including a supplied key in error logs.

- [`setlegiKey()`](https://aberuiz.github.io/legihelpR/reference/setlegiKey.md)
  matches only actual `legiKey=` entries in `.Renviron`, checks setup
  and backup failures, and safely quotes the stored value.

- Document and sponsored-session messages now use fields present in
  LegiScan’s documented response schema.

- [`getDatasetRaw()`](https://aberuiz.github.io/legihelpR/reference/getDatasetRaw.md)
  now takes `format` after `legiKey`, matching the argument order of
  [`getDataset()`](https://aberuiz.github.io/legihelpR/reference/getDataset.md).
  Positional calls that passed `format` third must be updated to name
  the argument.

- Internal request building no longer uses R’s native pipe. This is a
  style change only: `httr2` and `dplyr` both require R \>= 4.1, so the
  package’s effective minimum R version is unchanged.

- Expanded offline regression coverage and declared the testthat version
  used by the test helpers.

## legihelpR 0.3.2

- [`legiSearch()`](https://aberuiz.github.io/legihelpR/reference/legiSearch.md)
  and
  [`legiSearchRaw()`](https://aberuiz.github.io/legihelpR/reference/legiSearchRaw.md)
  now return a zero-row data frame with the documented columns, instead
  of `NULL`, when a search matches nothing. The “No results found”
  warning is unchanged. Downstream code can call
  [`nrow()`](https://rdrr.io/r/base/nrow.html), select columns, or bind
  results without special-casing empty searches; existing
  [`is.null()`](https://rdrr.io/r/base/NULL.html) guards will no longer
  trigger.
- `maxPages` in
  [`legiSearch()`](https://aberuiz.github.io/legihelpR/reference/legiSearch.md)
  and
  [`legiSearchRaw()`](https://aberuiz.github.io/legihelpR/reference/legiSearchRaw.md)
  now caps the number of pages fetched, as documented, rather than
  acting as a maximum page number. Behavior only changes when paginating
  from a custom starting `page` \> 1.
- [`legiSearchRaw()`](https://aberuiz.github.io/legihelpR/reference/legiSearchRaw.md)
  no longer errors (“argument is of length zero”) when a response
  arrives without a `summary$page_total`; it stops paginating and
  returns what it collected.
- [`legiSearch()`](https://aberuiz.github.io/legihelpR/reference/legiSearch.md)
  drops the `summary` block from responses by name rather than by
  position, matching
  [`getMasterList()`](https://aberuiz.github.io/legihelpR/reference/getMasterList.md),
  so a reordered response can never silently discard a result row.
- [`legiSearch()`](https://aberuiz.github.io/legihelpR/reference/legiSearch.md)
  uses `summary$page_total` to detect the final page instead of the
  “fewer than 50 rows” heuristic, which spent one extra API query
  whenever the result count was an exact multiple of the page size.
- [`getMasterList()`](https://aberuiz.github.io/legihelpR/reference/getMasterList.md)
  no longer emits a blank message when a response has no `session`
  block.
- `DESCRIPTION` now declares the required `httr2 (>= 1.1.0)` and drops
  the unused `LazyData` field.

## legihelpR 0.3.1

- Renamed function arguments to a consistent camelCase ID convention
  (e.g. `billID`, `sessionID`, `peopleID`, `legiKey`).
- Document functions
  ([`getText()`](https://aberuiz.github.io/legihelpR/reference/getText.md),
  [`getAmendment()`](https://aberuiz.github.io/legihelpR/reference/getAmendment.md),
  [`getSupplement()`](https://aberuiz.github.io/legihelpR/reference/getSupplement.md),
  [`getDataset()`](https://aberuiz.github.io/legihelpR/reference/getDataset.md))
  gained a `file` argument to decode base64 documents to disk.
- Search pagination is capped with `maxPages` (default 10) to protect
  API quota; use `Inf` to fetch every page.
- Added a change-detection vignette.
