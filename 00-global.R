library(conflicted)
library(tidyverse)
library(tibblify)
conflicted::conflicts_prefer(dplyr::filter)
conflicted::conflicts_prefer(purrr::set_names)

packages <- c(
  "DBI",
  "DBItest",
  "RMariaDB",
  "RPostgres",
  "RSQLite",
  "dblog",
  "RKazam",
  NULL
)

tib_chr_datetime <- function(key, ...) {
  tib_scalar(key, vctrs::new_datetime(), ptype_inner = character(), transform = parsedate::parse_iso_8601, ...)
}
