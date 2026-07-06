-- =============================================================================
-- 1. SETUP AND IMPORTS
-- =============================================================================
local tools = require("outils")
local factory = require("vaisseau")

-- =============================================================================
-- 2. GAME SETTINGS
-- =============================================================================
local SCREEN_WIDTH = 25
local SCREEN_HEIGHT = 10 

-- =============================================================================
-- 3. CREATING OBJECTS (INITIALIZATION)
-- =============================================================================
local player = factory.Vaisseau.creer()
player.x = 12            
player.y = SCREEN_HEIGHT 

local enemyList = {}
local playerLasers = {}
local enemyLasers = {}

for i = 1, 10 do
    local newEnemy = factory.Enemie.creer()
    newEnemy.x = i * 2  
    newEnemy.y = 2      
    table.insert(enemyList, newEnemy)
end

-- =============================================================================
-- 4. MAIN GAME LOOP
-- =============================================================================
while true do
    -- -------------------------------------------------------------------------
    -- Step A: RENDERING (We draw the game FIRST so the player can see it!)
    -- -------------------------------------------------------------------------
    tools.EffacerEcran()
    
    print("\n=== SPACE CONQUEROR ===")
    print("Player HP: " .. player.pointVie .. " | Enemies left: " .. #enemyList .. "\n")

    -- Matrix scan to draw the grid
    for y = 1, SCREEN_HEIGHT do
        local lineString = "" 
        
        for x = 1, SCREEN_WIDTH do
            local charToDraw = " . " 

            -- Check player
            if x == player.x and y == player.y then
                charToDraw = player.sprite
            end

            -- Check enemies
            for e = 1, #enemyList do
                if x == enemyList[e].x and y == enemyList[e].y then
                    charToDraw = enemyList[e].sprite
                end
            end

            -- Check player lasers
            for pl = 1, #playerLasers do
                if x == playerLasers[pl].x and y == playerLasers[pl].y then
                    charToDraw = " | "
                end
            end

            -- Check enemy lasers
            for el = 1, #enemyLasers do
                if x == enemyLasers[el].x and y == enemyLasers[el].y then
                    charToDraw = " * " 
                end
            end

            lineString = lineString .. charToDraw
        end
        print(lineString)
    end
    print("=======================\n")

    -- -------------------------------------------------------------------------
    -- Step B: CONTROLS & INPUT (Now we ask the player what to do)
    -- -------------------------------------------------------------------------
    print("COMMANDS: [q] Left | [d] Right | [f] Shoot | [Enter] Pass turn")
    io.write("Your action: ")
    local choice = io.read() 

    if choice == "q" then
        player.x = player.x - 1
    elseif choice == "d" then
        player.x = player.x + 1
    elseif choice == "f" then
        local newLaser = factory.Laser.creer(player.x, player.y - 1)
        table.insert(playerLasers, newLaser)
    end

    -- Keep player inside screen limits
    if player.x < 1 then player.x = 1 end
    if player.x > SCREEN_WIDTH then player.x = SCREEN_WIDTH end

    -- -------------------------------------------------------------------------
    -- Step C: UPDATE ENEMIES & ENEMY ACTIONS
    -- -------------------------------------------------------------------------
    for i = 1, #enemyList do
        local currentEnemy = enemyList[i]
        currentEnemy:deplacerDroite()
        
        if currentEnemy.x > SCREEN_WIDTH then
            currentEnemy.x = 1
        end

        -- AI SHOOTING: 5% chance to shoot
        if math.random(1, 100) <= 5 then
            local newEnemyLaser = factory.Laser.creer(currentEnemy.x, currentEnemy.y + 1)
            table.insert(enemyLasers, newEnemyLaser)
        end
    end

    -- -------------------------------------------------------------------------
    -- Step D: UPDATE LASERS POSITION
    -- -------------------------------------------------------------------------
    -- Player lasers move UP
    for i = #playerLasers, 1, -1 do
        local laser = playerLasers[i]
        laser.y = laser.y - 1 
        if laser.y < 1 then
            table.remove(playerLasers, i)
        end
    end

    -- Enemy lasers move DOWN
    for i = #enemyLasers, 1, -1 do
        local laser = enemyLasers[i]
        laser.y = laser.y + 1 
        if laser.y > SCREEN_HEIGHT then
            table.remove(enemyLasers, i)
        end
    end

    -- -------------------------------------------------------------------------
    -- Step E: COLLISIONS & DAMAGE DETECTION
    -- -------------------------------------------------------------------------
    -- Player lasers vs Enemies
    for l = #playerLasers, 1, -1 do
        local laser = playerLasers[l]
        for e = #enemyList, 1, -1 do
            local enemy = enemyList[e]
            
            if laser.x == enemy.x and laser.y == enemy.y then
                enemy.pointVie = enemy.pointVie - 1 
                table.remove(playerLasers, l)        
                
                if enemy.pointVie <= 0 then
                    table.remove(enemyList, e)
                end
                break 
            end
        end
    end

    -- Enemy lasers vs Player
    for l = #enemyLasers, 1, -1 do
        local laser = enemyLasers[l]
        if laser.x == player.x and laser.y == player.y then
            player.pointVie = player.pointVie - 10 
            table.remove(enemyLasers, l)           
            
            if player.pointVie <= 0 then
                print("\nGAME OVER! The aliens invaded Earth!")
                os.exit() 
            end
        end
    end

    -- Win Condition
    if #enemyList == 0 then
        print("\nVICTORY! You saved the galaxy!")
        os.exit()
    end
end