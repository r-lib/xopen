
#' @export

xopen <- function(target = NULL, app = NULL, app_args = NULL) {

  if (is.null(app) && !is.null(app_args)) {
    warning("No `app`, so `app_args` are ignored")
  }

  if (.Platform$OS.type == "windows") {
    cmd <- "cmd"
    args <- c("/c", "start", "\"\"", "/b")
    target <- gsub("&", "^&", target)
    if (!is.null(app)) args <- c(args, app, app_args)
    args <- c(args, target)

  } else if (Sys.info()[["sysname"]] == "Darwin") {
    cmd <- "open"
    args <- if (!is.null(app)) c("-a", app)
    args <- c(args, target)
    if (!is.null(app)) args <- c(args, "--args",  app_args)

  } else {
    if (!is.null(app)) {
      cmd <- app
      args <- app_args
    } else  {
      cmd <- system.file("xdg-open", package = "xopen")
      args <- character()
    }
    args <- c(args, target)
  }

  px <- processx::process$new(cmd, as.character(args))

  invisible(px)
}
