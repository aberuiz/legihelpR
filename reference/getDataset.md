# Download dataset archive

Return a base64 encoded ZIP archive of a specific dataset based on
session_id and access_key

## Usage

``` r
getDataset(
  sessionID = NULL,
  accessKey = NULL,
  file = NULL,
  legiKey = NULL,
  format = "json"
)
```

## Arguments

- sessionID:

  session_id integer value (use session_id from getDatasetList)

- accessKey:

  access_key string value (use access_key from getDatasetList)

- file:

  Optional file path to write the decoded ZIP archive to. When supplied,
  the base64 zip is decoded and saved to disk. The destination folder
  must already exist

- legiKey:

  32 character string provided by legiscan

- format:

  File format of the ZIP contents, either "json" or "csv"
  (case-insensitive)

## Value

A list containing dataset archive metadata and a base64 encoded `zip`
field. When `file` is supplied, the decoded content is written to disk
and `file` is returned invisibly instead of the list.

## Examples

``` r
if (FALSE) { # \dontrun{
getDataset(sessionID = 1234, accessKey = "abc123def456")
getDataset(sessionID = 1234, accessKey = "abc123def456", format = "csv", file = "dataset.zip")
} # }
```
