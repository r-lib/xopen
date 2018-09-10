library(testthat)
library(xopen)

if (ps::ps_is_supported()) {
  reporter <- ps::CleanupReporter(testthat::SummaryReporter)$new()
} else {
  ## ps does not support this platform
  reporter <- "progress"
}

test_check("xopen", reporter = reporter)
