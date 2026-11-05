-- Locales.lua
--
-- Lightweight i18n loader for UiTTS.  Exposes a single global table
-- UiTTS_L that maps English source strings (the keys used throughout the
-- Lua code) to localised strings for the active client locale.
--
-- Missing keys fall back to the English key itself, so any locale file
-- can leave entries out and the addon still renders something sensible.
--
-- Locale files (Locales/enUS.lua, ptBR.lua, …) each begin with a
-- GetLocale() guard and populate UiTTS_L for the matching client.
-- They are listed in the .toc after this loader.

local L = setmetatable({}, {
    __index = function(t, k)
        -- Cache the fallback so repeated lookups are O(1) and the table
        -- gradually mirrors every key actually used by the addon.
        rawset(t, k, k)
        return k
    end,
})

UiTTS_L = L
