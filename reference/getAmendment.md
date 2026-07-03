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
if (FALSE) { # \dontrun{
getAmendment(amendmentID = 1234567)
} # }
```
