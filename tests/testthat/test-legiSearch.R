with_mock_dir("fixtures", {
  test_that("legiSearch stops fetching at maxPages", {
    expect_message(
      expect_message(
        results <- legiSearch(query = "pagetest", state = "MA", maxPages = 2, legiKey = fakeKey),
        "Stopped at page 2"
      ),
      "Results Found"
    )
    expect_s3_class(results, "data.frame")
    expect_equal(nrow(results), 100)
    expect_contains(names(results), c("bill_id", "bill_number", "title"))
  })

  test_that("legiSearch returns a zero-row data frame when nothing matches", {
    expect_warning(
      results <- legiSearch(query = "nohits", state = "MA", legiKey = fakeKey),
      "No results found"
    )
    expect_s3_class(results, "data.frame")
    expect_equal(nrow(results), 0)
    expect_contains(names(results), c("bill_id", "bill_number", "title", "change_hash"))
  })
})
