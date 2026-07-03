with_mock_dir("fixtures", {
  test_that("getPerson returns an individual record as a dataframe", {
    expect_output(
      person <- getPerson(PeopleID = 5997, legiKey = fakeKey)
    )
    expect_s3_class(person, "data.frame")
    expect_true(all(person$people_id == 5997))
    expect_contains(names(person), c("name", "party"))
  })
})
