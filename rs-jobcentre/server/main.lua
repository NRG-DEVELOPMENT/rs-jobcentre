local QBCore, ESX = nil, nil
local JobHistory = {}

-- Framework Detection and Initialization
local function InitializeFramework()
    if Config.Framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
    end
end

-- Initialize when resource starts
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitializeFramework()
        print('^2RS-JobCentre^7: Resource started successfully')
    end
end)

-- Get player identifier based on framework
local function GetPlayerIdentifier(source)
    if Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            return Player.PlayerData.citizenid
        end
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            return xPlayer.identifier
        end
    end
    return nil
end

-- Add job to player's history
local function AddJobToHistory(source, jobId)
    local identifier = GetPlayerIdentifier(source)
    if not identifier then return end
    
    if not JobHistory[identifier] then
        JobHistory[identifier] = {}
    end
    
    -- Add new job to history
    table.insert(JobHistory[identifier], 1, {
        jobId = jobId,
        jobName = Config.Jobs[jobId].label,
        timestamp = os.time()
    })
    
    -- Limit history size
    while #JobHistory[identifier] > Config.MaxJobHistory do
        table.remove(JobHistory[identifier])
    end
    
    -- Update client
    TriggerClientEvent('rs-jobcentre:client:UpdateJobHistory', source, JobHistory[identifier])
end

-- Assign job to player
local function AssignJobToPlayer(source, jobId)
    if Config.Framework == 'qb' then
        local Player = QBCore.Functions.GetPlayer(source)
        if Player then
            Player.Functions.SetJob(jobId, 0)
            return true
        end
    elseif Config.Framework == 'esx' then
        local xPlayer = ESX.GetPlayerFromId(source)
        if xPlayer then
            xPlayer.setJob(jobId, 0)
            return true
        end
    end
    return false
end

-- Events
RegisterNetEvent('rs-jobcentre:server:RequestJobHistory')
AddEventHandler('rs-jobcentre:server:RequestJobHistory', function()
    local src = source
    local identifier = GetPlayerIdentifier(src)
    
    if identifier and JobHistory[identifier] then
        TriggerClientEvent('rs-jobcentre:client:UpdateJobHistory', src, JobHistory[identifier])
    else
        TriggerClientEvent('rs-jobcentre:client:UpdateJobHistory', src, {})
    end
end)

RegisterNetEvent('rs-jobcentre:server:AssignJob')
AddEventHandler('rs-jobcentre:server:AssignJob', function(jobId)
    local src = source
    
    if not Config.Jobs[jobId] then
        TriggerClientEvent('rs-jobcentre:client:Notify', src, 'error', 'This job does not exist.')
        return
    end
    
    -- Only assign jobs that have autoAssign set to true
    if Config.Jobs[jobId].autoAssign then
        if AssignJobToPlayer(src, jobId) then
            AddJobToHistory(src, jobId)
            TriggerClientEvent('rs-jobcentre:client:Notify', src, 'success', 'You have been assigned to the ' .. Config.Jobs[jobId].label .. ' job.')
        else
            TriggerClientEvent('rs-jobcentre:client:Notify', src, 'error', 'Failed to assign job.')
        end
    end
end)

-- Simplified server-side logic without admin approval functionality
-- We're keeping the AssignJob event but removing the RequestJob event and admin command

-- Initialize framework when resource starts
InitializeFramework()