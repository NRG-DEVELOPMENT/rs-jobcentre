local QBCore, ESX = nil, nil
local PlayerData = {}
local isLoggedIn = false
local jobHistory = {}

-- Framework Detection and Initialization
local function InitializeFramework()
    if Config.Framework == 'qb' then
        QBCore = exports['qb-core']:GetCoreObject()
        
        RegisterNetEvent('QBCore:Client:OnPlayerLoaded')
        AddEventHandler('QBCore:Client:OnPlayerLoaded', function()
            PlayerData = QBCore.Functions.GetPlayerData()
            isLoggedIn = true
            TriggerServerEvent('rs-jobcentre:server:RequestJobHistory')
        end)
        
        RegisterNetEvent('QBCore:Client:OnPlayerUnload')
        AddEventHandler('QBCore:Client:OnPlayerUnload', function()
            isLoggedIn = false
            PlayerData = {}
        end)
        
        RegisterNetEvent('QBCore:Client:OnJobUpdate')
        AddEventHandler('QBCore:Client:OnJobUpdate', function(JobInfo)
            PlayerData.job = JobInfo
        end)
        
        if QBCore.Functions.GetPlayerData() ~= nil then
            PlayerData = QBCore.Functions.GetPlayerData()
            isLoggedIn = true
        end
    elseif Config.Framework == 'esx' then
        ESX = exports['es_extended']:getSharedObject()
        
        RegisterNetEvent('esx:playerLoaded')
        AddEventHandler('esx:playerLoaded', function(xPlayer)
            PlayerData = xPlayer
            isLoggedIn = true
            TriggerServerEvent('rs-jobcentre:server:RequestJobHistory')
        end)
        
        RegisterNetEvent('esx:setJob')
        AddEventHandler('esx:setJob', function(job)
            PlayerData.job = job
        end)
        
        RegisterNetEvent('esx:onPlayerLogout')
        AddEventHandler('esx:onPlayerLogout', function()
            isLoggedIn = false
            PlayerData = {}
        end)
        
        if ESX.GetPlayerData() ~= nil then
            PlayerData = ESX.GetPlayerData()
            isLoggedIn = true
        end
    end
end

-- Spawn Job Centre Peds
local jobCentrePeds = {}

local function SpawnJobCentrePeds()
    if Config.InteractionMethod ~= 'target_ped' then return end
    
    for i, pedConfig in ipairs(Config.JobCentrePeds) do
        RequestModel(GetHashKey(pedConfig.model))
        while not HasModelLoaded(GetHashKey(pedConfig.model)) do
            Wait(1)
        end
        
        local ped = CreatePed(4, GetHashKey(pedConfig.model), pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z - 1.0, pedConfig.coords.w, false, true)
        SetEntityHeading(ped, pedConfig.coords.w)
        FreezeEntityPosition(ped, true)
        SetEntityInvincible(ped, true)
        SetBlockingOfNonTemporaryEvents(ped, true)
        
        if pedConfig.scenario then
            TaskStartScenarioInPlace(ped, pedConfig.scenario, 0, true)
        end
        
        table.insert(jobCentrePeds, ped)
    end
end

-- Target System Setup
local function SetupTargetSystem()
    -- Target Points
    if Config.InteractionMethod == 'target_point' then
        if Config.Target == 'qb' then
            for _, location in pairs(Config.JobCentreLocations) do
                exports['qb-target']:AddBoxZone("jobcentre_".._, location.coords, 1.5, 1.5, {
                    name = "jobcentre_".._,
                    heading = 0,
                    debugPoly = false,
                    minZ = location.coords.z - 1,
                    maxZ = location.coords.z + 1,
                }, {
                    options = {
                        {
                            type = "client",
                            event = "rs-jobcentre:client:OpenJobCentre",
                            icon = "fas fa-briefcase",
                            label = "Open Job Centre",
                        },
                    },
                    distance = 2.5
                })
            end
        elseif Config.Target == 'ox' then
            for _, location in pairs(Config.JobCentreLocations) do
                exports.ox_target:addBoxZone({
                    coords = location.coords,
                    size = vector3(1.5, 1.5, 2.0),
                    rotation = 0,
                    debug = false,
                    options = {
                        {
                            name = "jobcentre_".._, 
                            icon = "fas fa-briefcase",
                            label = "Open Job Centre",
                            onSelect = function()
                                TriggerEvent('rs-jobcentre:client:OpenJobCentre')
                            end
                        }
                    }
                })
            end
        end
    end
    
    -- Target Peds
    if Config.InteractionMethod == 'target_ped' then
        if Config.Target == 'qb' then
            exports['qb-target']:AddTargetModel(GetPedModels(), {
                options = {
                    {
                        type = "client",
                        event = "rs-jobcentre:client:OpenJobCentre",
                        icon = "fas fa-briefcase",
                        label = "Talk to Job Agent",
                    },
                },
                distance = 2.5
            })
        elseif Config.Target == 'ox' then
            for _, pedConfig in ipairs(Config.JobCentrePeds) do
                exports.ox_target:addModel(GetHashKey(pedConfig.model), {
                    {
                        name = "jobcentre_ped",
                        icon = "fas fa-briefcase",
                        label = "Talk to Job Agent",
                        onSelect = function()
                            TriggerEvent('rs-jobcentre:client:OpenJobCentre')
                        end
                    }
                })
            end
        end
    end
end

-- Get all ped models from config
function GetPedModels()
    local models = {}
    for _, pedConfig in ipairs(Config.JobCentrePeds) do
        table.insert(models, pedConfig.model)
    end
    return models
end

-- Create Blips
local function CreateBlips()
    -- Create blips for target points
    if Config.InteractionMethod == 'target_point' then
        for _, location in pairs(Config.JobCentreLocations) do
            if location.blip.enabled then
                local blip = AddBlipForCoord(location.coords.x, location.coords.y, location.coords.z)
                SetBlipSprite(blip, location.blip.sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, location.blip.scale)
                SetBlipColour(blip, location.blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(location.blip.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
    
    -- Create blips for ped locations
    if Config.InteractionMethod == 'target_ped' then
        for _, pedConfig in ipairs(Config.JobCentrePeds) do
            if pedConfig.blip.enabled then
                local blip = AddBlipForCoord(pedConfig.coords.x, pedConfig.coords.y, pedConfig.coords.z)
                SetBlipSprite(blip, pedConfig.blip.sprite)
                SetBlipDisplay(blip, 4)
                SetBlipScale(blip, pedConfig.blip.scale)
                SetBlipColour(blip, pedConfig.blip.color)
                SetBlipAsShortRange(blip, true)
                BeginTextCommandSetBlipName("STRING")
                AddTextComponentString(pedConfig.blip.label)
                EndTextCommandSetBlipName(blip)
            end
        end
    end
end

-- NUI Callbacks
RegisterNUICallback('closeJobCentre', function(_, cb)
    SetNuiFocus(false, false)
    cb('ok')
end)

RegisterNUICallback('applyForJob', function(data, cb)
    local jobId = data.jobId
    
    if Config.Jobs[jobId] then
        -- Always set waypoint if location is available
        if Config.Jobs[jobId].jobLocation and Config.AutoSetWaypoint then
            SetNewWaypoint(Config.Jobs[jobId].jobLocation.x, Config.Jobs[jobId].jobLocation.y)
        end
        
        if Config.Jobs[jobId].autoAssign then
            -- Assign job and notify
            TriggerServerEvent('rs-jobcentre:server:AssignJob', jobId)
            TriggerEvent('rs-jobcentre:client:Notify', 'success', 'Job assigned! A waypoint has been set to your job location.')
        else
            -- Just set waypoint without assigning job
            TriggerEvent('rs-jobcentre:client:Notify', 'info', 'A waypoint has been set to the job location.')
        end
    else
        TriggerEvent('rs-jobcentre:client:Notify', 'error', 'This job does not exist.')
    end
    
    cb('ok')
end)

RegisterNUICallback('setWaypoint', function(data, cb)
    local jobId = data.jobId
    
    if Config.Jobs[jobId] and Config.Jobs[jobId].jobLocation then
        SetNewWaypoint(Config.Jobs[jobId].jobLocation.x, Config.Jobs[jobId].jobLocation.y)
        TriggerEvent('rs-jobcentre:client:Notify', 'success', 'Waypoint set to job location.')
    else
        TriggerEvent('rs-jobcentre:client:Notify', 'error', 'Could not set waypoint.')
    end
    
    cb('ok')
end)

-- Events
RegisterNetEvent('rs-jobcentre:client:OpenJobCentre')
AddEventHandler('rs-jobcentre:client:OpenJobCentre', function()
    if not isLoggedIn then return end
    
    local jobsData = {}
    for jobId, jobInfo in pairs(Config.Jobs) do
        table.insert(jobsData, {
            id = jobId,
            label = jobInfo.label,
            description = jobInfo.description,
            salary = jobInfo.salary,
            requirements = jobInfo.requirements,
            autoAssign = jobInfo.autoAssign,
            icon = jobInfo.icon
        })
    end
    
    SetNuiFocus(true, true)
    SendNUIMessage({
        action = "openJobCentre",
        jobs = jobsData,
        history = jobHistory,
        currentJob = PlayerData.job.name
    })
end)

RegisterNetEvent('rs-jobcentre:client:UpdateJobHistory')
AddEventHandler('rs-jobcentre:client:UpdateJobHistory', function(history)
    jobHistory = history
end)

RegisterNetEvent('rs-jobcentre:client:Notify')
AddEventHandler('rs-jobcentre:client:Notify', function(type, message)
    if Config.Framework == 'qb' then
        QBCore.Functions.Notify(message, type)
    elseif Config.Framework == 'esx' then
        ESX.ShowNotification(message)
    end
end)

-- Register command if configured
local function SetupCommand()
    if Config.InteractionMethod == 'command' then
        RegisterCommand(Config.Command, function()
            TriggerEvent('rs-jobcentre:client:OpenJobCentre')
        end, false)
        
        TriggerEvent('chat:addSuggestion', '/' .. Config.Command, 'Open the Job Centre')
    end
end

-- Cleanup function for peds when resource stops
AddEventHandler('onResourceStop', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        -- Delete all spawned peds
        for _, ped in ipairs(jobCentrePeds) do
            if DoesEntityExist(ped) then
                DeleteEntity(ped)
            end
        end
    end
end)

-- Initialization
AddEventHandler('onResourceStart', function(resourceName)
    if resourceName == GetCurrentResourceName() then
        InitializeFramework()
        SetupCommand()
        CreateBlips()
        SpawnJobCentrePeds()
        SetupTargetSystem()
    end
end)

Citizen.CreateThread(function()
    InitializeFramework()
    Wait(1000)
    SetupCommand()
    CreateBlips()
    SetupTargetSystem()
end)