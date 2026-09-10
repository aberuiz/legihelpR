# Return df of bills an individual has sponsored

Returns a dataframe of bills that an indiviual legislator has sponsored,
as specified using their people_id

## Usage

``` r
getSponsoredList(peopleID = NULL, legiKey = NULL)
```

## Arguments

- peopleID:

  People id integer value

- legiKey:

  32 character string provided by legiscan

## Value

A data frame (tibble) of sponsored bills, excluding sponsor and session
metadata. Columns come from the API response. An empty bill list returns
zero rows and zero columns.

## Examples

``` r
if (FALSE) { # \dontrun{
getSponsoredList(peopleID = 5997)
} # }
```
