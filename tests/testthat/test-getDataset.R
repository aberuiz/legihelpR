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
