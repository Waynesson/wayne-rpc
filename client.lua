local QBCore = exports['qb-core']:GetCoreObject()
local PlayerData = {}
local currentServerInfo = {
    players = 0,
    maxPlayers = 0
}

-- Discord application ID (create one at https://discord.com/developers/applications)
local discordAppId = '1234567890' -- Replace with your Discord Application ID

local largeImageKey = 'logo'
local smallImageKey = 'wayne_shsf'

local updateInterval = 60000 
function GetCurrentServerInfo()
    local players = #GetActivePlayers()
    local maxPlayers = GetConvarInt('sv_maxclients', 48)
    return {players = players, maxPlayers = maxPlayers}
end

function FormatJob(job)
    if job then
        local jobLabel = job.label or job.name
        local gradeLabel = job.grade.name or ("Grade "..job.grade.level)
        return jobLabel .. " - " .. gradeLabel
    end
    return "Unemployed"
end

Citizen.CreateThread(function()
    while not NetworkIsPlayerActive(PlayerId()) or not QBCore do
        Citizen.Wait(100)
    end
    
    SetDiscordAppId(discordAppId)
    
    SetDiscordRichPresenceAsset(largeImageKey)
    SetDiscordRichPresenceAssetText('Oasis Gaming')
    
    SetDiscordRichPresenceAssetSmall(smallImageKey)
    SetDiscordRichPresenceAssetSmallText('Waynesson')
    
    SetDiscordRichPresenceAction(0, "Join Server", "https://cfx.re/join/7zzxla")
    SetDiscordRichPresenceAction(1, "Discord", "https://discord.gg/hammeddevelopments")
    
    StartRichPresenceUpdates()
end)

function StartRichPresenceUpdates()
    Citizen.CreateThread(function()
        while true do
            if QBCore.Functions.GetPlayerData() then
                PlayerData = QBCore.Functions.GetPlayerData()
            end
            
            currentServerInfo = GetCurrentServerInfo()
            
            UpdateRichPresence()
            
            Citizen.Wait(updateInterval)
        end
    end)
end

function UpdateRichPresence()
    if not PlayerData.charinfo then
        return
    end
    
    local playerId = GetPlayerServerId(PlayerId())
    local characterName = PlayerData.charinfo.firstname .. ' ' .. PlayerData.charinfo.lastname
    local jobInfo = FormatJob(PlayerData.job)
    local playerCount = currentServerInfo.players .. '/' .. currentServerInfo.maxPlayers
    
    SetRichPresence(characterName .. " | ID: " .. playerId)
    
    SetDiscordRichPresenceAssetText(jobInfo)
    
    SetDiscordRichPresenceAction(0, "Join Server (" .. playerCount .. " players)", "https://cfx.re/join/7zzxla")
    
    if GetConvarInt('developer', 0) == 1 then
        print('Discord RPC Updated: ' .. characterName .. ' | ' .. jobInfo .. ' | ' .. playerCount)
    end
end

RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
    PlayerData = QBCore.Functions.GetPlayerData()
    UpdateRichPresence()
end)

RegisterNetEvent('QBCore:Client:OnJobUpdate')
AddEventHandler('QBCore:Client:OnJobUpdate', function(job)
    PlayerData.job = job
    UpdateRichPresence()
end)