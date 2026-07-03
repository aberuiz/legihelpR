with_mock_dir("fixtures", {
  test_that("getDatasetList returns available datasets for a state and year", {
    datasets <- getDatasetList(state = "TX", year = 2023, legiKey = fakeKey)
    expect_s3_class(datasets, "data.frame")
    expect_gt(nrow(datasets), 0)
    expect_contains(names(datasets), c("session_id", "access_key", "dataset_size"))
  })
})
