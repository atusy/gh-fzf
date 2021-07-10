# `ghf`, GitHub CLI with fuzzy finder.

[![MIT License](img/mit_license.svg)](https://opensource.org/licenses/MIT)

`ghf` = `gh` + `fzf`

## Features

1. Major subcommands gain `fzf` subsubcommand, which finds a topic of your interest.
   The return is the identifier (e.g., repository name), and can be piped to `ghf` or `gh`.
    ```bash
    ghf repo fzf | ghf repo clone
    ```
2. Major subcommands runs `fzf` subsubcommand by default instead of `--help` in `gh`.
   They then pipe the result to view on the web.
    ```bash
    # These are equivalent
    ghf issue
    ghf issue fzf | ghf issue view --web
    ```

## Installation

Requirements:

- [gh](https://cli.github.com/)
- [fzf](https://github.com/junegunn/fzf)

### For `bash` and `bash`-compatible shell users:

Add below in your `.bashrc` or `.zshrc`, or else.

```
source ghf.bash
```

### For Zinit users

Add below in your `.zshrc`

```
zinit load atusy/gh-fzf
```

## Tips

### Alias

```bash
alias gh=ghf
```

would be useful as `ghf` does not conflict with original features of `gh`.

