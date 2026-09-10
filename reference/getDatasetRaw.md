# Download dataset archive as a ZIP file

Download a specific dataset as a binary ZIP archive written directly to
disk, containing all bills, votes, and people data for the specified
session

## Usage

``` r
getDatasetRaw(
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

  File path to write the ZIP archive to. Defaults to
  legiscan_dataset\_\<sessionID\>.zip in the working directory

- legiKey:

  32 character string provided by legiscan

- format:

  File format of the ZIP contents, either "json" or "csv"
  (case-insensitive)

## Value

The path of the downloaded ZIP archive as a character string, returned
invisibly. The archive is written to disk.

## Examples

``` r
if (FALSE) { # \dontrun{
getDatasetRaw(sessionID = 1234, accessKey = "abc123def456")
getDatasetRaw(sessionID = 1234, accessKey = "abc123def456", format = "csv")
} # }
```
