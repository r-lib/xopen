
context("xopen")

test_that("xopen works", {

  if (Sys.getenv("TESTTHAT_INTERACTIVE") == "") {
    skip("Need to test this interactively")
  }

  ## File
  expect_error(xopen("test.R", quiet = TRUE), NA)

  ## URL
  expect_error(xopen("https://ps.r-lib.org", quiet = TRUE), NA)

  ## URL with given app
  expect_error(
    xopen("https://processx.r-lib.org", app = chrome(), quiet = TRUE),
    NA)

  ## App only, no target
  expect_error(xopen(app = chrome(), quiet = TRUE), NA)

  ## App and arguments (need to quit Chrome for this to work...)
  expect_error(
    xopen(
      app = c(chrome(), "--incognito", "https://github.com"),
      quiet = TRUE),
    NA)
})

test_that("URLs with spaces", {

  if (Sys.getenv("TESTTHAT_INTERACTIVE") == "") {
    skip("Need to test this interactively")
  }

  expect_error(
    xopen("https://google.com/search?q=a b c", quiet = TRUE),
    NA)
})

test_that("errors", {
  skip_on_cran()
  expect_error(xopen2(tempfile(), quiet = TRUE, timeout1 = 10, timeout2 = 10))
})

test_that("wait_for_finish", {
  px <- get("get_tool", asNamespace("processx"))("px")
  proc <- processx::process$new(
    px, c("errln", "message", "sleep", "100"), stderr = tempfile())
  on.exit(proc$kill(), add = TRUE)

  proc$poll_io(1000)
  expect_error(wait_for_finish(proc, "target", 10, 10),
               "Could not open")
  expect_error(wait_for_finish(proc, "target", 10, 10),
               "Standard error")
})
