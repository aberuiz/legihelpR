# Download dataset archive

Return a base64 encoded ZIP archive of a specific dataset based on
session_id and access_key

## Usage

``` r
getDataset(sessionID = NULL, accessKey = NULL, legiKey = NULL)
```

## Arguments

- sessionID:

  session_id integer value (use session_id from getDatasetList)

- accessKey:

  access_key string value (use access_key from getDatasetList)

- legiKey:

  32 character string provided by legiscan

## Value

Dataset archive with metadata and base64 encoded ZIP file

## Examples

``` r
if (FALSE) { # \dontrun{
getDataset(sessionID = 1234, accessKey = "abc123def456")
} # }
```
