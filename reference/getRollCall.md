# Voting information for provided Roll Call

Return vote detail summary for provided Roll Call and a nested list of
individual votes

## Usage

``` r
getRollCall(RollCall = NULL, legiKey = NULL)
```

## Arguments

- RollCall:

  Roll Call ID integer

- legiKey:

  32 character string provided by legiscan

## Value

Summary of Vote and nested list of individual votes by people id

## Examples

``` r
getRollCall(RollCall = 1361957)
#> Warning: Invalid API Key: 
#> Register <https://legiscan.com/user/register>
#> Store with `setlegiKey`
#> [1] "Invalid API Key: \nRegister <https://legiscan.com/user/register>\nStore with `setlegiKey`"
```
