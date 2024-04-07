source("00-global.R")

issues <- qs::qread("01-issues.qs")
issues_comments <- qs::qread("02-issues-comments.qs")

# issue_specs <-
#   issues |>
#   map(tibblify::guess_tspec)
#
# tibblify::tspec_combine(!!!issue_specs) |>
#   print() |>
#   capture.output() |>
#   clipr::write_clip()

issue_spec <- tspec_df(
  issue_url = tib_chr("url"),
  tib_chr("repository_url"),
  tib_chr("labels_url"),
  tib_chr("comments_url"),
  tib_chr("events_url"),
  issue_html_url = tib_chr("html_url"),
  tib_dbl("id"),
  tib_chr("node_id"),
  tib_int("number"),
  tib_chr("title"),
  tib_row(
    "user",
    tib_chr("login"),
    tib_dbl("id"),
    tib_chr("node_id"),
    tib_chr("avatar_url"),
    tib_chr("gravatar_id"),
    tib_chr("url"),
    tib_chr("html_url"),
    tib_chr("followers_url"),
    tib_chr("following_url"),
    tib_chr("gists_url"),
    tib_chr("starred_url"),
    tib_chr("subscriptions_url"),
    tib_chr("organizations_url"),
    tib_chr("repos_url"),
    tib_chr("events_url"),
    tib_chr("received_events_url"),
    tib_chr("type"),
    tib_lgl("site_admin"),
  ),
  tib_df(
    "labels",
    tib_dbl("id", required = FALSE),
    tib_chr("node_id", required = FALSE),
    tib_chr("url", required = FALSE),
    tib_chr("name", required = FALSE),
    tib_chr("color", required = FALSE),
    tib_lgl("default", required = FALSE),
    tib_chr("description", required = FALSE),
  ),
  tib_chr("state"),
  tib_lgl("locked"),
  tib_row(
    "assignee",
    tib_chr("login", required = FALSE),
    tib_dbl("id", required = FALSE),
    tib_chr("node_id", required = FALSE),
    tib_chr("avatar_url", required = FALSE),
    tib_chr("gravatar_id", required = FALSE),
    tib_chr("url", required = FALSE),
    tib_chr("html_url", required = FALSE),
    tib_chr("followers_url", required = FALSE),
    tib_chr("following_url", required = FALSE),
    tib_chr("gists_url", required = FALSE),
    tib_chr("starred_url", required = FALSE),
    tib_chr("subscriptions_url", required = FALSE),
    tib_chr("organizations_url", required = FALSE),
    tib_chr("repos_url", required = FALSE),
    tib_chr("events_url", required = FALSE),
    tib_chr("received_events_url", required = FALSE),
    tib_chr("type", required = FALSE),
    tib_lgl("site_admin", required = FALSE),
  ),
  tib_df(
    "assignees",
    tib_chr("login", required = FALSE),
    tib_dbl("id", required = FALSE),
    tib_chr("node_id", required = FALSE),
    tib_chr("avatar_url", required = FALSE),
    tib_chr("gravatar_id", required = FALSE),
    tib_chr("url", required = FALSE),
    tib_chr("html_url", required = FALSE),
    tib_chr("followers_url", required = FALSE),
    tib_chr("following_url", required = FALSE),
    tib_chr("gists_url", required = FALSE),
    tib_chr("starred_url", required = FALSE),
    tib_chr("subscriptions_url", required = FALSE),
    tib_chr("organizations_url", required = FALSE),
    tib_chr("repos_url", required = FALSE),
    tib_chr("events_url", required = FALSE),
    tib_chr("received_events_url", required = FALSE),
    tib_chr("type", required = FALSE),
    tib_lgl("site_admin", required = FALSE),
  ),
  tib_row(
    "milestone",
    tib_chr("url", required = FALSE),
    tib_chr("html_url", required = FALSE),
    tib_chr("labels_url", required = FALSE),
    tib_dbl("id", required = FALSE),
    tib_chr("node_id", required = FALSE),
    tib_int("number", required = FALSE),
    tib_chr("title", required = FALSE),
    tib_chr("description", required = FALSE),
    tib_row(
      "creator",
      .required = FALSE,
      tib_chr("login"),
      tib_dbl("id"),
      tib_chr("node_id"),
      tib_chr("avatar_url"),
      tib_chr("gravatar_id"),
      tib_chr("url"),
      tib_chr("html_url"),
      tib_chr("followers_url"),
      tib_chr("following_url"),
      tib_chr("gists_url"),
      tib_chr("starred_url"),
      tib_chr("subscriptions_url"),
      tib_chr("organizations_url"),
      tib_chr("repos_url"),
      tib_chr("events_url"),
      tib_chr("received_events_url"),
      tib_chr("type"),
      tib_lgl("site_admin"),
    ),
    tib_int("open_issues", required = FALSE),
    tib_int("closed_issues", required = FALSE),
    tib_chr("state", required = FALSE),
    tib_chr("created_at", required = FALSE),
    tib_chr("updated_at", required = FALSE),
    tib_chr("due_on", required = FALSE),
    tib_chr("closed_at", required = FALSE),
  ),
  tib_int("comments"),
  issue_created_at = tib_chr_datetime("created_at"),
  issue_updated_at = tib_chr_datetime("updated_at"),
  issue_closed_at = tib_chr_datetime("closed_at"),
  issue_author_association = tib_chr("author_association"),
  tib_chr("active_lock_reason"),
  tib_chr("body"),
  tib_row(
    "reactions",
    tib_chr("url"),
    tib_int("total_count"),
    tib_int("+1"),
    tib_int("-1"),
    tib_int("laugh"),
    tib_int("hooray"),
    tib_int("confused"),
    tib_int("heart"),
    tib_int("rocket"),
    tib_int("eyes"),
  ),
  tib_chr("timeline_url"),
  tib_unspecified("performed_via_github_app"),
  tib_chr("state_reason"),
  tib_lgl("draft", required = FALSE),
  tib_row(
    "pull_request",
    .required = FALSE,
    tib_chr("url", required = FALSE),
    tib_chr("html_url", required = FALSE),
    tib_chr("diff_url", required = FALSE),
    tib_chr("patch_url", required = FALSE),
    tib_chr("merged_at", required = FALSE),
  ),
)

issues_tbl <-
  issues |>
  map(tibblify::tibblify, spec = issue_spec, unspecified = "drop") |>
  bind_rows(.id = "repo")

# comment_specs <-
#   comments |>
#   map(tibblify::guess_tspec)
#
# tibblify::tspec_combine(!!!comment_specs) |>
#   print() |>
#   capture.output() |>
#   clipr::write_clip()

comments_spec <- tspec_df(
  tib_chr("url"),
  tib_chr("html_url"),
  tib_chr("issue_url"),
  tib_dbl("id"),
  tib_chr("node_id"),
  tib_row(
    "user",
    tib_chr("login"),
    tib_dbl("id"),
    tib_chr("node_id"),
    tib_chr("avatar_url"),
    tib_chr("gravatar_id"),
    tib_chr("url"),
    tib_chr("html_url"),
    tib_chr("followers_url"),
    tib_chr("following_url"),
    tib_chr("gists_url"),
    tib_chr("starred_url"),
    tib_chr("subscriptions_url"),
    tib_chr("organizations_url"),
    tib_chr("repos_url"),
    tib_chr("events_url"),
    tib_chr("received_events_url"),
    tib_chr("type"),
    tib_lgl("site_admin"),
  ),
  tib_chr_datetime("created_at"),
  tib_chr_datetime("updated_at"),
  tib_chr("author_association"),
  tib_chr("body"),
  tib_row(
    "reactions",
    tib_chr("url"),
    tib_int("total_count"),
    tib_int("+1"),
    tib_int("-1"),
    tib_int("laugh"),
    tib_int("hooray"),
    tib_int("confused"),
    tib_int("heart"),
    tib_int("rocket"),
    tib_int("eyes"),
  ),
  tib_unspecified("performed_via_github_app"),
)

issues_comments_tbl <-
  issues_comments |>
  map(tibblify::tibblify, spec = comments_spec, unspecified = "drop") |>
  bind_rows(.id = "repo")

qs::qsave(issues_tbl, "03-issues_tbl.qs")
qs::qsave(issues_comments_tbl, "03-issues_comments_tbl.qs")
