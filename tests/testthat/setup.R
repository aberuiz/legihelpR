library(httptest2)

set_redactor(legiscanRedactor)
# Fixture replays make no live requests, so skip request pacing.
withr::local_options(
  legihelpR.request_interval = 0,
  .local_envir = teardown_env()
)
