
context("xopen")

test_that("xopen works", {

  if (Sys.getenv("TESTTHAT_INTERACTIVE") == "") {
    skip("Need to test this interactively")
  }

  ## File
  xopen("test.R")

  ## URL
  xopen("https://ps.r-lib.org")

  ## URL with given app
  xopen("https://processx.r-lib.org", app = chrome())

  ## App only, no target
  xopen(app = chrome())

  ## App and arguments (need to quit Chrome for this to work...)
  xopen(app = chrome(), app_args = c("--incognito", "https://github.com"))
})

test_that("URLs with spaces", {

  if (Sys.getenv("TESTTHAT_INTERACTIVE") == "") {
    skip("Need to test this interactively")
  }

  xopen("https://google.com/search?q=a b c")
})
