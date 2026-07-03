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

available datasets for download

## Examples

``` r
if (FALSE) { # \dontrun{
getDatasetList(state = "TX", year = 2023)
} # }
```
