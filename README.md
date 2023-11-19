# 🎶 music.nvim — Control Your Media from Neovim
![Screenshot of lualine with the plugin showing lofi beats from YouTube](https://raw.githubusercontent.com/maxi0604/music.nvim-images/main/screenshot2.png)
![Screenshot of lualine with the plugin showing Burial - Archangel from Spotify](https://raw.githubusercontent.com/maxi0604/music.nvim-images/main/screenshot3.png)

**WIP:** This is very much in progress.

# Install

- Install `playerctl` from your distribution's repository.
- Add the following to your `lazy.nvim` configuration (or equivalent for other package managers)
```lua
{ 'maxi0604/music.nvim', config = true, lazy = false }
```
- Add the following to your configuration for `lualine.nvim` (or look at the code to figure out a custom configuration that looks nice for you)
```lua
sections = {
        lualine_a = {'mode'},
        lualine_b = {'branch', 'diff', 'diagnostics'},
        lualine_c = {'filename'},
        lualine_x = {"require('music').info()", 'encoding', 'fileformat', 'filetype'},
        lualine_y = {'progress'},
        lualine_z = {'location'}
      },
```

# TODO
- Better documentation
- More customization
- Player selection by user
- Basic commands
- Better performance - Move away from calling `playerctl`. Maybe call into `libdbus` via FFI.
- More robust error handling
- More platforms. Currently only works on Linux desktops or similar (More specifically those that use DBus)
