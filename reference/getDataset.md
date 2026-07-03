# Download dataset archive

Return a base64 encoded ZIP archive of a specific dataset based on
session_id or access_key

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
getDataset(sessionID = 1234)
#> Warning: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
#> [1] "Invalid API Key: \nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"
getDataset(accessKey = "abc123def456")
#> Warning: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
#> [1] "Invalid API Key: \nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"
```
