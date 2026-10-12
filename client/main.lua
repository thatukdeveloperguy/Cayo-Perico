local CAYO_MAP_HASH = GetHashKey('h4_fake_islandx')
local MAP_CAN_ZOOM_HASH = GetHashKey('MAP_CanZoom')

local nearCayo = false
local islandRadarLoaded = false
local cayoBlip = nil
local boundsBlips = {}

local CAYO_IPLS = {
    'h4_islandairstrip',
    'h4_islandairstrip_props',
    'h4_islandairstrip_propsb',
    'h4_islandairstrip_hangar_props',
    'h4_islandairstrip_doorsclosed',

    'h4_islandx',
    'h4_islandx_props',
    'h4_islandx_sea_mines',
    'h4_islandxtower',
    'h4_islandxtower_veg',
    'h4_islandxdock',
    'h4_islandxdock_props',
    'h4_islandxdock_props_2',
    'h4_islandxdock_water_hatch',
    'h4_islandx_maindock',
    'h4_islandx_maindock_props',
    'h4_islandx_maindock_props_2',
    'h4_islandxcanal_props',
    'h4_islandx_barrack_props',
    'h4_islandx_barrack_hatch',
    'h4_islandx_checkpoint',
    'h4_islandx_checkpoint_props',

    'h4_beach',
    'h4_beach_props',
    'h4_beach_bar_props',
    'h4_beach_props_party',
    'h4_beach_party',

    'h4_islandx_mansion',
    'h4_islandx_mansion_props',
    'h4_islandx_mansion_b',
    'h4_islandx_mansion_office',
    'h4_islandx_mansion_vault',
    'h4_islandx_mansion_lockup_01',
    'h4_islandx_mansion_lockup_02',
    'h4_islandx_mansion_lockup_03',
    'h4_islandx_mansion_guardfence',
    'h4_islandx_mansion_entrance_fence',
    'h4_islandx_mansion_b_side_fence',
    'h4_islandx_mansion_lights',
    'h4_mansion_gate_closed',

    'h4_aa_guns',
    'h4_underwater_gate_closed',

    'h4_islandx_terrain_01',
    'h4_islandx_terrain_01_lod',
    'h4_islandx_terrain_01_slod',
    'h4_islandx_terrain_02',
    'h4_islandx_terrain_02_lod',
    'h4_islandx_terrain_02_slod',
    'h4_islandx_terrain_03',
    'h4_islandx_terrain_03_lod',
    'h4_islandx_terrain_04',
    'h4_islandx_terrain_04_lod',
    'h4_islandx_terrain_04_slod',
    'h4_islandx_terrain_05',
    'h4_islandx_terrain_05_lod',
    'h4_islandx_terrain_05_slod',
    'h4_islandx_terrain_06',
    'h4_islandx_terrain_06_lod',
    'h4_islandx_terrain_06_slod',

    'h4_islandx_terrain_props_05_a',
    'h4_islandx_terrain_props_05_b',
    'h4_islandx_terrain_props_05_c',
    'h4_islandx_terrain_props_05_d',
    'h4_islandx_terrain_props_05_e',
    'h4_islandx_terrain_props_05_f',
    'h4_islandx_terrain_props_06_a',
    'h4_islandx_terrain_props_06_b',
    'h4_islandx_terrain_props_06_c',

    'h4_mph4_terrain_01',
    'h4_mph4_terrain_02',
    'h4_mph4_terrain_03',
    'h4_mph4_terrain_04',
    'h4_mph4_terrain_05',
    'h4_mph4_terrain_06',
    'h4_mph4_terrain_lod',
    'h4_mph4_island',
    'h4_mph4_island_lod',
    'h4_mph4_airstrip',
    'h4_mph4_beach',
    'h4_mph4_dock',
    'h4_mph4_mansion',
    'h4_mph4_mansion_b',
    'h4_mph4_wtowers',

    'h4_mph4_island_ne_placement',
    'h4_mph4_island_nw_placement',
    'h4_mph4_island_se_placement',
    'h4_mph4_island_sw_placement',
    'h4_mph4_island_placement',

    'h4_islandx_placement_01',
    'h4_islandx_placement_02',
    'h4_islandx_placement_03',
    'h4_islandx_placement_04',
    'h4_islandx_placement_05',
    'h4_islandx_placement_06',
    'h4_islandx_placement_07',
    'h4_islandx_placement_08',
    'h4_islandx_placement_09',
    'h4_islandx_placement_10'
}

for _, prefix in ipairs({'h4_ne_ipl', 'h4_nw_ipl', 'h4_se_ipl', 'h4_sw_ipl'}) do
    for i = 0, 9 do
        CAYO_IPLS[#CAYO_IPLS + 1] = ('%s_%02d'):format(prefix, i)
        CAYO_IPLS[#CAYO_IPLS + 1] = ('%s_%02d_lod'):format(prefix, i)
        CAYO_IPLS[#CAYO_IPLS + 1] = ('%s_%02d_slod'):format(prefix, i)
    end
end

local function setIslandHopper(enabled)
    Citizen.InvokeNative(0x9A9D1BA639675CF1, 'HeistIsland', enabled)
end

local function setIslandRadar(enabled)
    Citizen.InvokeNative(0x5E1460624D194A38, enabled)
    islandRadarLoaded = enabled
end

local function setIslandPathNodes(enabled)
    if Config.EnableCayoPathNodes then
        Citizen.InvokeNative(0xF74B1FFA4A15FBEA, enabled)
    end
end

local function requestCayoIPLs()
    if not Config.LoadCayoIPLs then return end
    for i = 1, #CAYO_IPLS do
        RequestIpl(CAYO_IPLS[i])
    end
end

local function setCayoEnvironment(enabled)
    setIslandPathNodes(enabled)

    if Config.EnableCayoPeds then
        SetScenarioGroupEnabled('Heist_Island_Peds', enabled)
        SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Zones', enabled, true)
        SetAmbientZoneListStatePersistent('AZL_DLC_Hei4_Island_Disabled_Zones', not enabled, true)
    end

    if Config.EnableCayoAudio then
        SetAudioFlag('PlayerOnDLCHeist4Island', enabled)
    end
end

local function createMapBlips()
    if Config.AddCayoBlip and not DoesBlipExist(cayoBlip) then
        local data = Config.CayoBlip
        cayoBlip = AddBlipForCoord(data.coords.x, data.coords.y, data.coords.z)
        SetBlipSprite(cayoBlip, data.sprite)
        SetBlipColour(cayoBlip, data.colour)
        SetBlipScale(cayoBlip, data.scale)
        SetBlipAsShortRange(cayoBlip, false)
        BeginTextCommandSetBlipName('STRING')
        AddTextComponentString(data.name)
        EndTextCommandSetBlipName(cayoBlip)
    end

    if Config.ExtendMapBounds and #boundsBlips == 0 then
        local anchors = {
            vector3(4700.0, -5145.0, 0.0),
            vector3(5943.568, -6272.115, 0.0)
        }

        for i = 1, #anchors do
            local p = anchors[i]
            local blip = AddBlipForCoord(p.x, p.y, p.z)
            SetBlipSprite(blip, 1)
            SetBlipScale(blip, 0.01)
            SetBlipAlpha(blip, 0)
            SetBlipAsShortRange(blip, false)
            boundsBlips[#boundsBlips + 1] = blip
        end
    end
end

local function removeMapBlips()
    if DoesBlipExist(cayoBlip) then
        RemoveBlip(cayoBlip)
        cayoBlip = nil
    end

    for i = 1, #boundsBlips do
        if DoesBlipExist(boundsBlips[i]) then
            RemoveBlip(boundsBlips[i])
        end
    end
    boundsBlips = {}
end

CreateThread(function()
    requestCayoIPLs()
    createMapBlips()

    setIslandRadar(false)
    setIslandHopper(false)

    if Config.DisableDeepOcean then
        SetDeepOceanScaler(0.0)
    end
end)

CreateThread(function()
    while true do
        local coords = GetEntityCoords(PlayerPedId())
        local shouldBeNear = #(coords - Config.CayoCenter) <= Config.IslandStateRadius

        if shouldBeNear ~= nearCayo then
            nearCayo = shouldBeNear

            if nearCayo then
                if Config.EnableIslandStateNearCayo then
                    setIslandHopper(true)
                end

                setCayoEnvironment(true)

                if Config.SwitchHUDRadarNearCayo and not IsPauseMenuActive() then
                    setIslandRadar(true)
                end
            else
                setIslandRadar(false)
                setCayoEnvironment(false)
                setIslandHopper(false)
            end
        end

        Wait(1000)
    end
end)

CreateThread(function()
    while true do
        local wait = 500

        if Config.ShowCayoOnPauseMap and IsPauseMenuActive() then
            local fullMap = PauseMenuIsContextActive(MAP_CAN_ZOOM_HASH)

            if fullMap and not IsMinimapInInterior() then
                if islandRadarLoaded then
                    setIslandRadar(false)
                end

                SetRadarAsExteriorThisFrame()
                SetRadarAsInteriorThisFrame(
                    CAYO_MAP_HASH,
                    4700.0,
                    -5145.0,
                    0,
                    0
                )

                wait = 0
            end
        elseif nearCayo and Config.SwitchHUDRadarNearCayo and not islandRadarLoaded then
            setIslandRadar(true)
            wait = 0
        end

        Wait(wait)
    end
end)

if Config.DebugCommand then
    RegisterCommand('cayomapdebug', function()
        local coords = GetEntityCoords(PlayerPedId())
        local dist = #(coords - Config.CayoCenter)

        print('^3[evan_cayo_map] ===== v1.2.1 DEBUG =====^7')
        print(('^3[evan_cayo_map]^7 Build: %s'):format(GetGameBuildNumber()))
        print(('^3[evan_cayo_map]^7 Position: %.2f, %.2f, %.2f'):format(coords.x, coords.y, coords.z))
        print(('^3[evan_cayo_map]^7 Cayo distance: %.2fm'):format(dist))
        print(('^3[evan_cayo_map]^7 nearCayo: %s'):format(tostring(nearCayo)))
        print(('^3[evan_cayo_map]^7 islandRadarLoaded: %s'):format(tostring(islandRadarLoaded)))
        print(('^3[evan_cayo_map]^7 pauseMenu: %s'):format(tostring(IsPauseMenuActive())))
        print(('^3[evan_cayo_map]^7 h4_islandx IPL active: %s'):format(tostring(IsIplActive('h4_islandx'))))
        print('^3[evan_cayo_map] ==========================^7')
    end, false)
end

AddEventHandler('onClientResourceStart', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    requestCayoIPLs()
    createMapBlips()

    -- Never force Cayo mode at resource start.
    setIslandRadar(false)
    setIslandHopper(false)
end)

AddEventHandler('onResourceStop', function(resourceName)
    if resourceName ~= GetCurrentResourceName() then return end

    setIslandRadar(false)
    setCayoEnvironment(false)
    setIslandHopper(false)
    removeMapBlips()

    if Config.DisableDeepOcean then
        SetDeepOceanScaler(1.0)
    end
end)
