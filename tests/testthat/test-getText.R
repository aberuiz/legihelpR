with_mock_dir("fixtures", {
  test_that("getText returns document metadata and a base64 encoded doc", {
    expect_output(
      text <- getText(textID = 2614108, legiKey = fakeKey)
    )
    expect_type(text, "list")
    expect_equal(text$doc_id, 2614108)
    expect_equal(text$bill_id, 1633853)
    expect_equal(text$mime, "text/html")
    expect_type(text$doc, "character")
    expect_gt(nchar(text$doc), 0)
  })
})
