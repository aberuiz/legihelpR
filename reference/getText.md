# Return bill text document

Return bill text document in base64 encoded format based on a text_id

## Usage

``` r
getText(textID = NULL, file = NULL, legiKey = NULL)
```

## Arguments

- textID:

  text_id integer value from bill object

- file:

  Optional file path to write the decoded document to. When supplied,
  the base64 doc is decoded and saved to disk

- legiKey:

  32 character string provided by legiscan

## Value

Bill text document with metadata and base64 encoded document, or the
file path invisibly when \`file\` is supplied

## Examples

``` r
if (FALSE) { # \dontrun{
getText(textID = 1234567)
getText(textID = 1234567, file = "bill_text.html")
} # }
```
