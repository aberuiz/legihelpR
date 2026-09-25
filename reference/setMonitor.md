# Add or remove bills from the monitor list

Interact with GAITS to add or remove bills from the monitor list of the
account associated with the legiKey provided, or set a stance on
monitored bills

## Usage

``` r
setMonitor(billIDs = NULL, action = NULL, stance = "watch", legiKey = NULL)
```

## Arguments

- billIDs:

  One or more bill_id integer values to operate on

- action:

  Action to take on the bill list: "monitor", "remove", or "set"

- stance:

  Position on the bill: "watch", "support", or "oppose"

- legiKey:

  32 character API key from legiscan

## Value

A base data frame containing `bill_id` and `result` for returned bills.
Bill IDs are character strings taken from the response names; results
contain the API values for the requested action.

## Details

Because this changes the account, it is not retried after a network
failure or gateway error that may have reached LegiScan. See
[legihelpR-errors](https://aberuiz.github.io/legihelpR/reference/legihelpR-errors.md).

## Examples

``` r
if (FALSE) { # \dontrun{
setMonitor(billIDs = c(150334, 141690), action = "monitor")
setMonitor(billIDs = 1533377, action = "set", stance = "support")
} # }
```
