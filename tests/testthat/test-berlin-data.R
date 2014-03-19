#describe("berlin_data", {
#  it("accepts a query string", {
#    data <- berlin_data(query = "stolpersteine")
#  })
#})

test_that("berlin_data basics", {
  data <- berlin_data(query = "stolpersteine")
})