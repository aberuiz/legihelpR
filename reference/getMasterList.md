# Return legiscan Master List

Returns a legiscan Master List for a specified session or the most
recent regular session if only state is provided

## Usage

``` r
getMasterList(sessionID = NULL, state = NULL, legiKey = NULL)
```

## Arguments

- sessionID:

  Session id integer value. Can be found with \`getSessions\`

- state:

  US state abbreviation, 'DC', or 'US' for Congress (case-insensitive).
  Ignored when \`sessionID\` is supplied

- legiKey:

  32 character string provided by legiscan

## Value

A data frame (tibble) of bills, excluding session metadata. Columns come
from the API response. An empty bill list returns zero rows and zero
columns.

## Examples

``` r
if (FALSE) { # \dontrun{
getMasterList(sessionID = 2108)
getMasterList(state = "TX")
} # }
```
