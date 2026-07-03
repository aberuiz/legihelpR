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

Monitored bills with bill_id and change_hash in dataframe format

## Examples

``` r
if (FALSE) { # \dontrun{
getMonitorListRaw()
getMonitorListRaw(record = "archived")
} # }
```
