# getDataset requires BOTH a session_id and an access_key (issued together by
# getDatasetList). These checks confirm the guard fails locally when either is
# missing, so no malformed request is ever sent. without_internet enforces that.
test_that("getDataset requires both sessionID and accessKey before any request", {
  without_internet({
    expect_error(
      getDataset(legiKey = fakeKey),
      "Specify both a sessionID and accessKey"
    )
    expect_error(
      getDataset(sessionID = 1234, legiKey = fakeKey),
      "Specify both a sessionID and accessKey"
    )
    expect_error(
      getDataset(accessKey = "abc123def456", legiKey = fakeKey),
      "Specify both a sessionID and accessKey"
    )
  })
})

test_that("dataset functions validate format before any request", {
  without_internet({
    expect_error(
      getDataset(
        sessionID = 1234,
        accessKey = "abc123def456",
        format = "xml",
        legiKey = fakeKey
      ),
      "`format` must be either 'json' or 'csv'"
    )
    expect_error(
      getDatasetRaw(
        sessionID = 1234,
        accessKey = "abc123def456",
        format = NA_character_,
        legiKey = fakeKey
      ),
      "`format` must be either 'json' or 'csv'"
    )
  })
})

test_that("getDataset supports and normalizes the format parameter", {
  requestArgs <- NULL
  local_mocked_bindings(
    legiRequest = function(...){
      requestArgs <<- list(...)
      list(
        dataset = list(
          session_name = "Test Session",
          state_name = NULL,
          zip = ""
        )
      )
    },
    .package = "legihelpR"
  )

  expect_message(
    dataset <- getDataset(
      sessionID = 1234,
      accessKey = "abc123def456",
      format = "CSV",
      legiKey = fakeKey
    ),
    "Dataset: Test Session"
  )
  expect_equal(requestArgs$format, "csv")
  expect_equal(dataset$session_name, "Test Session")
})

test_that("getDatasetRaw normalizes format before downloading", {
  requestArgs <- NULL
  path <- withr::local_tempfile(fileext = ".zip")
  local_mocked_bindings(
    legiRequest = function(...){
      requestArgs <<- list(...)
      charToRaw("PK")
    },
    .package = "legihelpR"
  )

  expect_message(
    result <- getDatasetRaw(
      sessionID = 1234,
      accessKey = "abc123def456",
      format = "CSV",
      file = path,
      legiKey = fakeKey
    ),
    "Dataset saved to"
  )
  expect_equal(result, path)
  expect_equal(requestArgs$format, "csv")
  expect_identical(readBin(path, "raw", n = file.size(path)), charToRaw("PK"))
})
