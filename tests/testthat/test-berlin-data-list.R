context("berlin_data_list")

test_that("outputs a summary", {
  data_list1 <- structure(list(list(title = "data set 1")), 
                          class = "berlin_data_list")
  expected_output1 <- list(length = 1, data_sets = c("data set 1"))
  expect_equivalent(summary(data_list1), expected_output1)
})