with_mock_dir("fixtures", {
  test_that("getBill returns bill detail for a bill_id", {
    expect_message(
      bill <- getBill(billID = 1633853, legiKey = fakeKey),
      "HB778"
    )
    expect_type(bill, "list")
    expect_equal(bill$bill_id, 1633853)
    expect_equal(bill$bill_number, "HB778")
    expect_equal(bill$state, "TX")
    expect_contains(names(bill), c("sponsors", "history", "texts"))
  })
})

test_that("getBill rejects a missing billID before any request", {
  without_internet({
    expect_error(
      getBill(legiKey = fakeKey),
      "`billID` is required"
    )
  })
})
