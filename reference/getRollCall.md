# Voting information for provided Roll Call

Return vote detail summary for provided Roll Call and a nested list of
individual votes

## Usage

``` r
getRollCall(rollCallID = NULL, legiKey = NULL)
```

## Arguments

- rollCallID:

  Roll Call ID integer

- legiKey:

  32 character string provided by legiscan

## Value

Summary of Vote and nested list of individual votes by people id

## Examples

``` r
if (FALSE) { # \dontrun{
getRollCall(rollCallID = 1361957)
} # }
```
