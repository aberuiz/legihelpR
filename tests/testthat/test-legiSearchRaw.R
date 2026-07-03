with_mock_dir("fixtures", {
  test_that("legiSearchRaw returns bill_id and change_hash search results", {
    expect_message(
      results <- legiSearchRaw(query = "wage theft", state = "MA", legiKey = fakeKey),
      "Results Found"
    )
    expect_s3_class(results, "data.frame")
    expect_gt(nrow(results), 0)
    expect_contains(names(results), c("bill_id", "change_hash", "relevance"))
  })
})
