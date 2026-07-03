# Return a specific bill

Return a specific bill based on a legiscan bill_id

## Usage

``` r
getBill(billID = NULL, legiKey = NULL)
```

## Arguments

- billID:

  bill_id integer value

- legiKey:

  32 character string provided by legiscan

## Value

Bill detail information including sponsors, history, texts, and roll
calls

## Examples

``` r
if (FALSE) { # \dontrun{
getBill(billID = 1633853)
} # }
```
