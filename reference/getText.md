# Return bill text document

Return bill text document in base64 encoded format based on a text_id

## Usage

``` r
getText(textID = NULL, legiKey = NULL)
```

## Arguments

- textID:

  text_id integer value from bill object

- legiKey:

  32 character string provided by legiscan

## Value

Bill text document with metadata and base64 encoded document

## Examples

``` r
if (FALSE) { # \dontrun{
getText(textID = 1234567)
} # }
```
