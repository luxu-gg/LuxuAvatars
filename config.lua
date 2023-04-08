Config = {}


Config.ProfileMenuCommand = "avatar" -- Command to open the profile menu, set to fale to disable

--[[ Default image path ]]
Config.DefaultImg = {
      type = 'file', -- "file" - File path, "url" - URL
      link = "/web/imgs/default.jpg"
}

Config.UseMySQL = true -- Set to true if you want to use MySQL instead of Local JSON files

--[[ Framework Exclusive ]]
-- These options only work if you have Config.Framework defined

Config.Framework = 'qb'          -- "qb" - QBCore, "esx" - ESX, false - None
Config.ESX_VERSION = "legacy"    -- "legacy" - ESX Legacy, "old" -- ESX

Config.CharacterExclusive = true -- Set to true if you want each player character to have their own avatar
