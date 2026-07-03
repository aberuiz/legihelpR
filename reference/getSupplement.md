# Return supplement document

Return supplement document in base64 encoded format based on a
supplement_id

## Usage

``` r
getSupplement(supplementID = NULL, legiKey = NULL)
```

## Arguments

- supplementID:

  supplement_id integer value from bill object

- legiKey:

  32 character string provided by legiscan

## Value

Supplement document with metadata and base64 encoded document

## Examples

``` r
getSupplement(supplementID = 1234567)
#> Error: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
```
