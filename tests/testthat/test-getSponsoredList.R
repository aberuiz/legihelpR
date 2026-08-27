test_that("getSponsoredList reports documented session_name values", {
  local_mocked_bindings(
    legiRequest = function(...){
      list(
        sponsoredbills = list(
          sponsor = list(name = "Test Sponsor", district = "HD-001"),
          sessions = list(
            list(session_id = 2, session_name = "2025-2026 Regular Session"),
            list(session_id = 1, session_name = "2023-2024 Regular Session")
          ),
          bills = list(list(bill_id = 1234))
        )
      )
    },
    .package = "legihelpR"
  )

  expect_message(
    bills <- getSponsoredList(peopleID = 99, legiKey = fakeKey),
    "First Active: 2023-2024 Regular Session\\nLast Active: 2025-2026 Regular Session"
  )
  expect_equal(bills$bill_id, 1234)
})
