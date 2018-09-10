
# xopen

> Open System Files, URLs, Anything

[![Linux Build Status](https://travis-ci.org/r-lib/xopen.svg?branch=master)](https://travis-ci.org/r-lib/xopen)
[![Windows Build status](https://ci.appveyor.com/api/projects/status/github/r-lib/xopen?branch=master&svg=true)](https://ci.appveyor.com/project/gaborcsardi/xopen)
[![](http://www.r-pkg.org/badges/version/xopen)](http://www.r-pkg.org/pkg/xopen)
[![CRAN RStudio mirror downloads](http://cranlogs.r-pkg.org/badges/xopen)](http://www.r-pkg.org/pkg/xopen)

Cross platform solution to open files, directories or URLs with their
associated programs. Inspired by `shell.exec()`,
https://github.com/pwnall/node-open and
https://github.com/sindresorhus/opn

## Installation

Once released, you can install xopen from CRAN:

```r
install.packages("xopen")
```

## Usage

```r
library(xopen)
```

Open a file:

```r
xopen("test.R")
```

Open a URL:

```r
xopen("https://ps.r-lib.org")
```

URL with given app:

```r
chrome <- function() {
  switch(
    get_os(),
    win = "Chrome",
    macos = "google chrome",
    other = "google-chrome")
}
xopen("https://processx.r-lib.org", app = chrome())
```

Open a given app (or switch to it, if already open):

```r
xopen(app = chrome())
```

App and arguments. (You need to quit Chrome for this to work):
```r
xopen(app = c(chrome(), "--incognito", "https://github.com"))
```

## License

MIT © RStudio
