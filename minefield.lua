local tileBlueprint --- Blueprint
local jumpPadBlueprint --- Blueprint
local width --- number
local height --- number
local mineCount --- number

local function IncrementTile(minefield, x, y)
    -- Check that x,y within bounds of the minefield
    if x >= 0 and x < width and y >= 0 and y < height then
        current = minefield[x + y*width]

        -- Check that not a mine
        if current ~= -1 then
            minefield[x + y*width] = current + 1
        end
    end
end

local function PlaceMine(minefield)
    -- Keep trying random tile locations until we find one that doesn't have a mine on it
    local x, y
    while true do        
        x = math.floor(math.random() * width)
        y = math.floor(math.random() * height)

        if minefield[x + y*width] ~= -1 then
            -- No mine here yet!
            break
        end
    end

    -- Place the mine
    minefield[x + y*width] = -1

    -- Increment nearby mine counts
    IncrementTile(minefield, x - 1, y - 1)
    IncrementTile(minefield, x, y - 1)
    IncrementTile(minefield, x + 1, y - 1)

    IncrementTile(minefield, x - 1, y)
    IncrementTile(minefield, x + 1, y)

    IncrementTile(minefield, x - 1, y + 1)
    IncrementTile(minefield, x, y + 1)
    IncrementTile(minefield, x + 1, y + 1)
end

local function CreateMinefield()
    -- Store the minefield as flat array of numbers indicating the number of nearby mines. 
    -- We'll use -1 if the tile has a mine on it.
    minefield = {}

    -- First initialize the field to all zeros - we start with no mines
    for x = 0, width - 1 do
        for y = 0, height - 1 do
            minefield[x + y*width] = 0
        end
    end

    -- We won't allow more than half of all tiles to be mines
    mineCount = math.min(mineCount, width*height / 2)

    -- Now place 'mineCount' mines in the field
    for i = 1, mineCount do    
        PlaceMine(minefield)
    end

    return minefield
end

function OnCreate()
    local minefield = CreateMinefield()

    for i = 0, width - 1 do
        for j = 0, height - 1 do            
            local location = Vec3(5*i, 0, 5*j)
            local tile = World_SpawnBlueprint(tileBlueprint, location, Angles(), Self_GetId())

            local nearbyMineCount = minefield[i + j*width]
            local isMine = nearbyMineCount == -1
            World_QueueMessage("SetupTile", tile, { isMine=isMine, nearbyMineCount=nearbyMineCount })

            if i % 2 == 0 and j % 2 == 0 then
                World_SpawnBlueprint(jumpPadBlueprint, location + Vec3(2.5, 0, 2.5), Angles(), Self_GetId())
            end
        end
    end
end
