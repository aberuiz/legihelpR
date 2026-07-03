with_mock_dir("fixtures", {
  test_that("getRollCall returns vote detail for a roll call id", {
    expect_message(
      rollCall <- getRollCall(rollCallID = 1361957, legiKey = fakeKey)
    )
    expect_type(rollCall, "list")
    expect_equal(rollCall$roll_call_id, 1361957)
    expect_contains(names(rollCall), c("desc", "votes"))
    expect_equal(rollCall$yea + rollCall$nay + rollCall$nv + rollCall$absent, rollCall$total)
  })
})
