source("00-global.R")

issues <- map(
  set_names(packages),
  ~ gh::gh(paste0("GET /repos/r-dbi/", .x, "/issues"), state = "all", .limit = Inf),
  .progress = TRUE
)

qs::qsave(issues, "01-issues.qs")
