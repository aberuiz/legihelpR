# Synthetic JSON follows the response examples in the LegiScan API manual
# (getMasterListRaw and getMonitorListRaw), with an extra field to verify passthrough.
rawListResponse <- function(body){
  httr2::response(
    200,
    headers = list("content-type" = "application/json"),
    body = charToRaw(body)
  )
}

test_that("raw list empty results support selection, joins, and row binding", {
  for (op in c("getMasterListRaw", "getMonitorListRaw")){
    master <- op == "getMasterListRaw"
    payload <- if (master) "masterlist" else "monitorlist"
    fetch <- if (master) function() getMasterListRaw(sessionID = 1234, legiKey = fakeKey) else
      function() getMonitorListRaw(legiKey = fakeKey)
    row <- if (master) '{"bill_id":1132030,"number":"AB1","change_hash":"abc"}' else
      '{"bill_id":1132030,"state":"CA","number":"AB1","stance":2,"change_hash":"abc","status":1}'
    body <- paste0('{"status":"OK","', payload, '":{"0":', row, '}}')
    local_mocked_bindings(
      req_perform = function(...) rawListResponse(body),
      .package = "httr2"
    )
    nonempty <- fetch()

    for (empty in c('{}', '[]', 'null')){
      body <- paste0('{"status":"OK","', payload, '":', empty, '}')
      result <- fetch()
      expect_identical(result, nonempty[0, ])
      expect_identical(dplyr::select(result, bill_id), dplyr::tibble(bill_id = integer()))
      expect_identical(dplyr::bind_rows(result, nonempty), nonempty)
      expect_identical(dplyr::bind_rows(nonempty, result), nonempty)
      expect_identical(dplyr::anti_join(nonempty, result, by = "bill_id"), nonempty)
      expect_equal(nrow(dplyr::left_join(result, nonempty, by = "bill_id")), 0L)
      joined <- dplyr::left_join(nonempty, result, by = "bill_id")
      expect_equal(nrow(joined), 1L)
      expect_true(is.na(joined$change_hash.y))
    }

    # Additional API fields and nonempty column types must not be normalized.
    body <- paste0('{"status":"OK","', payload,
      '":{"0":{"bill_id":1132030,"change_hash":"abc","extra":"keep"}}}')
    expect_identical(fetch(), dplyr::tibble(bill_id = 1132030L, change_hash = "abc", extra = "keep"))

    body <- '{"status":"ERROR","alert":{"message":"Test API failure"}}'
    expect_error(fetch(), "API returned error: Test API failure", fixed = TRUE)
  }
})

test_that("a session-only raw master list returns typed empty columns", {
  local_mocked_bindings(
    req_perform = function(...) rawListResponse(
      '{"status":"OK","masterlist":{"session":{"session_name":"Test Session"}}}'
    ),
    .package = "httr2"
  )
  expect_message(
    result <- getMasterListRaw(sessionID = 1234, legiKey = fakeKey),
    "Test Session"
  )
  expect_identical(result, dplyr::tibble(
    bill_id = integer(), number = character(), change_hash = character()
  ))
})
