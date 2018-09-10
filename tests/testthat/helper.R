
chrome <- function() {
  switch(
    get_os(),
    win = "Chrome",
    macos = "google chrome",
    other = "google-chrome")
}
