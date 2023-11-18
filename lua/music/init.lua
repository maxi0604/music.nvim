local NO_PLAYERS = "No players found"
local DEFAULT_PLAYER
local PLAYER_PREFS
local PREF_OFFSET = 0

local function play_pause()
    vim.fn.system({"playerctl", "play-pause"})
end

local function trim(str)
  return str:gsub("^%s*(.-)%s*$", "%1")
end

local function get_players()
    local list = vim.fn.system({"playerctl", "-l"})
    if list == NO_PLAYERS then
        return {}
    end

    -- gmatch returns an annoying iterator.
    -- Turn it into a list.
    local res = {}
    for v in string.gmatch(list, "[^\n]+") do
        res[#res+1] = v
    end
    return res
end

local function choose_default_player(prefs)
    local players = get_players()
    for _, pref in pairs(prefs) do
        if type(pref) ~= "string" then
            error("pref array may only contain strings.", 2)
        end

        -- Choose first option where a player matches.
        -- O(n²) is probably unavoidable here.
        for _, choice in pairs(players) do
            if string.find(choice, pref) then
                DEFAULT_PLAYER = choice
                return choice
            end
        end
    end
    return nil
end

local function get_checked(func, prefs)
    local ret
    if DEFAULT_PLAYER then
        ret = func(DEFAULT_PLAYER)
    end

    if not ret or ret == NO_PLAYERS then
        if choose_default_player(prefs) then
            -- Old player was closed but new default player was chosen. Try again.
            ret = func(DEFAULT_PLAYER)
            if ret == NO_PLAYERS then
                return nil
            end

            return ret
        else
            return nil
        end
    end
    return ret
end

-- Returns an array with {position, length} both in seconds.
local function progress(player)
    local time_str = vim.fn.system({"playerctl", "-p", player, "position"})
    local media_length_str = vim.fn.system({"playerctl", "-p", player, "metadata", "mpris:length"})

    if time_str == NO_PLAYERS or media_length_str == NO_PLAYERS then
        return NO_PLAYERS
    end
    -- The length is given in microseconds.
    return {time_str + 0.0, (media_length_str + 0.0) / 1000000}
end

local function unchecked_artist(player)
    return trim(vim.fn.system({"playerctl", "-p", player, "metadata", "xesam:artist"}))
end

local function unchecked_title(player)
     return trim(vim.fn.system({"playerctl", "-p", player, "metadata", "xesam:title"}))
end

local function unchecked_album(player)
    return trim(vim.fn.system({"playerctl", "-p", player, "metadata", "xesam:album"}))
end

local function default_artist()
    return get_checked(unchecked_artist, PLAYER_PREFS)
end

local function default_title()
    return get_checked(unchecked_title, PLAYER_PREFS)
end

local function default_album()
    return get_checked(unchecked_album, PLAYER_PREFS)
end

local ICONS = {
    { "spotify", '' },
    { "firefox", '󰈹' },
    {"plasma-browser-integration", '🌐'}
}

local function get_nf_icon(player)
    for key, icon in ICONS do
        if string.find(player, key) then
            return icon
        end
    end

    return "🎵"
end

local function bar(length, bg, dot)
    local prog = get_checked(progress, PLAYER_PREFS)
    if not prog then
        return nil
    end

    if not prog[1] or not prog[2] then
        return nil
    end

    local fraction = prog[1] / prog[2]

    local before = math.floor(fraction * 10)
    local after = length - before - 1

    local result = string.rep(bg, before) .. dot .. string.rep(bg, after)
    return result
end

return {
    setup = function(cfg)
        vim.api.nvim_create_user_command("MusicPlayPause", play_pause, {})
        vim.api.nvim_create_user_command("MusicProg", function()
            vim.print(progress("spotify"))
        end, {})
        vim.api.nvim_create_user_command("MusicTitle", function()
            vim.print(default_title())
        end, {})
        vim.api.nvim_create_user_command("MusicBar", function()
            vim.print(bar(10, '—', '⬤ '))
        end, {})
        vim.api.nvim_create_user_command("MusicPrintPlayer", function()
            vim.print(DEFAULT_PLAYER)
        end, {})
        if not cfg then
            cfg = {}
        end

        if type(cfg.player_prefs) == "string" then
            cfg.player_prefs = {cfg.player_prefs}
        elseif not cfg.player_prefs then
            cfg.player_prefs = {"spotify", "plasma"}
        end

        PLAYER_PREFS = cfg.player_prefs
    end,
    default_title = default_title,
    default_artist = default_artist,
    default_album = default_album,
    default_bar = function ()
        return bar(10, '⸺', '⬤') .. ' '
    end,
    default = function()
        return get_nf_icon(DEFAULT_PLAYER) .. ' ' .. default_album() ' - ' .. default_title() .. ' | ' .. bar(10, '⸺', '⬤') .. ' '
    end
}
