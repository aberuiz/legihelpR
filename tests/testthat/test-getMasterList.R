test_that("getMasterList requires a session or a state", {
  without_internet({
    expect_error(getMasterList(), "Specify a Session or a State")
  })
})

test_that("getMasterListRaw requires a session or a state", {
  without_internet({
    expect_error(getMasterListRaw(), "Specify a Session or a State")
  })
})
