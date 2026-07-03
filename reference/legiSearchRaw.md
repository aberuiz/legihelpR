# Return raw search results from legiscan's database

Return search results from legiscan's full text engine with simplified
details, 2000 results at a time. Returns relevance, bill_id, and
change_hash only, appropriate for automated keyword monitoring. Check
legiscan.com for specific search syntax for more details.

## Usage

``` r
legiSearchRaw(
  query = NULL,
  state = "ALL",
  year = 2,
  session = NULL,
  page = 1,
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

  Default is set to return Page 1. \`legiSearchRaw\` will paginate and
  include results.

- legiKey:

  32 character string provided by legiscan

## Value

Search results with relevance, bill_id, and change_hash in dataframe
format

## Examples

``` r
if (FALSE) { # \dontrun{
legiSearchRaw(
  query = "intro:month AND wage theft",
  state = "TX"
)
} # }
```
