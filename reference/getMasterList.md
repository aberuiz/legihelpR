# Return legiscan Master List

Returns a legiscan Master List for a specified session or the most
recent regular session if only state is provided

## Usage

``` r
getMasterList(session = NULL, state = NULL, legiKey = NULL)
```

## Arguments

- session:

  Session id integer value. Can be found with \`getSessions\`

- state:

  US state abbreviation

- legiKey:

  32 character string provided by legiscan

## Value

Master List in dataframe format

## Examples

``` r
getMasterList(session = 2108)
#> Error: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
getMasterList(state = "TX")
#> Error: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
```
