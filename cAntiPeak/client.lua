 --╔══════════════════════════════════════════════════╗--
---║                    ©cato.dev                     ║---
 --╚══════════════════════════════════════════════════╝--

CheckDistance = 15.0
DrawDot = true
DotSize = 0.03
DotColor = {255, 0, 0, 0.2}

PlaySound = true -- play a sound if player tryes to shoot
IgnoredMaterials = {
    244521486, -- glas
}

------------------------------------------< code >------------------------------------------

CreateThread(function()
    while true do
        local sleep = 200

        local currentWeapon = GetCurrentPedWeaponEntityIndex(PlayerPedId())
        if currentWeapon > 0 and IsPlayerFreeAiming(PlayerId()) then
            sleep = 1
            local start, fin = GetCoordsInFrontOfCam(0, 500)

            hitPos = GetCrosshairAiming()
            WhitPos = GetWeaponAiming()

            if not (hitPos == vector3(0, 0, 0)) then
                if #(start - WhitPos) < CheckDistance then
                    local ignore = false
                    for _, i in pairs(IgnoredMaterials) do
                        if material == i then
                            ignore = true
                        end
                    end
                    if #(hitPos - WhitPos) > 0.5 and not ignore then
                        if DrawDot then
                            DrawSphere(WhitPos.x, WhitPos.y, WhitPos.z, DotSize, DotColor[1], DotColor[2], DotColor[3], DotColor[4])
                        end
                        DisablePlayerFiring(PlayerPedId(), true)
                        DisableControlAction(0, 106, true)
                        if IsDisabledControlJustPressed(2, 24) and PlaySound then
                            PlaySoundFrontend(-1, "5_Second_Timer", "DLC_HEISTS_GENERAL_FRONTEND_SOUNDS", false) 
                        end
                    end
                end
            end
        end

        Wait(sleep)
    end
end)

function GetCrosshairAiming()
    local ret = nil
    local start, fin = GetCoordsInFrontOfCam(0, 500)
    local _, _, hitPos1, _, _, material1 = GetShapeTestResultIncludingMaterial(StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, 1, PlayerPedId(), 1))
    local _, _, hitPos2, _, _, material2 = GetShapeTestResultIncludingMaterial(StartShapeTestRay(start.x, start.y, start.z, fin.x, fin.y, fin.z, 16, PlayerPedId(), 1))
    if #(hitPos1 - start) < #(hitPos2 - start) then
        ret = hitPos1
    else
        ret = hitPos2
    end
    return ret
end

function GetWeaponAiming()
    local ret = nil
    local start, fin = GetCoordsInFrontOfCam(0, 500)
    local weaponPos = GetEntityCoords(GetCurrentPedWeaponEntityIndex(PlayerPedId()))
    local _, _, WhitPos1, _, Wmaterial, _ = GetShapeTestResultIncludingMaterial(StartShapeTestRay(weaponPos.x, weaponPos.y, weaponPos.z, hitPos.x, hitPos.y, hitPos.z, 1, PlayerPedId(), 1))
    local _, _, WhitPos2, _, Wmaterial, _ = GetShapeTestResultIncludingMaterial(StartShapeTestRay(weaponPos.x, weaponPos.y, weaponPos.z, hitPos.x, hitPos.y, hitPos.z, 16, PlayerPedId(), 1))
    if #(WhitPos1 - start) < #(WhitPos2 - start) then
        ret = WhitPos1
    else
        ret = WhitPos2
    end
    return ret
end

function GetCoordsInFrontOfCam(...)
    local coords = GetGameplayCamCoord()

    local direction = RotationToDirection()
    local inTable  = {...}
    local retTable = {}

    if (#inTable == 0) or (inTable[1] < 0.000001) then
        inTable[1] = 0.000001
    end

    for k,distance in pairs(inTable) do
        if (type(distance) == "number") then
            if (distance == 0) then
                retTable[k] = coords
            else
                retTable[k] = vector3(coords.x + (distance*direction.x),coords.y + (distance*direction.y),coords.z + (distance*direction.z))       
            end
        end
    end

    return table.unpack(retTable)
end

function RotationToDirection()
    local rot = GetGameplayCamRot(2);
  
    local rotZ = rot.z * (math.pi / 180.0)
    local rotX = rot.x * (math.pi / 180.0)
    local c = math.cos(rotX);
    local multXY = math.abs(c)
    local res = vector3( ( math.sin(rotZ) * -1 )*multXY, math.cos(rotZ)*multXY, math.sin(rotX) )

    return res
end