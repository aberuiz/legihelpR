
# legihelpR

<!-- badges: start -->
<!-- badges: end -->

This R package, legihelpR, is meant to use the legiscan API to help
track legislative actions.

## Installation & Load

You can install the development version of legihelpR from
[GitHub](https://github.com/aberuiz/legihelpR) with:

``` r
# install.packages("remotes")
# remotes::install_github("aberuiz/legihelpR")
library(legihelpR)
```

## API Registration

Requests to legiscan require an API key to function. You can register
for an API key on the [legiscan
website](https://legiscan.com/user/register).

You can store your API key into your environment using `setlegiKey`. To
permanently store your legiscan API key in your environment use the
argument ‘install = TRUE’.

``` r
setlegiKey(
  APIkey = "< 32 character API Key >",
  install = TRUE
)
```

Once you have set up your API key all other legihelpR functions will use
`getlegiKey` to check your stored environment file by default. You can
use `getlegiKey` to check which API key you have stored. You can
overwrite your existing key by using ‘overwrite = TRUE’ in `setlegiKey`.

## Sessions

Receive a dataframe of all sessions in legiscan’s database using
`getSessions` to return unique Session IDs for the provided state.

``` r
getSessions(state = "MA")
#> # A tibble: 8 × 14
#>   session_id state_id year_start year_end prefile sine_die prior special
#>        <int>    <int>      <int>    <int>   <int>    <int> <int>   <int>
#> 1       2026       21       2023     2024       0        0     0       0
#> 2       1807       21       2021     2022       0        1     1       0
#> 3       1637       21       2019     2020       0        1     1       0
#> 4       1413       21       2017     2018       0        1     1       0
#> 5       1134       21       2015     2016       0        1     1       0
#> 6       1006       21       2013     2014       0        1     1       0
#> 7         99       21       2011     2012       0        1     1       0
#> 8         28       21       2009     2010       0        1     1       0
#> # ℹ 6 more variables: session_tag <chr>, session_title <chr>,
#> #   session_name <chr>, dataset_hash <chr>, session_hash <chr>, name <chr>
```

## Master List

For receiving a Master List from legiscan’s API you can use
`getMasterlist`. You can provide a unique session ID or you can provide
the state abbreviation to return the most recent regular session from
that state.

``` r
getMasterList(session = 2108)
#> [1] "88th Legislature 4th Special Session"
#> # A tibble: 399 × 10
#>    bill_id number change_hash          url   status_date status last_action_date
#>      <int> <chr>  <chr>                <chr> <chr>        <int> <chr>           
#>  1 1782999 HB1    a7dd8ab0cbac7f28afa… http… 2023-11-07       1 2023-11-17      
#>  2 1783170 HB2    4da362887d807b94bf0… http… 2023-11-20       2 2023-11-21      
#>  3 1783002 HB3    8056938ff2b255cc490… http… 2023-11-07       1 2023-11-10      
#>  4 1783007 HB4    17459d166806c526c46… http… 2023-11-07       1 2023-11-13      
#>  5 1783053 HB11   c74da0cc9f83206bd2d… http… 2023-11-07       1 2023-11-07      
#>  6 1783070 HB12   eed274a463bb592c254… http… 2023-11-07       1 2023-11-07      
#>  7 1783056 HB13   8aba11f7a402ff084d8… http… 2023-11-07       1 2023-11-07      
#>  8 1783054 HB14   a3f1a2e1372be27dde6… http… 2023-11-07       1 2023-11-07      
#>  9 1783060 HB15   54068d5092f6d5dbb10… http… 2023-11-07       1 2023-11-07      
#> 10 1783015 HB16   c3af43bf73d6302a2db… http… 2023-11-07       1 2023-11-07      
#> # ℹ 389 more rows
#> # ℹ 3 more variables: last_action <chr>, title <chr>, description <chr>
```

# In Development, In Order

    `legiSearch` = getSearch
    `getPerson` = getPerson
    `getMonitored` = getMonitorList
    `getBill` = getBill

Last Update 08/20/24