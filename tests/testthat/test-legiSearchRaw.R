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

  test_that("legiSearchRaw stops at maxPages and reports remaining pages", {
    expect_message(
      expect_message(
        results <- legiSearchRaw(query = "pagetest", state = "MA", maxPages = 2, legiKey = fakeKey),
        "3 pages of results exist; stopped at page 2"
      ),
      "Results Found"
    )
    expect_equal(nrow(results), 4)
  })

  test_that("legiSearchRaw returns a zero-row data frame when nothing matches", {
    expect_warning(
      results <- legiSearchRaw(query = "nohits", state = "MA", legiKey = fakeKey),
      "No results found"
    )
    expect_s3_class(results, "data.frame")
    expect_equal(nrow(results), 0)
    expect_named(results, c("relevance", "bill_id", "change_hash"))
  })
})

test_that("legiSearchRaw validates query and pagination before any request", {
  without_internet({
    expect_error(
      legiSearchRaw(query = "", legiKey = fakeKey),
      "`query` must be a non-empty string"
    )
    expect_error(
      legiSearchRaw(query = "test", page = 1.5, legiKey = fakeKey),
      "`page` must be a positive whole number"
    )
    expect_error(
      legiSearchRaw(query = "test", maxPages = 0, legiKey = fakeKey),
      "`maxPages` must be a positive whole number or `Inf`"
    )
  })
})

test_that("session-scoped legiSearchRaw omits state and year filters", {
  requestArgs <- NULL
  local_mocked_bindings(
    legiRequest = function(...){
      requestArgs <<- list(...)
      list(searchresult = list())
    },
    .package = "legihelpR"
  )

  expect_warning(
    legiSearchRaw(
      query = "test",
      state = "TX",
      year = 2024,
      sessionID = 1234,
      legiKey = fakeKey
    ),
    "No results found"
  )
  expect_null(requestArgs$state)
  expect_null(requestArgs$year)
  expect_equal(requestArgs$id, 1234)
})
