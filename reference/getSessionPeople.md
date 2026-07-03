# People from specified session

Return a dataframe of people from the specified session

## Usage

``` r
getSessionPeople(session = NULL, legiKey = NULL)
```

## Arguments

- session:

  Session ID. Can be found with \`getSessions\`

- legiKey:

  32 character string provided by legiscan

## Examples

``` r
getSessionPeople(session = 2160)
#> Error: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
```
