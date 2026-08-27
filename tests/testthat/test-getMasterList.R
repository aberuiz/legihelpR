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

test_that("master list requests prefer sessionID over state", {
  requests <- list()
  local_mocked_bindings(
    legiRequest = function(...){
      requests[[length(requests) + 1L]] <<- list(...)
      list(masterlist = list())
    },
    .package = "legihelpR"
  )

  getMasterList(sessionID = 1234, state = "TX", legiKey = fakeKey)
  getMasterListRaw(sessionID = 1234, state = "TX", legiKey = fakeKey)

  expect_length(requests, 2)
  expect_null(requests[[1]]$state)
  expect_null(requests[[2]]$state)
  expect_equal(requests[[1]]$id, 1234)
  expect_equal(requests[[2]]$id, 1234)
})
