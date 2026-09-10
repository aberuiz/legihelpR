# Return associated monitor list

Return items from the monitor list from the account associated with the
legiKey provided

## Usage

``` r
getMonitorList(record = "current", legiKey = NULL)
```

## Arguments

- record:

  Record filter: "current" or "archived", or an exact year \>= 2010

- legiKey:

  32 character API key from legiscan

## Value

A data frame (tibble) of monitored bills. Columns come from the API
response. An empty monitor list returns zero rows and zero columns.

## Examples

``` r
if (FALSE) { # \dontrun{
getMonitorList()
getMonitorList(record = "archived")
} # }
```
