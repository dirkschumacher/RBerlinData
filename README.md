[![Build Status](https://travis-ci.org/dirkschumacher/RBerlinData.svg?branch=master)](https://travis-ci.org/dirkschumacher/RBerlinData)
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
# still under development
result <- berlin_data(query = "stolpersteine")
dataset <- load_metadata(result[[2]]$link)
resources <- resources(dataset)
data <- fetch(resources[[2]])
```

# Versioning
It uses [Semantic Versioning 2](http://semver.org/spec/v2.0.0.html) for version numbering.
