# Return associated monitor list for change detection

Return bill_id and change_hash values from the monitor list of the
account associated with the legiKey provided. Optimized for detecting
which bills have changed and need updating via \`getBill\`.

## Usage

``` r
getMonitorListRaw(record = "current", legiKey = NULL)
```

## Arguments

- record:

  Record filter: "current" or "archived", or an exact year \>= 2010

- legiKey:

  32 character API key from legiscan

## Value

A data frame (tibble) of monitored bill IDs and change hashes. Nonempty
results retain the API columns. An empty monitor list returns zero rows
with integer `bill_id`, `stance`, and `status` columns and character
`state`, `number`, and `change_hash` columns. Use
[`nrow()`](https://rdrr.io/r/base/nrow.html) to test whether there are
any bills.

## Examples

``` r
if (FALSE) { # \dontrun{
getMonitorListRaw()
getMonitorListRaw(record = "archived")
} # }
```
