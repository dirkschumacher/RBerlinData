[![Build Status](https://travis-ci.org/dirkschumacher/RBerlinData.png?branch=master)](https://travis-ci.org/dirkschumacher/RBerlinData)
BerlinData
===========

The `R` package `BerlinData` gives you easy access to [data.berlin.de](http://daten.berlin.de). This is currently the development version

# Installation

To get the current released version from CRAN (not yet available):

```R
install.packages("BerlinData")
```

To get the current development version from github:

```R
# install.packages("devtools")
devtools::install_github("dirkschumacher/RBerlinData")
```


# Usage
```R
results <- berlin_data(query = "stolpersteine")
summary(results)
resources <- resources(results[[2]])
summary(resources)
data <- fetch(resources[[1]]) # fetches the first reseource into a data.frame
summary(data)
```

# Versioning
It uses [Semantic Versioning 2](http://semver.org/spec/v2.0.0.html) for version numbering.
