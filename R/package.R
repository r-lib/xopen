
#' Open a file, directory or URL
#'
#' Open a file, directory or URL, using the local platforms conventions,
#' i.e. associated applications, default programs, etc. This is usually
#' equivalent to double-clicking on the file in the GUI.
#'
#' @param target String, the path or URL to open.
#' @param app Specify the app to open `target` with. Note that app names
#'   are platform dependent.
#' @param app_args Arguments to pass to `app`. If this is specified, but
#'   `app` is `NULL`, then it is ignored, with a warning.
#' @param quiet Whether to echo the command to the screen, before
#'   running it.
#'
#' @section Examples:
#' ```
#' xopen("test.R")
#' xopen("https://ps.r-lib.org")
#' xopen(tempdir())
#' ```
#' @export

xopen <- function(target = NULL, app = NULL, app_args = NULL,
                  quiet = FALSE) {

  if (is.null(app) && !is.null(app_args)) {
    warning("No `app`, so `app_args` are ignored")
  }

  os <- get_os()
  fun <- switch(os, win = xopen_win, macos = xopen_macos, xopen_other)
  par <- fun(target, app, app_args)

  err <- tempfile()
  on.exit(unlink(err, recursive = TRUE), add = TRUE)
  px <- processx::process$new(par[[1]], par[[2]], stderr = err,
                              echo_cmd = !quiet)

  invisible(px)
}

get_os <- function() {
  if (.Platform$OS.type == "windows") {
    "win"
  } else if (Sys.info()[["sysname"]] == "Darwin") {
    "macos"
  } else {
    "other"
  }
}

xopen_macos <- function(target, app, app_args) {
  cmd <- "open"
  args <- if (!is.null(app)) c("-a", app)
  args <- c(args, target)
  if (!is.null(app)) args <- c(args, "--args",  app_args)
  list(cmd, args)
}

xopen_win <- function(target, app, app_args) {
  cmd <- "cmd"
  args <- c("/c", "start", "\"\"", "/b")
  target <- gsub("&", "^&", target)
  if (!is.null(app)) args <- c(args, app, app_args)
  args <- c(args, target)
  list(cmd, args)
}

xopen_other <- function(target, app, app_args) {
  if (!is.null(app)) {
    cmd <- app
    args <- app_args
  } else  {
    cmd <- Sys.which("xdg-open")
    if (cmd == "") cmd <- system.file("xdg-open", package = "xopen")
    args <- character()
  }
  args <- c(args, target)
  list(cmd, args)
}
