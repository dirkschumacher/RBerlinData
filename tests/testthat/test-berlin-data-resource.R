context("berlin_data_resource")

test_that("download.CSV correctly loads and parses CSV", {
  csv.url <- './data/test-data.csv'
  csv.data <- download.CSV(csv.url)
  expect_error(download.CSV())
  expect_message(download.CSV(4))
  expect_warning(download.CSV('./data/test-data.json'))
  expect_equivalent(class(csv.data), "data.frame")
  expect_equivalent(dim(csv.data), c(4, 22))
})

test_that("download.JSON correctly loads and parses JSON", {
  json.url <- './data/test-data.json'
  json.data <- download.JSON(json.url)
  expect_error(download.JSON())
  expect_message(download.JSON(4))
  expect_message(download.JSON('./data/test-rss-feed.xml'))
  expect_equivalent(class(json.data), "data.frame")
  expect_equivalent(dim(json.data), c(4, 22))
})

test_that("download.XML correctly loads and parses XML", {
  xml.url <- './data/test-data.xml'
  xml.data <- download.XML(xml.url)
  expect_error(download.XML())
  expect_error(download.XML(4))
  expect_error(download.XML('./data/test-data.json'))
  expect_equivalent(class(xml.data), "data.frame")
  expect_equivalent(dim(xml.data), c(4, 22))
})

test_that("generic download function calls correct methods", {
  test_bdr <- structure(list(
    url = './data/test-data.xml',
    format = 'XML'
    ), class="berlin_data_resource")
  data = download(test_bdr)
  expect_equivalent(class(data), "data.frame")
  expect_equivalent(dim(data), c(4, 22))
  # unsupported file formats should call download.default, 
  # which gives an apologetic message
  test_bdr$format <- 'CSS'
  expect_message(download(test_bdr))
  expect_message(download(4))
  expect_error(download())
})
