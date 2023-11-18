local function play_pause()
    vim.fn.system({"playerctl", "play-pause"})
end

-- Returns an array with {position, length} both in seconds.
local function progress(player)
    local time_str = vim.fn.system({"playerctl", "-p", player, "position"})
    local media_length_str = vim.fn.system({"playerctl", "-p", player, "metadata", "mpris:length"})
    -- The length is given in microseconds.
    return {time_str + 0.0, (media_length_str + 0.0) / 1000000}
end

local function artist(player)
    local ret = vim.fn.system({"playerctl", "-p", player, "metadata", "xesam:artist"})
    -- TODO: Error handling
    return ret
end

local function title(player)
    local ret = vim.fn.system({"playerctl", "-p", player, "metadata", "xesam:title"})
    -- TODO: Error handling
    return ret
end

local function album(player)
    local ret = vim.fn.system({"playerctl", "-p", player, "metadata", "xesam:album"})
    -- TODO: Error handling
    return ret
end

local function default_artist()
    return artist(DEFAULT_PLAYER)
    -- TODO: Error handling. e. g. player was closed.
end

local function default_title()
    return title(DEFAULT_PLAYER)
    -- TODO: Error handling. e. g. player was closed.
end

local function default_album()
    return album(DEFAULT_PLAYER)
    -- TODO: Error handling. e. g. player was closed.
end

local function bar(length, bg, dot)
    local prog = progress(DEFAULT_PLAYER)
end

local function get_players()

end

local function choose_default_player(prefs)
    local players = get_players()
    for pref in prefs do
        if type(pref) ~= "string" then
            error("pref array may only contain strings.", 2)
        end

        -- Choose first option where a player matches.
        for choice in players do
            if string.find(choice, pref) then
                DEFAULT_PLAYER = choice
                return choice
            end
        end
    end


end


return {
    setup = function(cfg)
        vim.api.nvim_create_user_command("MusicPlayPause", play_pause, {})
        vim.api.nvim_create_user_command("MusicProg", function()
            vim.print(progress("spotify"))
        end, {})

        if not cfg then
            cfg = {}
        end

        if type(cfg.player_prefs) == "string" then
            cfg.player_prefs = {cfg.player_prefs}
        elseif not cfg.player_prefs then
            cfg.player_prefs = {"spotify", "firefox"}
        end

        PLAYER_PREFS = cfg.player_prefs
    end,
    default_title = default_title,
    default_artist = default_artist,
    default_album = default_album,
}
