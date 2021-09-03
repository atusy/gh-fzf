# gh-fzf v0.2.0 (unreleased)

- Add `_GH_FZF_VIEWER` environmental variable to control viewer.
  Options are `web` (default), `text`, `id`, `url`, and `short_url`.
  The `short_url` shortens the url by `git.io` for GitHub and `bitly` for GitLab.
- Support aliases and extensions. For them, `ghf` and `glabf` do not attempt applying `fzf`
  unless they do so by themseves (#5).

# gh-fzf v0.1.0

- `ghf` and `glabf` extends `gh` and `glab`, respectively.
- `ghf` and `glabf` gains the `fzf` sub-subcommands
  which performs fuzzy selection on the `list` sub-subcommands.
- `ghf` and `glabf` peforms fuzzy selection on the `list`,
  and view the result on the web,
  i.e. `ghf repo` is equivalent of `ghf repo fzf | ghf repo view --web'

