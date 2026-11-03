library(httptest2)

set_redactor(legiscanRedactor)

# httptest2::with_mock_dir() records from the live API whenever `dir` is not
# found, for example when tests run from an unexpected directory. This masks it
# so that a missing directory is an error instead. It is here, not in helper.R,
# because test_local() puts helpers behind library(httptest2) on the search path.
with_mock_dir <- function(dir, expr) {
  path <- test_path(dir)
  if (!dir.exists(path)) {
    stop("Fixture directory not found, refusing to record: ", path, call. = FALSE)
  }
  httptest2::with_mock_dir(normalizePath(path), expr)
}

# Fixture replays make no live requests, so skip request pacing.
withr::local_options(
  legihelpR.request_interval = 0,
  .local_envir = teardown_env()
)
# Tests never use the real key or the real network. Any request a mock does not
# catch goes to a closed local port and fails. Only local sockets are exempt.
withr::local_envvar(
  legiKey = NA,
  http_proxy = "http://127.0.0.1:9",
  https_proxy = "http://127.0.0.1:9",
  no_proxy = "127.0.0.1",
  .local_envir = teardown_env()
)
