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

  US state abbreviation

- legiKey:

  32 character string provided by legiscan

## Value

Master List of bill_id and change_hash in dataframe format

## Examples

``` r
if (FALSE) { # \dontrun{
getMasterListRaw(sessionID = 2108)
getMasterListRaw(state = "TX")
} # }
```
