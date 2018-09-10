
#' @export

xopen <- function(target = NULL, app = NULL, app_args = NULL,
                  quiet = FALSE) {

  if (is.null(app) && !is.null(app_args)) {
    warning("No `app`, so `app_args` are ignored")
  }

  if (.Platform$OS.type == "windows") {
    par <- xopen_win(target, app, app_args)

  } else if (Sys.info()[["sysname"]] == "Darwin") {
    par <- xopen_macos(target, app, app_args)

  } else {
    par <- xopen_other(target, app, app_args)
  }

  err <- tempfile()
  on.exit(unlink(err, recursive = TRUE), add = TRUE)
  px <- processx::process$new(par[[1]], par[[2]], stderr = err,
                              echo_cmd = !quiet)

  invisible(px)
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

xopen_other <- function(taget, app, app_args) {
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
