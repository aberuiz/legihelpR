# Return amendment document

Return amendment document in base64 encoded format based on an
amendment_id

## Usage

``` r
getAmendment(amendmentID = NULL, legiKey = NULL)
```

## Arguments

- amendmentID:

  amendment_id integer value from bill object

- legiKey:

  32 character string provided by legiscan

## Value

Amendment document with metadata and base64 encoded document

## Examples

``` r
getAmendment(amendmentID = 1234567)
#> Warning: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
#> [1] "Invalid API Key: \nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"
```
