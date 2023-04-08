local default_picture
if Config.DefaultImg.type == 'url' then
      default_picture = Config.DefaultImg.link
elseif Config.DefaultImg.type == 'file' then
      default_picture = string.format("https://cfx-nui-%s/%s", GetCurrentResourceName(), Config.DefaultImg.link)
end
SetTimeout(500, function()
      SendNUIMessage({ type = 'default_avatar', data = { avatar = default_picture } })
end
)

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


if type(Config.ProfileMenuCommand) == 'string' then
      RegisterCommand(Config.ProfileMenuCommand, function(_, args)
            local avatar = GetCurrentPlayerAvatar()
            SetNuiFocus(true, true)
            SendNUIMessage({ type = "open", data = { avatar = avatar } })
      end)
end


-- Functions
function GetCurrentPlayerAvatar()
      local result = lib.callback.await('LuxuAvatar:Server:GetMyAvatar', false)
      return result
end

function GetAllPlayersAvatars()
      local result = lib.callback.await('LuxuAvatar:Server:GetAllPlayersAvatars', false)
      return result
end

-- NUI
RegisterNUICallback('close', function(data, cb)
      SetNuiFocus(false, false)
      cb(true)
end)

RegisterNuiCallback('UpdateAvatar', function(data, cb)
      local avatar = data.avatar
      TriggerServerEvent('LuxuAvatar:Server:SetAvatar', avatar)
      cb(true)
end)

RegisterNuiCallback('UseOldAvatar', function(data, cb)
      local avatar = data.avatar
      TriggerServerEvent('LuxuAvatar:Server:UseOldAvatar', avatar)
      cb(true)
end)

RegisterNUICallback('getAvatar', function(data, cb)
      local avatar = GetPlayerAvatar()
      cb(avatar)
end)

RegisterNUICallback("GetAvatarHistory", function(data, cb)
      local history = lib.callback.await('LuxuAvatar:Server:GetAvatarHistory', false)
      print(json.encode(history))
      cb(history)
end)

RegisterNUICallback("UpdateAvatarHistory", function(data, cb)
      local history = data.history
      lib.callback('LuxuAvatar:Server:UpdateAvatarHistory', false, history)
      cb(true)
end)

RegisterNuiCallback('resetAvatar', function(data, cb)
      TriggerServerEvent('LuxuAvatar:Server:ResetAvatar')
      cb(true)
end)

RegisterNUICallback('DeleteAvatar', function(data, cb)
      if data.history then
            TriggerServerEvent('LuxuAvatar:Server:DeleteAvatar', data)
      end
      cb(true)
end)

--[[ Exports ]]
exports('GetCurrentPlayerAvatar', GetCurrentPlayerAvatar)
exports('GetAllPlayersAvatars', GetAllPlayersAvatars)
