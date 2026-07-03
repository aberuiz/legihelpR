# People from specified session

Return a dataframe of people from the specified session

## Usage

``` r
getSessionPeople(sessionID = NULL, legiKey = NULL)
```

## Arguments

- sessionID:

  Session ID. Can be found with \`getSessions\`

- legiKey:

  32 character string provided by legiscan

## Value

People active in the specified session in dataframe format

## Examples

``` r
if (FALSE) { # \dontrun{
getSessionPeople(sessionID = 2160)
} # }
```
