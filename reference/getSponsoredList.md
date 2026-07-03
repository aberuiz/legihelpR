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
getSponsoredList(peopleID = 5997)
#> Warning: Invalid API Key:  Register <https://legiscan.com/user/register> Store with `setlegiKey`
#> [1] "Invalid API Key:  Register <https://legiscan.com/user/register> Store with `setlegiKey`"
```
