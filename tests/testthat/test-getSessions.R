with_mock_dir("fixtures", {
  test_that("getSessions returns a dataframe of session ids for a state", {
    sessions <- getSessions(state = "MA", legiKey = fakeKey)
    expect_s3_class(sessions, "data.frame")
    expect_gt(nrow(sessions), 0)
    expect_contains(names(sessions), c("session_id", "session_name", "year_start"))
  })
})
