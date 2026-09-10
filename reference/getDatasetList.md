# Return list of available datasets

Return a list of available datasets, available to filter by state and
year

## Usage

``` r
getDatasetList(state = NULL, year = NULL, legiKey = NULL)
```

## Arguments

- state:

  US state 2 character abbreviation

- year:

  4 year digit

- legiKey:

  32 character string provided by legiscan

## Value

A data frame (tibble) of available datasets and their download metadata.
Columns come from the API response. An empty dataset list returns zero
rows and zero columns.

## Examples

``` r
if (FALSE) { # \dontrun{
getDatasetList(state = "TX", year = 2023)
} # }
```
