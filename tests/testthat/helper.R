# 32 character stand-in for a real LegiScan API key. Tests pass it explicitly
# so replaying fixtures never depends on a key in ~/.Renviron.
fakeKey <- "FAKEKEYFAKEKEYFAKEKEYFAKEKEY0000"

# httptest2 applies this to requests and responses when recording and replaying
# fixtures. LegiScan sends the API key as a query parameter, which httptest2
# does not redact by default: this swaps the real key for `fakeKey` in fixture
# file names (hashed from the URL) and bodies, so the real key never lands in
# tests/testthat/fixtures.
legiscanRedactor <- function(x) {
  realKey <- Sys.getenv("legiKey")
  if (nzchar(realKey)) {
    x$url <- gsub(realKey, fakeKey, x$url, fixed = TRUE)
    if (inherits(x, "httr2_response") && length(x$body)) {
      x <- httptest2::within_body_text(
        x,
        function(body) gsub(realKey, fakeKey, body, fixed = TRUE)
      )
    }
  }
  x
}

# A listening socket that never accepts: connections succeed, requests are
# sent, and no answer ever comes. Returns the URL and the socket.
local_silent_server <- function(env = parent.frame()) {
  for (port in sample(49152:65535, 20)) {
    server <- tryCatch(suppressWarnings(serverSocket(port)), error = function(e) NULL)
    if (!is.null(server)) {
      withr::defer(close(server), envir = env)
      return(list(url = sprintf("http://127.0.0.1:%d", port), server = server))
    }
  }
  stop("Could not open a local socket", call. = FALSE)
}

# Number of connections a silent server received.
count_connections <- function(server) {
  count <- 0L
  repeat {
    connection <- tryCatch(
      suppressWarnings(socketAccept(server, timeout = 1)),
      error = function(e) NULL
    )
    if (is.null(connection)) return(count)
    close(connection)
    count <- count + 1L
  }
}
