# Return legiscan Master List for change detection

Returns a Master List of bill_id and change_hash values for a specified
session or the most recent regular session if only state is provided.
Optimized for detecting which bills have changed and need updating via
\`getBill\`.

## Usage

``` r
getMasterListRaw(sessionID = NULL, state = NULL, legiKey = NULL)
```

## Arguments

- sessionID:

  Session id integer value. Can be found with \`getSessions\`

- state:

  US state abbreviation. Ignored when \`sessionID\` is supplied

- legiKey:

  32 character string provided by legiscan

## Value

A data frame (tibble) of bill IDs and change hashes, excluding session
metadata. Nonempty results retain the API columns. An empty bill list
returns zero rows with integer `bill_id` and character `number` and
`change_hash` columns. Use [`nrow()`](https://rdrr.io/r/base/nrow.html)
to test whether there are any bills.

## Examples

``` r
if (FALSE) { # \dontrun{
getMasterListRaw(sessionID = 2108)
getMasterListRaw(state = "TX")
} # }
```
