# Return amendment document

Return amendment document in base64 encoded format based on an
amendment_id

## Usage

``` r
getAmendment(amendmentID = NULL, file = NULL, legiKey = NULL)
```

## Arguments

- amendmentID:

  amendment_id integer value from bill object

- file:

  Optional file path to write the decoded document to. When supplied,
  the base64 doc is decoded and saved to disk

- legiKey:

  32 character string provided by legiscan

## Value

Amendment document with metadata and base64 encoded document, or the
file path invisibly when \`file\` is supplied

## Examples

``` r
if (FALSE) { # \dontrun{
getAmendment(amendmentID = 1234567)
getAmendment(amendmentID = 1234567, file = "amendment.pdf")
} # }
```
