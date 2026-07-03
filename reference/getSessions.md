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

A dataframe of all state legislative session ids

## Examples

``` r
getSessions(state = "MA")
#> Warning: Invalid API Key:  Register <https://legiscan.com/user/register> Store with `setlegiKey`
#> [1] "Invalid API Key:  Register <https://legiscan.com/user/register> Store with `setlegiKey`"
```
