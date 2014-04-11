# Code snippets for demonstrating package use

# Gets list of all available datasets
all.results <- searchBerlinDatasets(query = "")
length(all.results)
# Downloads metadata for all available datasets (can take some time)
all.metadata <- getDatasetMetaData(all.results)

# Currently we support CSV, JSON, and XML.
# How much of the available data does that cover?

covered.formats <- c('CSV', 'XML', 'JSON')
all.resources <- lapply(all.metadata, function(dataset) {
  title <- dataset$title
  hashes <- sapply(dataset$resources, function(res) res$hash)
  formats <- sapply(dataset$resources, function(res) res$format)
  data.frame(title=rep(title, length(hashes)),
             hash=hashes,
             format=formats)
})
all.resources = do.call(rbind, all.resources)
summary(all.resources) 
# why are there fewer unique titles here than items in the all.metadata list? missing resources?

covered.resources <- colSums(xtabs(~ format + title, data=all.resources)[covered.formats, ])
percent.covered <- length(covered.resources[covered.resources > 0])/length(covered.resources)

percent.covered # hm, not too good.

# Of the formats we don't yet support, which are most used? We should work on those first.
table(all.resources$format[all.resources$title %in% names(covered.resources[covered.resources == 0])])
# gah. XLS, of course.

