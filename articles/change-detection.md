# Detecting Bill Changes with change_hash

``` r

library(legihelpR)
```

If you track a legislative session over time, the naive approach —
re-fetching every bill you care about on a schedule — burns through your
LegiScan quota (30,000 queries/month) fast. A session with 5,000 bills
polled daily is 150,000 queries a month before you’ve done anything
useful.

LegiScan’s API is built for a cheaper pattern, described in the API
manual’s *Update Workflow* section: every bill record carries a
`change_hash` that changes whenever anything about the bill changes.
`getMasterListRaw` returns the `bill_id` and `change_hash` for an entire
session in a **single query**. By keeping the hashes from your last
check and comparing, you can identify exactly which bills changed and
re-fetch only those with `getBill`.

The daily cost becomes: 1 query for the master list + 1 query per bill
that actually changed. For most sessions on most days, that’s a handful
of queries instead of thousands.

## Step 1 — Establish a baseline

Pull the raw master list for the session you’re tracking (find session
IDs with `getSessions`) and store it locally. `saveRDS` is the simplest
store; a database table works the same way if you’re already using one.

``` r

sessionID <- 2108

baseline <- getMasterListRaw(sessionID = sessionID)

saveRDS(baseline, "bill_hashes.rds")
```

If you want the full bill detail up front — not just the hashes — you
can bulk-load the session once from a weekly dataset archive instead.
`getDatasetList` shows what’s available and `getDataset(file = ...)`
writes the ZIP of JSON bill records to disk. The archive costs one query
no matter how many bills the session has.

``` r

datasets <- getDatasetList(state = "TX")

getDataset(
  sessionID = datasets$session_id[1],
  accessKey = datasets$access_key[1],
  file = "session_archive.zip"
)
```

## Step 2 — Check for changes

On whatever schedule suits you (daily is typical), fetch the master list
again — one query — and join it against the stored hashes. Three cases
fall out: new bills, changed bills, and (rarely) bills that dropped off
the list.

``` r

stored <- readRDS("bill_hashes.rds")
current <- getMasterListRaw(sessionID = sessionID)

comparison <- current |>
  dplyr::left_join(
    stored |> dplyr::select(bill_id, old_hash = change_hash),
    by = "bill_id"
  )

newBills <- comparison |> dplyr::filter(is.na(old_hash))
changedBills <- comparison |> dplyr::filter(!is.na(old_hash), change_hash != old_hash)

message(nrow(newBills), " new, ", nrow(changedBills), " changed")
```

## Step 3 — Re-fetch only what changed

Each changed or new bill costs one `getBill` query. On a quiet day this
loop does nothing at all.

``` r

toFetch <- c(newBills$bill_id, changedBills$bill_id)

updatedBills <- lapply(toFetch, \(id) getBill(billID = id))
```

`getBill` returns the full bill record — status, progress, sponsors,
votes, and document metadata — so whatever you store downstream can be
refreshed from it. If you also archive bill text, the record’s `texts`
element carries a `doc_id` for each version; pass it to
`getText(textID = ..., file = ...)` to write the document to disk.

## Step 4 — Save the new baseline

Overwrite the stored hashes so the next run diffs against today.

``` r

saveRDS(current, "bill_hashes.rds")
```

## Variation: keyword monitoring across states

If you’re tracking a topic rather than a session, `legiSearchRaw`
returns `bill_id` and `change_hash` for search results — the same diff
pattern applies. Store the hashes from your last search, re-run the
search on a schedule, and `getBill` only the hits that are new or
changed.

``` r

hits <- legiSearchRaw(query = "wage theft", state = "TX")
```

Each page of search results is one query; `legiSearchRaw` paginates
automatically up to `maxPages`.
