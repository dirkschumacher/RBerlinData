context("berlin_data_resource")

test_that("downloadJSON correctly loads and parses JSON", {
  json.url = './data/test-data.json'
  json.data = downloadJSON(json.url)
  expect_error(downloadJSON())
  expect_error(downloadJSON(4))
  expect_error(downloadJSON('./data/test-rss-feed.xml'))
  expect_equivalent(class(json.data), "data.frame")
  expect_equivalent(dim(json.data), c(4, 22))
})

test_that("downloadXML correctly loads and parses XML", {
  xml.url = './data/test-data.xml'
  xml.data = downloadXML(xml.url)
  expect_error(downloadXML())
  expect_error(downloadXML(4))
  expect_error(downloadXML('./data/test-data.json'))
  expect_equivalent(class(xml.data), "data.frame")
  expect_equivalent(dim(xml.data), c(4, 22))
})
