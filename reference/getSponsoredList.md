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

Bills sponsored by a specified individual

## Examples

``` r
if (FALSE) { # \dontrun{
getSponsoredList(peopleID = 5997)
} # }
```
