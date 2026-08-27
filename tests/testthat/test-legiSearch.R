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

test_that("legiSearch validates query and pagination before any request", {
  without_internet({
    expect_error(
      legiSearch(legiKey = fakeKey),
      "`query` must be a non-empty string"
    )
    expect_error(
      legiSearch(query = "test", page = 0, legiKey = fakeKey),
      "`page` must be a positive whole number"
    )
    expect_error(
      legiSearch(query = "test", maxPages = NA, legiKey = fakeKey),
      "`maxPages` must be a positive whole number or `Inf`"
    )
  })
})

test_that("session-scoped legiSearch omits state and year filters", {
  requestArgs <- NULL
  local_mocked_bindings(
    legiRequest = function(...){
      requestArgs <<- list(...)
      list(searchresult = list())
    },
    .package = "legihelpR"
  )

  expect_warning(
    legiSearch(
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
