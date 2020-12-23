# fzf-addons

Additional 20 commands and 40 mappings for FZF.

## Installation

Use your favorite vim plugin manager.

## Commands

- `:Brofiles`

Open an fzf buffer with previously opened buffers. Utilizies the built-in
var, `v:oldfiles`. Similar to the fzf command `:History`, but comes with
command completion.

- `:Mru`

Similar to Brofiles but with a split.

- `:ShowPlugins`

Show your loaded plugins in an FZF buffer.

*Note*: Requires vim-plug

## Mappings

**Note**: In order to use the mappings provided in this repository, Neovim must
be used as we exclusively use the `<Cmd>` mapping provided exclusively in
`nvim`. This is working on being refactored.

## See More

See the full documentation at [fzf-addons](doc/fzf-addons.txt).
