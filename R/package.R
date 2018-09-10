
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
#' @param ... Additional arguments, not used currently.
#'
#' @section Examples:
#' ```
#' xopen("test.R")
#' xopen("https://ps.r-lib.org")
#' xopen(tempdir())
#' ```
#' @export

xopen <- function(target = NULL, app = NULL, app_args = NULL,
                  quiet = FALSE, ...)
  UseMethod("xopen")

#' @export

xopen.default <- function(target = NULL, app = NULL, app_args = NULL,
                          quiet = FALSE, ...) {

  if (is.null(app) && !is.null(app_args)) {
    warning("No `app`, so `app_args` are ignored")
  }

  xopen2(target, app, app_args, quiet)
}

xopen2 <- function(target, app, app_args, quiet,
                   timeout1 = 2000, timeout2 = 5000) {

  os <- get_os()
  fun <- switch(os, win = xopen_win, macos = xopen_macos, xopen_other)
  par <- fun(target, app, app_args)

  err <- tempfile()
  on.exit(unlink(err, recursive = TRUE), add = TRUE)
  px <- processx::process$new(par[[1]], par[[2]], stderr = err,
                              echo_cmd = !quiet)

  ## Cleanup, if needed
  if (par[[3]]) wait_for_finish(px, target, timeout1, timeout2)

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
  list(cmd, args, TRUE)
}

xopen_win <- function(target, app, app_args) {
  cmd <- "cmd"
  args <- c("/c", "start", "\"\"", "/b")
  target <- gsub("&", "^&", target)
  if (!is.null(app)) args <- c(args, app, app_args)
  args <- c(args, target)
  list(cmd, args, TRUE)
}

xopen_other <- function(target, app, app_args) {
  if (!is.null(app)) {
    cmd <- app
    args <- app_args
    cleanup <- FALSE
  } else  {
    cmd <- Sys.which("xdg-open")
    if (cmd == "") cmd <- system.file("xdg-open", package = "xopen")
    args <- character()
    cleanup <- TRUE
  }
  args <- c(args, target)
  list(cmd, args, cleanup)
}

#' Wait for a process to finish
#'
#' With timeout(s), and interaction, if the session is interactive.
#'
#' First we wait for 2s. If the process is still alive, then we give
#' it another 5s, but first let the user know that they can interrupt
#' the process.
#'
#' @param process The process. It should not have `stdout` or `stderr`
#'   pipes, because that can make it freeze.
#' @param timeout1 Timeout before message.
#' @param timeout2 Timeout after message.
#'
#' @keywords internal

wait_for_finish <- function(process, target, timeout1 = 2000,
                            timeout2 = 5000) {
  on.exit(process$kill(), add = TRUE)
  process$wait(timeout = timeout1)
  if (process$is_alive()) {
    message("Still trying to open ", encodeString(target, quote = "'"),
            ", you can interrupt any time")
    process$wait(timeout = timeout2)
    process$kill()
  }
  if (stat <- process$get_exit_status()) {
    err <- if (file.exists(ef <- process$get_error_file())) readLines(ef)
    stop(
      call. = FALSE,
      "Could not open ", encodeString(target, quote = "'"), "\n",
      "Exit status: ", stat, "\n",
      if (length(err) && nzchar(err))
        paste("Standard error:", err, collapse = "\n"))
  }
}
