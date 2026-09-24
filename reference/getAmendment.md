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
  the base64 doc is decoded and saved to disk. The destination folder
  must already exist

- legiKey:

  32 character string provided by legiscan

## Value

A list containing amendment document metadata and a base64 encoded `doc`
field. When `file` is supplied, the decoded content is written to disk
and `file` is returned invisibly instead of the list.

## Examples

``` r
if (FALSE) { # \dontrun{
getAmendment(amendmentID = 1234567)
getAmendment(amendmentID = 1234567, file = "amendment.pdf")
} # }
```
