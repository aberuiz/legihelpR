# Set a legiscan api key

Every request requires a legiscan api key to be set in order to complete
a request.

## Usage

``` r
setlegiKey(APIkey, install = FALSE, overwrite = FALSE)
```

## Arguments

- APIkey:

  32 character string given to you by legiscan.com

- install:

  Store the key in your .Renviron file for use across sessions

- overwrite:

  Overwrite a previously installed key in your .Renviron file

## Value

Your legiscan API key is set for data requests
