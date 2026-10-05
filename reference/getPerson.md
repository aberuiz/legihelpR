# Return record on Person

Return an individual record with basic information

## Usage

``` r
getPerson(peopleID = NULL, legiKey = NULL)
```

## Arguments

- peopleID:

  integer value from legiscan

- legiKey:

  32 character string provided by legiscan

## Value

A one-row data frame (tibble) containing the individual record. Columns
come from the API response. Nested fields such as `bio` are kept as list
columns, e.g. `person$bio[[1]]$social$email`.

## Examples

``` r
if (FALSE) { # \dontrun{
getPerson(peopleID = 5997)
} # }
```
