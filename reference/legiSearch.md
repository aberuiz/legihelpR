# Return search results from legiscan's database

Return search results from legiscan's database. Check legiscan.com for
specific search syntax for more details.

## Usage

``` r
legiSearch(
  query = NULL,
  state = "ALL",
  year = 2,
  session = NULL,
  page = 1,
  maxPages = 10,
  legiKey = NULL
)
```

## Arguments

- query:

  Enter your search text. Your query may use grammatically correct
  spacing. Use legiscan's search syntax for more powerful results.

- state:

  Search the entire nation by default with 'ALL' or specify state using
  letter abbreviations

- year:

  Should be an integer. 1=All, 2=Current, 3=Recent, 4=Prior,
  \>1900=Exact Year

- session:

  Limit search to specific session with a session_id

- page:

  Default is set to return Page 1. \`legiSearch\` will paginate and
  include results.

- maxPages:

  Maximum number of pages to fetch. Each page is one API query against
  your monthly quota. Use \`Inf\` to fetch every page.

- legiKey:

  32 character string provided by legiscan

## Value

Search results in dataframe format

## Examples

``` r
if (FALSE) { # \dontrun{
legiSearch(
  query = "action:yesterday AND 'workers compensation'",
  state = "TX"
)

legiSearch(
  query = "intro:month AND wage theft"
)
} # }
```
