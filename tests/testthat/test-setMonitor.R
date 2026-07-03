# Validation only: setMonitor mutates the account tied to the API key, so no
# live request is ever made here. without_internet guarantees that.
test_that("setMonitor validates its inputs before any request", {
  without_internet({
    expect_error(
      setMonitor(action = "monitor"),
      "Specify one or more billIDs"
    )
    expect_error(
      setMonitor(billIDs = 12345),
      "action must be one of"
    )
    expect_error(
      setMonitor(billIDs = 12345, action = "delete"),
      "action must be one of"
    )
    expect_error(
      setMonitor(billIDs = 12345, action = "set", stance = "against"),
      "stance must be one of"
    )
  })
})
