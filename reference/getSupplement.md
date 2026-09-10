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

A list containing supplement document metadata and a base64 encoded
`doc` field. When `file` is supplied, the decoded content is written to
disk and `file` is returned invisibly instead of the list.

## Examples

``` r
if (FALSE) { # \dontrun{
getSupplement(supplementID = 1234567)
getSupplement(supplementID = 1234567, file = "supplement.pdf")
} # }
```
