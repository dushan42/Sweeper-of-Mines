local flag = EntityId_Invalid --- EntityId
local mineBlueprint --- Blueprint
local number = EntityId_Invalid --- EntityId

local isFlagged = false
local isRevealed = false
local isMine = false
local nearbyMineCount = 9

function OnUse(message)
    if message.using then
        isFlagged = not isFlagged
        if flag ~= EntityId_Invalid then
            World_QueueMessage("Flag", flag, { value=isFlagged })
        end
    end
end

local function Reveal()
    isRevealed = true
    if isMine then
        local coords = Self_GetCoords()
        World_SpawnBlueprint(mineBlueprint, coords.origin + Vec3(0, 1, 0), coords:GetAngles())
        World_EndGame()
    else
        World_QueueMessage("SetDigit", number, { digit=nearbyMineCount })

        -- If we reveal a tile with no mines, it automatically reveals all nearby tiles
        if nearbyMineCount == 0 then
            local nearby = World_TestSphereOverlap(Self_GetCoords().origin, 6)
            for i = 1, #nearby do
                if nearby[i] ~= Self_GetId() then
                    World_QueueMessage("Reveal", nearby[i])
                end
            end
        end

    end
end

function OnReveal()
    if not isRevealed then
        Reveal()
    end
end

function OnTrigger(message)
    if message.enter and not isFlagged and not isRevealed then
        Reveal()
    end        
end

function OnSetupTile(message)
    isMine = message.isMine
    nearbyMineCount = message.nearbyMineCount
end
