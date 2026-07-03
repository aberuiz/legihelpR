# Return supplement document

Return supplement document in base64 encoded format based on a
supplement_id

## Usage

``` r
getSupplement(supplementID = NULL, file = NULL, legiKey = NULL)
```

## Arguments

- supplementID:

  supplement_id integer value from bill object

- file:

  Optional file path to write the decoded document to. When supplied,
  the base64 doc is decoded and saved to disk

- legiKey:

  32 character string provided by legiscan

## Value

Supplement document with metadata and base64 encoded document, or the
file path invisibly when \`file\` is supplied

## Examples

``` r
if (FALSE) { # \dontrun{
getSupplement(supplementID = 1234567)
getSupplement(supplementID = 1234567, file = "supplement.pdf")
} # }
```
