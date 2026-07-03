# legihelpR

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
#> # A tibble: 9 × 15
#>   session_id state_id state_abbr year_start year_end prefile sine_die prior
#>        <int>    <int> <chr>           <int>    <int>   <int>    <int> <int>
#> 1       2182       21 MA               2025     2026       0        0     0
#> 2       2026       21 MA               2023     2024       0        1     1
#> 3       1807       21 MA               2021     2022       0        1     1
#> 4       1637       21 MA               2019     2020       0        1     1
#> 5       1413       21 MA               2017     2018       0        1     1
#> 6       1134       21 MA               2015     2016       0        1     1
#> 7       1006       21 MA               2013     2014       0        1     1
#> 8         99       21 MA               2011     2012       0        1     1
#> 9         28       21 MA               2009     2010       0        1     1
#> # ℹ 7 more variables: special <int>, session_tag <chr>, session_title <chr>,
#> #   session_name <chr>, dataset_hash <chr>, session_hash <chr>, name <chr>
```

## Master List

For receiving a Master List from legiscan’s API you can use
`getMasterlist`. You can provide a unique session ID or you can provide
the state abbreviation to return the most recent regular session from
that state.

``` r

getMasterList(sessionID = 2108)
#> 88th Legislature 4th Special Session
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

To track a session over time without burning API quota, use
`getMasterListRaw` — it returns each bill’s `change_hash` so you can
detect which bills changed and re-fetch only those with `getBill`. See
the [change detection
vignette](https://aberuiz.github.io/legihelpR/articles/change-detection.html)
([`vignette("change-detection")`](https://aberuiz.github.io/legihelpR/articles/change-detection.md))
for the full workflow.

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
#> 108 Results Found
#> # A tibble: 108 × 11
#>    relevance state bill_number bill_id change_hash   url   text_url research_url
#>        <int> <chr> <chr>         <int> <chr>         <chr> <chr>    <chr>       
#>  1       100 TX    SB1455      1976056 ef4cd00a3f52… http… https:/… https://leg…
#>  2        99 TX    HB4483      2002338 e21037c74f19… http… https:/… https://leg…
#>  3        99 TX    SB2077      1994907 36b04ee1b8be… http… https:/… https://leg…
#>  4        99 TX    HB3914      1993351 b865bd54a9dd… http… https:/… https://leg…
#>  5        99 TX    HB4464      2000135 6420227e8d3c… http… https:/… https://leg…
#>  6        99 TX    HB5545      2008375 d47eb1a3432f… http… https:/… https://leg…
#>  7        99 TX    HB2488      1957337 dae9ad9cd064… http… https:/… https://leg…
#>  8        99 TX    HB4067      1994949 c24af9052b24… http… https:/… https://leg…
#>  9        98 TX    HB2414      1954268 a8b730069476… http… https:/… https://leg…
#> 10        98 TX    HB1667      1897368 f1068ef0e375… http… https:/… https://leg…
#> # ℹ 98 more rows
#> # ℹ 3 more variables: last_action_date <chr>, last_action <chr>, title <chr>
```

## Session People

Return a dataframe of basic information for people from the provided
session id.

``` r

getSessionPeople(sessionID = 2108)
#> 88th Legislature 4th Special Session
#> # A tibble: 537 × 24
#>    people_id person_hash party_id state_id party role_id role  name   first_name
#>        <int> <chr>       <chr>       <int> <chr>   <int> <chr> <chr>  <chr>     
#>  1      5848 3b040ho3    1              43 D           1 Rep   Alma … Alma      
#>  2      5848 3b040ho3    1              43 D           1 Rep   Alma … Alma      
#>  3      5848 3b040ho3    1              43 D           1 Rep   Alma … Alma      
#>  4      5850 mcnms1e8    1              43 D           2 Sen   Carol… Carol     
#>  5      5850 mcnms1e8    1              43 D           2 Sen   Carol… Carol     
#>  6      5850 mcnms1e8    1              43 D           2 Sen   Carol… Carol     
#>  7      5851 i5zt5f3s    1              43 D           1 Rep   Rafae… Rafael    
#>  8      5851 i5zt5f3s    1              43 D           1 Rep   Rafae… Rafael    
#>  9      5851 i5zt5f3s    1              43 D           1 Rep   Rafae… Rafael    
#> 10      5852 0iywahqt    2              43 R           1 Rep   Charl… Charles   
#> # ℹ 527 more rows
#> # ℹ 15 more variables: middle_name <chr>, last_name <chr>, suffix <chr>,
#> #   nickname <chr>, district <chr>, ftm_eid <int>, votesmart_id <int>,
#> #   opensecrets_id <chr>, knowwho_pid <int>, ballotpedia <chr>,
#> #   bioguide_id <chr>, committee_sponsor <int>, committee_id <int>,
#> #   state_federal <int>, bio <named list>
```

# Full API Coverage

legihelpR covers every operation in the legiscan Pull API:

| Area | Functions |
|----|----|
| Sessions & Bills | `getSessions`, `getMasterList`, `getMasterListRaw`, `getBill`, `getText`, `getAmendment`, `getSupplement`, `getRollCall` |
| People | `getPerson`, `getSessionPeople`, `getSponsoredList` |
| Search | `legiSearch`, `legiSearchRaw` |
| Datasets | `getDatasetList`, `getDataset`, `getDatasetRaw` |
| Monitoring | `getMonitorList`, `getMonitorListRaw`, `setMonitor` |

Last Update 07/03/26
