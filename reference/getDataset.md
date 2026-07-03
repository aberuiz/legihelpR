# Download dataset archive

Return a base64 encoded ZIP archive of a specific dataset based on
session_id and access_key

## Usage

``` r
getDataset(sessionID = NULL, accessKey = NULL, file = NULL, legiKey = NULL)
```

## Arguments

- sessionID:

  session_id integer value (use session_id from getDatasetList)

- accessKey:

  access_key string value (use access_key from getDatasetList)

- file:

  Optional file path to write the decoded ZIP archive to. When supplied,
  the base64 zip is decoded and saved to disk

- legiKey:

  32 character string provided by legiscan

## Value

Dataset archive with metadata and base64 encoded ZIP file, or the file
path invisibly when \`file\` is supplied

## Examples

``` r
if (FALSE) { # \dontrun{
getDataset(sessionID = 1234, accessKey = "abc123def456")
getDataset(sessionID = 1234, accessKey = "abc123def456", file = "dataset.zip")
} # }
```
