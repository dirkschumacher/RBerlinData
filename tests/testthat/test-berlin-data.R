context("berlin_data")

# helper functions
checkDataSet <- function(data, expected_title, expected_number_resources) {
  expect_equivalent(class(data), "berlin_data_dataset")
  expect_equivalent(data$title, expected_title)
  expect_equivalent(length(data$resources), expected_number_resources)
  lapply(data$resources, 
         function(res)expect_equivalent(class(res), 
                                        "berlin_data_resource"))
}

test_that("searchBerlinDatasets query basic", {
  data <- searchBerlinDatasets(query = "stolpersteine")
  expect_true(length(data) >= 1)
  expect_true(length(data) < 5)
  expect_equivalent(class(data), "berlin_data_list")
})

test_that("searchBerlinDatasets error handling params", {
  expect_error(searchBerlinDatasets())
  expect_error(searchBerlinDatasets(query = c("1", "2")))
})

test_that("search_data correctly finds items", {
  data <- search_data("wochen", xml.url = "./data/test-rss-feed.xml")
  expect_equivalent(length(data), 1)
  data <- search_data("watwatwat", xml.url = "./data/test-rss-feed.xml")
  expect_equivalent(length(data), 1)
  expect_equivalent(class(data), "berlin_data_query_no_results")
  data <- search_data("Antikmarkt", xml.url = "./data/test-rss-feed.xml")
  expect_equivalent(length(data), 1)
})

test_that("search_data extracts the correct information", {
  data <- search_data("wochen", xml.url = "./data/test-rss-feed.xml")[[1]]
  expect_equivalent(data$link, "http://daten.berlin.de/datensaetze/berliner-wochen-und-tr%C3%B6delm%C3%A4rkte-2013")
  expect_equivalent(data$title, "Berliner Wochen- und Troedelmaerkte 2013")
  expect_equivalent(data$description, "Wochenmarkt, Troedelmarkt, Flohmarkt, Antikmarkt")
})

test_that("parseMetaData parses correctly the information", {
  url <- "./data/test-data-datasetpage.html"
  data <- parseMetaData(url)
  expect_equivalent("berlin_data_resource_list", class(resources(data)))
  checkDataSet(data, expected_title = "Sportvereine und Sportangebote in Marzahn-Hellersdorf",
               expected_number_resources = 5)
  expect_equivalent(data$resources[[1]]$hash, "dd42aa49-0b9d-483f-a4c5-9ae561395773")
  expect_equivalent(data$resources[[1]]$format, "HTML")
  expect_equivalent(data$resources[[1]]$language, "Deutsch")
  expect_equivalent(data$resources[[1]]$url, "http://www.berlin.de/ba-marzahn-hellersdorf/verwaltung/bildung/sport/sportvereine/index.php")  
})

test_that("parseMetaData parses correctly the information 2", {
  url <- "./data/data-datasetpage2.html"
  data <- parseMetaData(url)
  expect_equivalent("berlin_data_resource_list", class(resources(data)))
  checkDataSet(data, expected_title = "Angebote der schulbezogenen Jugendarbeit und Jugendsozialarbeit",
               expected_number_resources = 9)
  expect_equivalent(data$resources[[1]]$hash, "1cec5a90-cc82-4351-9298-2ae90e2d86eb")
  expect_equivalent(data$resources[[1]]$format, "HTML")
  expect_equivalent(data$resources[[1]]$language, "Deutsch")
  expect_equivalent(data$resources[[1]]$url, "http://www.berlin.de/ba-lichtenberg/freizeit/sport/ja-jsa/index.php")  
})

test_that("parseMetaData fails with wrong parameter", {
  expect_error(parseMetaData("wat"))
  expect_error(parseMetaData("http://google.com"))
  expect_error(parseMetaData(c("wat", "wat2")))
})

test_that("getDatasetMetaData returns same output for different objects", {
  data_url <- './data/data-datasetpage2.html'
  data_info <- structure(
    list(
      description = 'foo',
      title = 'bar',
      link = data_url
    ),
    class = "berlin_data_dataset_info"
  )
  data_list <- structure(
    list(data_info,
         data_info
      ),
    class = "berlin_data_list"
    )
  expect_equivalent(getDatasetMetaData(data_url), getDatasetMetaData(data_info))
  expect_equivalent(getDatasetMetaData(data_info), getDatasetMetaData(data_list)[[1]])
})

test_that("getDatasetMetaData throws appropriate errors", {
  data_url <- './data/data-datasetpage2.html'
  expect_error(getDatasetMetaData())
  expect_error(getDatasetMetaData(4))
  expect_error(getDatasetMetaData('hi'))
  expect_error(getDatasetMetaData(c(data_url, data_url)))
})
