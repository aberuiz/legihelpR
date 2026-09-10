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

A data frame (tibble) of people active in the session, excluding session
metadata. Columns come from the API response. An empty people list
returns zero rows and zero columns.

## Examples

``` r
if (FALSE) { # \dontrun{
getSessionPeople(sessionID = 2160)
} # }
```
