with_mock_dir("fixtures", {
  test_that("getMonitorList returns the account monitor list as a dataframe", {
    monitored <- getMonitorList(legiKey = fakeKey)
    expect_s3_class(monitored, "data.frame")
  })
})
