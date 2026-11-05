-- enUS / enGB base locale.  The English strings ARE the keys used in the
-- source, so no explicit translations are needed here — the fallback
-- metatable in Locales.lua returns the key as the value.
--
-- This file exists so the .toc can declare an enUS entry alongside the
-- other locales and so future additions to enUS-specific phrasing have a
-- home.

local locale = GetLocale()
if locale ~= "enUS" and locale ~= "enGB" then return end
-- intentionally empty: keys = values
