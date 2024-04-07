source("00-global.R")

comments <- map(
  set_names(packages),
  ~ gh::gh(paste0("GET /repos/r-dbi/", .x, "/issues/comments"), state = "all", .limit = Inf),
  .progress = TRUE
)

qs::qsave(comments, "02-issues-comments.qs")
