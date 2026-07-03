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

Status of each bill_id and the action taken in dataframe format

## Examples

``` r
if (FALSE) { # \dontrun{
setMonitor(billIDs = c(150334, 141690), action = "monitor")
setMonitor(billIDs = 1533377, action = "set", stance = "support")
} # }
```
