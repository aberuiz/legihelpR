test_that("legiRequest rejects a malformed API key before any request", {
  without_internet({
    expect_error(
      getSessions(state = "MA", legiKey = "tooshort"),
      "Invalid API Key"
    )
  })
})

test_that("legiRequest rejects a missing API key before any request", {
  withr::local_envvar(legiKey = "")
  without_internet({
    expect_error(
      getSessions(state = "MA"),
      "Invalid API Key"
    )
  })
})

with_mock_dir("fixtures", {
  test_that("legiRequest turns a status ERROR response into an R error", {
    expect_error(
      getBill(billID = 0, legiKey = fakeKey),
      "API returned error"
    )
  })
})

test_that("request slots are spaced by the configured interval", {
  withr::local_options(legihelpR.request_interval = 10)
  withr::defer(pacer$lastRequest <- -Inf)
  pacer$lastRequest <- -Inf

  expect_equal(reserveRequestSlot(), 0)
  expect_equal(reserveRequestSlot(), 10, tolerance = 0.1)
  # A retry delay longer than the interval wins over the spacing.
  expect_equal(reserveRequestSlot(25), 25, tolerance = 0.1)
  expect_equal(reserveRequestSlot(), 35, tolerance = 0.1)
})

test_that("an invalid request interval errors", {
  withr::local_options(legihelpR.request_interval = -1)
  expect_error(reserveRequestSlot(), "request_interval")
})
