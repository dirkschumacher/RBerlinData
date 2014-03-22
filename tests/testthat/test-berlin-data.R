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

test_that("load_metadata parses correctly the information", {
  url <- "test-data-datasetpage.html"
  data <- load_metadata(url)
  expect_equivalent(class(data), "berlin_data_dataset")
  expect_equivalent(data$title, "Sportvereine und Sportangebote in Marzahn-Hellersdorf")
  expect_equivalent(length(data$resources), 5)
  lapply(data$resources, 
         function(res)expect_equivalent(class(res), 
                                        "berlin_data_resource"))
  expect_equivalent(data$resources[[1]]$hash, "dd42aa49-0b9d-483f-a4c5-9ae561395773")
  expect_equivalent(data$resources[[1]]$format, "HTML")
  expect_equivalent(data$resources[[1]]$language, "Deutsch")
  expect_equivalent(data$resources[[1]]$url, "http://www.berlin.de/ba-marzahn-hellersdorf/verwaltung/bildung/sport/sportvereine/index.php")
  
})

test_that("load_metadata fails with wrong parameter", {
  expect_error(load_metadata("wat"))
  expect_error(load_metadata("http://google.com"))
  expect_error(load_metadata(c("wat", "wat2")))
})

