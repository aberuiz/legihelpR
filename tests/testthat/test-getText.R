with_mock_dir("fixtures", {
  test_that("getText returns document metadata and a base64 encoded doc", {
    expect_message(
      text <- getText(textID = 2614108, legiKey = fakeKey)
    )
    expect_type(text, "list")
    expect_equal(text$doc_id, 2614108)
    expect_equal(text$bill_id, 1633853)
    expect_equal(text$mime, "text/html")
    expect_type(text$doc, "character")
    expect_gt(nchar(text$doc), 0)
  })

  test_that("getText decodes the doc to disk when file is supplied", {
    path <- withr::local_tempfile(fileext = ".html")
    expect_message(
      result <- getText(textID = 2614108, file = path, legiKey = fakeKey),
      "Document saved to "
    )
    expect_equal(result, path)
    expect_true(file.exists(path))
    suppressMessages(
      text <- getText(textID = 2614108, legiKey = fakeKey)
    )
    expect_identical(
      readBin(path, "raw", n = file.size(path)),
      openssl::base64_decode(text$doc)
    )
  })
})
