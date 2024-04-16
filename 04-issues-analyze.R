source("00-global.R")

issues_tbl <- qs::qread("03-issues_tbl.qs")
issues_comments_tbl <- qs::qread("03-issues_comments_tbl.qs")

issues_tbl |>
  count(issue_author_association)

my_issues_tbl <-
  issues_tbl |>
  mutate(
    repo,
    issue_url,
    number,
    state,
    issue_created_at,
    issue_closed_at,
    issue_user_login = user$login,
    issue_author_association,
    issue_author_is_member = (issue_author_association == "MEMBER"),
    issue_is_pr = !is.na(pull_request$url),
    issue_html_url,
    .keep = "none"
  )

issues_comments_tbl |>
  count(author_association)

my_issues_comments_tbl <-
  issues_comments_tbl |>
  mutate(
    id,
    issue_url,
    user_login = user$login,
    author_is_member = (author_association == "MEMBER"),
    created_at,
    .keep = "none"
  )

issues_vs_first_member_comment <-
  my_issues_comments_tbl |>
  filter(author_is_member) |>
  filter(row_number() == 1, .by = issue_url) |>
  full_join(my_issues_tbl, join_by(issue_url))

issues_vs_first_member_comment |>
  count(issue_author_is_member, author_is_member, state)

# Unresponded issues
issues_vs_first_member_comment |>
  filter(!issue_author_is_member & is.na(author_is_member) & state == "open") |>
  pull() |>
  # walk(browseURL)
  identity()

# Slow issues
issues_vs_first_member_comment |>
  mutate(time = as.numeric(created_at - issue_created_at) / 86400) |>
  filter(clock::get_year(issue_created_at) >= 2022) |>
  filter(!issue_is_pr) |>
  filter(time >= 14) |>
  pull(issue_html_url) |>
  # walk(browseURL)
  identity()

my_issues_tbl |>
  filter(!issue_is_pr) |>
  mutate(year = lubridate::year(issue_created_at)) |>
  mutate(issue_author_association = factor(issue_author_association, levels = c("MEMBER", "CONTRIBUTOR", "NONE"))) |>
  ggplot(aes(factor(year), fill = issue_author_association)) +
  geom_bar() +
  labs(
    x = "Year",
    y = "Number of issues",
    fill = "Author association",
    title = "Issues opened per year"
  ) +
  theme(axis.text.x = element_text(angle = 90, hjust = 0, vjust = 0.5))

ggsave("issues_per_year.png", width = 10, height = 6)

issues_vs_first_member_comment |>
  filter(!issue_author_is_member) |>
  mutate(new = clock::get_year(issue_created_at) >= 2022) |>
  mutate(time = as.numeric(created_at - issue_created_at) / 86400) |>
  filter(!is.na(time)) |>
  mutate(time_bin = santoku::chop(
    trunc(time),
    as.integer(c(0, 1, 4, 7, 14)),
    labels = santoku::lbl_glue("<{r}", last = ">{l}")
  )) |>
  count(new, issue_is_pr, time_bin) |>
  mutate(issue_is_pr = ifelse(issue_is_pr, "Pull requests", "Issues")) |>
  mutate(new = ifelse(new, "2022 and later", "Before 2022")) |>
  ggplot(aes(time_bin, n)) +
  geom_col() +
  scale_y_continuous() +
  labs(
    x = "Time to first response (days)",
    y = "Number of issues",
    title = "Time to first response for issues and pull requests",
  ) +
  facet_grid(vars(new), vars(issue_is_pr), scales = "free_y")

ggsave("time_to_first_response.png", width = 10, height = 6)

issues_vs_first_member_comment |>
  filter(!issue_author_is_member) |>
  mutate(new = clock::get_year(issue_created_at) >= 2022) |>
  mutate(time = as.numeric(issue_closed_at - issue_created_at) / 86400) |>
  mutate(human = (issue_user_login != "github-actions[bot]")) |>
  filter(!is.na(time)) |>
  mutate(time_bin = santoku::chop(
    trunc(time),
    as.integer(c(0, 1, 4, 7, 14, 28, 90, 180, 360)),
    labels = santoku::lbl_glue("<{r}", last = ">{l}")
  )) |>
  count(new, issue_is_pr, human, time_bin) |>
  mutate(issue_is_pr = ifelse(issue_is_pr, "Pull requests", "Issues")) |>
  mutate(new = ifelse(new, "2022 and later", "Before 2022")) |>
  mutate(human = ifelse(human, "Human", "Bot")) |>
  ggplot(aes(time_bin, n, fill = human)) +
  geom_col() +
  scale_y_continuous() +
  labs(
    x = "Time to close (days)",
    y = "Number of issues",
    fill = "Issue author",
    title = "Time to close for issues and pull requests",
  ) +
  facet_grid(vars(new), vars(issue_is_pr), scales = "free_y")

ggsave("time_to_close.png", width = 10, height = 6)
