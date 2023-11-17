local function play()
    vim.fn.system({"playerctl", "play-pause"})
end
return {
    setup = function(cfg)
        vim.api.nvim_create_user_command("MusicPlay", play, {})
    end
}
