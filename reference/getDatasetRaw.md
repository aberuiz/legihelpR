# Download dataset archive as a ZIP file

Download a specific dataset as a binary ZIP archive written directly to
disk, containing all bills, votes, and people data for the specified
session

## Usage

``` r
getDatasetRaw(
  sessionID = NULL,
  accessKey = NULL,
  format = "json",
  file = NULL,
  legiKey = NULL
)
```

## Arguments

- sessionID:

  session_id integer value (use session_id from getDatasetList)

- accessKey:

  access_key string value (use access_key from getDatasetList)

- format:

  File format of the ZIP contents, either "json" or "csv"

- file:

  File path to write the ZIP archive to. Defaults to
  legiscan_dataset\_\<sessionID\>.zip in the working directory

- legiKey:

  32 character string provided by legiscan

## Value

File path of the downloaded ZIP archive, invisibly

## Examples

``` r
if (FALSE) { # \dontrun{
getDatasetRaw(sessionID = 1234, accessKey = "abc123def456")
getDatasetRaw(sessionID = 1234, accessKey = "abc123def456", format = "csv")
} # }
```
