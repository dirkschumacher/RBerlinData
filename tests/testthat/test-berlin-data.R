context("berlin_data")

test_that("berlin_data query basic", {
  data <- berlin_data(query = "stolpersteine")
  expect_true(length(data) >= 1)
  expect_true(length(data) < 5)
  expect_equivalent(class(data), "berlin_data_list")
})

test_that("berlin_data error handling params", {
  expect_error(berlin_data(query = "wat", url = "wat2"))
  expect_error(berlin_data())
  expect_error(berlin_data(query = c("1", "2")))
  expect_error(berlin_data(url = c("1", "2")))
})

test_that("search_data correctly finds items", {
  data <- search_data("wochen", xml_url = "test-rss-feed.xml")
  expect_equivalent(length(data), 1)
  data <- search_data("watwatwat", xml_url = "test-rss-feed.xml")
  expect_equivalent(length(data), 1)
  expect_equivalent(class(data), "berlin_data_query_no_results")
  data <- search_data("Antikmarkt", xml_url = "test-rss-feed.xml")
  expect_equivalent(length(data), 1)
})

test_that("search_data extracts the correct information", {
  data <- search_data("wochen", xml_url = "test-rss-feed.xml")[[1]]
  expect_equivalent(data$link, "http://daten.berlin.de/datensaetze/berliner-wochen-und-tr%C3%B6delm%C3%A4rkte-2013")
  expect_equivalent(data$title, "Berliner Wochen- und Troedelmaerkte 2013")
  expect_equivalent(data$description, "Wochenmarkt, Troedelmarkt, Flohmarkt, Antikmarkt")
})

