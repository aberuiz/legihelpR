# Return legislative session ids

Return a dataframe for all session ids of specified state in legiscan's
database

## Usage

``` r
getSessions(state = NULL, legiKey = NULL)
```

## Arguments

- state:

  US State abbreviation

- legiKey:

  32 character string provided by legiscan.com

## Value

A data frame (tibble) of legislative sessions. Columns come from the API
response. An empty session list returns zero rows and zero columns.

## Examples

``` r
if (FALSE) { # \dontrun{
getSessions(state = "MA")
} # }
```
