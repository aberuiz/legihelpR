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
