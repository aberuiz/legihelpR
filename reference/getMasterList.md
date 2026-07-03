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
if (FALSE) { # \dontrun{
getMasterList(session = 2108)
getMasterList(state = "TX")
} # }
```
