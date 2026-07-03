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

Monitored bills in dataframe format

## Examples

``` r
if (FALSE) { # \dontrun{
getMonitorList()
getMonitorList(record = "archived")
} # }
```
