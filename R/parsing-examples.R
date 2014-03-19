library(XML)

# example: get all items from daten.berlin's Open Data sets rss feed
feed = xmlParse('http://daten.berlin.de/datensaetze/rss.xml')
items = getNodeSet(feed, "//item"))

# parse one of the item's URLs          
through.site = htmlParse('http://daten.berlin.de/datensaetze/besch%C3%A4ftigtendaten')
through.links = xpathApply(through.site,  "//a[@href]", xmlGetAttr, "href")
              
# get plausible API links
api.links = unlist(lapply(through.links, function(link) grep('\\?q=', link, value=TRUE)))



