# Luxu Avatars

[Preview](https://www.youtube.com/watch?v=aFrsELRVuJA)

## What is this 🤔?

This FiveM resource enables developers to consolidate all player avatars in one central location.

## Why do I need this 🤨?

An increasing number of resources include player profile pictures and store them in unique ways, which can create challenges in accessing them for other resources.

## How does it work 🦊?

This resource addresses this issue by providing a dedicated script that allows players to change their profile picture. This change will synchronize with all other resources that leverage these exports, making it easier and more efficient to manage player avatars.

## Contribute and make it better 🌐

This will only be as good as the community wants it to be.
Consider contributing with code on github.

## [Dependencies]

- [ox_lib](https://github.com/overextended/ox_lib/releases/)

## [Installation]

- Create a folder named `LuxuAvatars`
- Place everything inside
- Copy `LuxuAvatars` to your resources folder.

## [Exports]

Client

```lua
-- Get Player Avatar | returns string or nil
exports.LuxuAvatars:GetCurrentPlayerAvatar()
-- Get All Players Avatars | returns table or nil
exports.LuxuAvatars:GetAllPlayersAvatars()
```

Server

```lua
-- Get Player Avatar | returns string or nil
exports.LuxuAvatars:GetPlayerAvatar(playerSRC)
-- Get All Players Avatars | returns table or nil
exports.LuxuAvatars:GetAllPlayersAvatars()
-- Update Player Avatar
exports.LuxuAvatars:UpdatePlayerAvatar(playerSRC,avatar)
```

## [Config]

```lua
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
```

## [Optional SQL]

```sql
CREATE TABLE `luxu_avatars` (
      `key` int(11) NOT NULL AUTO_INCREMENT,
      `identifier` varchar(100) NOT NULL,
      `avatar` varchar(255) NOT NULL,
      `history` LONGTEXT NOT NULL DEFAULT '{}',
      PRIMARY KEY (`key`)
) ENGINE=InnoDB  DEFAULT CHARSET=UTF8;
```

## Links 🔗

- Tebex 😊 | Buy it and Support me (Access to customer support and other benefits): https://fivem.luxu.gg/package/5621659
- Discord: https://discord.gg/luxu
