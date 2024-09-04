
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

## legiSearch

Return a dataframe of search results from legiscan using the
`legiSearch` function. Reference [legiscan’s
documentation](https://legiscan.com/fulltext-search) for assistance with
additional search syntax. You can specify dates, status, type, & more
using legiscan’s search filters in the ‘query’ argument.

``` r
legiSearch(
  query = "workers compensation",
  state = "TX"
)
#> 126 Results Found
#> # A tibble: 126 × 11
#>    relevance state bill_number bill_id change_hash   url   text_url research_url
#>        <int> <chr> <chr>         <int> <chr>         <chr> <chr>    <chr>       
#>  1       100 TX    HB351       1632612 dd8a4d0ce42d… http… https:/… https://leg…
#>  2        99 TX    HB4389      1731515 0cead4ca815c… http… https:/… https://leg…
#>  3        99 TX    HB778       1633853 15f1b71b4aa3… http… https:/… https://leg…
#>  4        99 TX    HB3335      1726032 aa237860109e… http… https:/… https://leg…
#>  5        98 TX    HB4147      1730763 f0d956d2c38e… http… https:/… https://leg…
#>  6        98 TX    HB790       1634033 f24304e018fb… http… https:/… https://leg…
#>  7        98 TX    HB102       1632560 e63dc9a79415… http… https:/… https://leg…
#>  8        98 TX    HB2314      1706966 999038a29872… http… https:/… https://leg…
#>  9        98 TX    HB2702      1719196 41789a475d09… http… https:/… https://leg…
#> 10        98 TX    SB1776      1729262 9cf2c498fd6d… http… https:/… https://leg…
#> # ℹ 116 more rows
#> # ℹ 3 more variables: last_action_date <chr>, last_action <chr>, title <chr>
```

## Session People

Return a dataframe of basic information for people from the provided
session id.

``` r
getSessionPeople(session = 2108)
#> [1] "88th Legislature 4th Special Session"
#> # A tibble: 180 × 23
#>    people_id person_hash party_id state_id party role_id role  name   first_name
#>        <int> <chr>       <chr>       <int> <chr>   <int> <chr> <chr>  <chr>     
#>  1      5848 3b040ho3    1              43 D           1 Rep   Alma … Alma      
#>  2      5850 mcnms1e8    1              43 D           2 Sen   Carol… Carol     
#>  3      5851 i5zt5f3s    1              43 D           1 Rep   Rafae… Rafael    
#>  4      5852 0iywahqt    2              43 R           1 Rep   Charl… Charles   
#>  5      5862 2oz7ngk6    2              43 R           1 Rep   Angie… Angie     
#>  6      5874 afzjvlgk    2              43 R           1 Rep   Tom C… Tom       
#>  7      5875 d8zu56yg    2              43 R           2 Sen   Charl… Charles   
#>  8      5877 x0l0s73o    2              43 R           1 Rep   Drew … Drew      
#>  9      5879 gel8m81o    1              43 D           1 Rep   Yvonn… Yvonne    
#> 10      5884 1pzqjv8g    1              43 D           1 Rep   Harol… Harold    
#> # ℹ 170 more rows
#> # ℹ 14 more variables: middle_name <chr>, last_name <chr>, suffix <chr>,
#> #   nickname <chr>, district <chr>, ftm_eid <int>, votesmart_id <int>,
#> #   opensecrets_id <chr>, knowwho_pid <int>, ballotpedia <chr>,
#> #   bioguide_id <chr>, committee_sponsor <int>, committee_id <int>,
#> #   state_federal <int>
```

# Up Next, In Order

    getRollCall
    getAmendement
    getSupplement

Last Update 09/03/24
