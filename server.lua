local player_avatars = {}

local default_picture
if Config.DefaultImg.type == 'url' then
      default_picture = Config.DefaultImg.link
elseif Config.DefaultImg.type == 'file' then
      default_picture = string.format("https://cfx-nui-%s/%s", GetCurrentResourceName(), Config.DefaultImg.link)
end


--[[ Frameworks]]
local QBCore, ESX
if Config.Framework == 'qb' then
      QBCore = exports['qb-core']:GetCoreObject()
elseif Config.Framework == 'esx' then
      if Config.ESX_VERSION == 'legacy' then
            ESX = exports['es_extended']:getSharedObject()
      elseif Config.ESX_VERSION == 'old' then
            TriggerEvent('esx:getSharedObject', function(obj) ESX = obj end)
      end
end



--[[ Functions ]]
function PlayerIdentifier(src)
      if Config.Framework and Config.CharacterExclusive then
            if Config.Framework == "qb" then
                  return QBCore.Functions.GetPlayer(src).PlayerData.citizenid
            elseif Config.Framework == "esx" then
                  return ESX.GetPlayerFromId(src).getIdentifier()
            end
      else
            return GetPlayerIdentifierByType(src, "license")
      end
end

function GetPlayerAvatar(src)
      local playerNname = GetPlayerName(src)
      if not playerNname then -- Player is not active
            print("Player is not active")
            return
      end

      if not playerNname then return end -- Player is not active

      local identifier = PlayerIdentifier(src)
      return player_avatars[identifier] or default_picture
end

function SavePlayerAvatar(identifier, avatar)
      if Config.UseMySQL then
            --[[ Check if player exists in database ]]
            local result = MySQL.Sync.fetchAll("SELECT * FROM luxu_avatars WHERE identifier = @identifier", {
                  ["@identifier"] = identifier
            })
            if not result[1] then
                  MySQL.Sync.execute(
                        "INSERT INTO luxu_avatars (identifier, avatar,history) VALUES (@identifier, @avatar,@history)", {
                              ["@identifier"] = identifier,
                              ["@avatar"] = avatar,
                              ["@history"] = json.encode({ { avatar = avatar, time = os.date("%d/%m/%Y %X") } })
                        })
            else
                  MySQL.Async.execute("UPDATE luxu_avatars SET avatar = @avatar WHERE identifier = @identifier", {
                        ["@avatar"] = avatar,
                        ["@identifier"] = identifier
                  })
            end
      else
            player_avatars[identifier] = avatar
            SaveResourceFile(GetCurrentResourceName(), "./database/player_avatars.json", json.encode(player_avatars), -1)
      end
end

-- If table saves full history, if not saves only the last avatar
function SaveAvatarHistory(identifier, data)
      if Config.UseMySQL then
            local result = MySQL.Sync.fetchAll("SELECT history FROM luxu_avatars WHERE identifier = @identifier", {
                  ["@identifier"] = identifier
            })
            if not result[1] then
                  local history = json.encode({ { avatar = data, time = os.date("%d/%m/%Y %X") } })
                  MySQL.Async.execute(
                        "INSERT INTO luxu_avatars (identifier, avatar, history) VALUES (@identifier,@avatar, @history)",
                        {
                              ["@identifier"] = identifier,
                              ["@avatar"] = data,
                              ["@history"] = history
                        })
            else
                  local history = json.decode(result[1].history)
                  if type(data) == 'table' then
                        history = data
                  else
                        -- Check if the avatar link is already in the history
                        for i = 1, #history do
                              if history[i].avatar == data then
                                    return
                              end
                        end
                        history[#history + 1] = { avatar = data, time = os.date("%d/%m/%Y %X") }
                  end
                  MySQL.Async.execute(
                        "UPDATE luxu_avatars SET history = @history WHERE identifier = @identifier", {
                              ["@history"] = json.encode(history),
                              ["@identifier"] = identifier
                        })
            end
            return true
      else
            local DB = LoadResourceFile(GetCurrentResourceName(), "./database/player_avatars_history.json")
            if not DB then
                  print("Couldn't find player_avatars_history.json, " .. identifier .. " old avatar was not saved.")
                  return false
            end
            local current_history = json.decode(DB)
            if not current_history[identifier] then
                  current_history[identifier] = {}
            end

            if type(data) == 'table' then
                  current_history[identifier] = data
            else
                  for i = 1, #current_history[identifier] do
                        if current_history[identifier][i].avatar == data then
                              return
                        end
                  end
                  local time = os.date("%d/%m/%Y %X")
                  table.insert(current_history[identifier], { avatar = data, time = time })
            end
            SaveResourceFile(GetCurrentResourceName(), "./database/player_avatars_history.json",
                  json.encode(current_history), -1)
            return true
      end
end

function UpdatePlayerAvatar(src, avatar)
      local playerNname = GetPlayerName(src)
      if not playerNname then -- Player is not active
            print("Player is not active")
            return
      end
      local identifier = PlayerIdentifier(src)
      player_avatars[identifier] = avatar
      SaveAvatarHistory(identifier, avatar)
      SavePlayerAvatar(identifier, avatar)
end

function LoadPlayerAvatars()
      if Config.UseMySQL then
            local result = MySQL.Sync.fetchAll("SELECT identifier, avatar FROM luxu_avatars")
            for i = 1, #result do
                  local identifier = result[i].identifier
                  local avatar = result[i].avatar
                  player_avatars[identifier] = avatar
                  print(json.encode(player_avatars))
            end
      else
            local data = LoadResourceFile(GetCurrentResourceName(), "./database/player_avatars.json")
            if data then
                  player_avatars = json.decode(data)
            else -- If the file doesn't exist
                  print("Couldn't find player_avatars.json, creating a new one, on next call...")
                  player_avatars = {}
            end
      end
end

--[[ Events ]]
RegisterNetEvent('LuxuAvatar:Server:SetAvatar', function(avatar)
      local identifer = PlayerIdentifier(source)
      player_avatars[identifer] = avatar
      SavePlayerAvatar(identifer, avatar)
      SaveAvatarHistory(identifer, avatar)
end)

RegisterNetEvent('LuxuAvatar:Server:ResetAvatar', function()
      local identifier = PlayerIdentifier(source)
      player_avatars[identifier] = default_picture
      SavePlayerAvatar(identifier, default_picture)
end)

RegisterNetEvent('LuxuAvatar:Server:DeleteAvatar', function(data)
      local identifier = PlayerIdentifier(source)
      local NewHistory = data.history
      SaveAvatarHistory(identifier, NewHistory)
end)

RegisterNetEvent('LuxuAvatar:Server:UseOldAvatar', function(avatar)
      local identifier = PlayerIdentifier(source)
      player_avatars[identifier] = avatar
      SavePlayerAvatar(identifier, avatar)
end)

--[[ Callbacks ]]
lib.callback.register("LuxuAvatar:Server:GetMyAvatar", function(source)
      local identifier = PlayerIdentifier(source)
      return player_avatars[identifier] or default_picture
end)

lib.callback.register("LuxuAvatar:Server:GetAllPlayersAvatars", function(source)
      return player_avatars
end)

lib.callback.register("LuxuAvatar:Server:GetAvatarHistory", function(source)
      local identifier = PlayerIdentifier(source)
      if Config.UseMySQL then
            local result = MySQL.Sync.fetchAll("SELECT * FROM luxu_avatars WHERE identifier = @identifier", {
                  ["@identifier"] = identifier
            })
            if not result[1] then
                  return {}
            else
                  return result[1].history and json.decode(result[1].history) or {}
            end
      else
            local DB = LoadResourceFile(GetCurrentResourceName(), "./database/player_avatars_history.json")
            if not DB then
                  print("Couldn't find player_avatars_history.json, " .. identifier .. " old avatar was not saved.")
                  return
            end
            local data = json.decode(DB)
            if not data[identifier] then
                  return {}
            else
                  return data[identifier]
            end
      end
end)

lib.callback.register("LuxuAvatar:Server:UpdateAvatarHistory", function(source, history)
      local identifier = PlayerIdentifier(source)
      SaveAvatarHistory(identifier, history)
end)


--[[ Exports ]]
exports("GetAllPlayersAvatars", function()
      return player_avatars
end);

exports("GetPlayerAvatar", GetPlayerAvatar)

exports("UpdatePlayerAvatar", UpdatePlayerAvatar)


--[[ First Time Load ]]
CreateThread(LoadPlayerAvatars)
