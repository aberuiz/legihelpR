test_that("search pagination preserves rows and types from a custom start", {
  for (search in list(legiSearch, legiSearchRaw)){
    requestedPages <- numeric()
    local_mocked_bindings(
      legiRequest = function(op, page, ...){
        requestedPages <<- c(requestedPages, page)
        rows <- list(list(bill_id = page, change_hash = paste0("hash", page)))
        summary <- list(page_total = 5)
        if (op == "getSearchRaw"){
          return(list(searchresult = list(results = rows, summary = summary)))
        }
        # Metadata deliberately follows the first bill.
        list(searchresult = c(rows, list(summary = summary)))
      },
      .package = "legihelpR"
    )

    result <- suppressMessages(search(query = "test", page = 3, maxPages = 2))
    expect_equal(requestedPages, c(3, 4))
    expect_identical(result, dplyr::tibble(
      bill_id = c(3, 4), change_hash = c("hash3", "hash4")
    ))

    requestedPages <- numeric()
    result <- suppressMessages(search(query = "test", page = 3, maxPages = Inf))
    expect_equal(requestedPages, c(3, 4, 5))
    expect_equal(result$bill_id, c(3, 4, 5))
  }
})
