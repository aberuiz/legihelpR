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
