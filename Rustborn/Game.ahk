;==================================================================================================================
; Robot Battle Game
;==================================================================================================================
; Description:    A turn-based robot battle game set in an alien wasteland
;                 Players customize their robot with parts salvaged from defeated opponents
;
; Features:       - Turn-based combat system
;                 - Robot customization with salvageable parts
;                 - Special abilities with elemental effects
;                 - Story progression with multiple opponents
;                 - Save/load functionality
;
; Usage:          Run the script to start the game
;
; Hotkeys:        Space - Confirm/Select
;                 Escape - Back/Menu
;                 Arrow Keys - Navigate
;                 F5 - Save Game
;                 F9 - Load Game
;
; Dependencies:   - AutoHotkey v2.0
;                 - D2D1.ahk library
;
; Author:         CasperHarkin
; Version:        0.1.0
; Last Updated:   12/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\Direct2D\d2d1.ahk
#Include Robot.ahk
#Include BattleManager.ahk
#Include Debug.ahk

; ==================== Game States ====================
class GameState {
    static MAIN_MENU := "MAIN_MENU"
    static STORY := "STORY"
    static ROBOT_CUSTOMIZATION := "ROBOT_CUSTOMIZATION"
    static BATTLE_SELECTION := "BATTLE_SELECTION"
    static BATTLE := "BATTLE"
    static INVENTORY := "INVENTORY"
    static GAME_OVER := "GAME_OVER"
    static VICTORY := "VICTORY"
}

; ==================== Robot Battle Game Class ====================
class RobotBattleGame {
    ; Game properties
    width := 1024
    height := 768
    title := "Robot Battle"
    currentState := GameState.MAIN_MENU
    
    ; Game objects
    d2d := ""
    myGui := ""
    events := ""
    
    
    ; Game data
    playerRobot := ""
    opponents := []
    currentOpponent := ""
    inventory := []
    storyProgress := 0
    battleManager := ""
    
    ; Menu properties
    selectedMenuOption := 1  ; 1 = New Game, 2 = Load Game, 3 = Exit
    
    ; Animation properties
    frameCount := 0
    lastFrameTime := 0
    fps := 0
    
    ; Constructor
    __New() {
        ; Create GUI window
        this.myGui := Gui("+AlwaysOnTop +Resize", this.title)
        this.myGui.OnEvent("Size", ObjBindMethod(this, "OnResize"))
        this.myGui.OnEvent("Close", ObjBindMethod(this, "OnExit"))
        this.myGui.Show("w" this.width " h" this.height)
        
        ; Initialize D2D1 instance
        this.d2d := D2D1(this.myGui.hwnd, 0, 0, this.width, this.height)
        
        ; Initialize event system
        this.events := D2D1EventSystem()
        
        ; Register event handlers
        this._registerEventHandlers()
        
        ; Initialize game data
        this._initializeGameData()
        
        ; Set up hotkeys
        this._configureHotkeys()
        
        ; Set up game timer (60 FPS)
        this.lastFrameTime := A_TickCount
        SetTimer(ObjBindMethod(this, "GameLoop"), 16)
    }
    
    ; ==================== Initialization Functions ====================
    
    ; Initialize game data
    _initializeGameData() {
        ; Create player robot
        this.playerRobot := Robot("Player")
        this.playerRobot.description := "Your customized robot"
        
        ; Equip basic parts
        this.playerRobot.equipPart("head", RobotPart("head", "Basic Scanner", "poor", {accuracy: 5, critChance: 2}, ""))
        this.playerRobot.equipPart("torso", RobotPart("torso", "Basic Chassis", "poor", {health: 80, defense: 10}, ""))
        this.playerRobot.equipPart("leftArm", RobotPart("leftArm", "Basic Manipulator", "poor", {attack: 10, specialPower: 5}, ""))
        this.playerRobot.equipPart("rightArm", RobotPart("rightArm", "Basic Manipulator", "poor", {attack: 10, specialPower: 5}, ""))
        this.playerRobot.equipPart("leftLeg", RobotPart("leftLeg", "Basic Actuator", "poor", {evasion: 3, speed: 5}, ""))
        this.playerRobot.equipPart("rightLeg", RobotPart("rightLeg", "Basic Actuator", "poor", {evasion: 3, speed: 5}, ""))
        this.playerRobot.equipPart("powerCore", RobotPart("powerCore", "Basic Core", "poor", {energyRegen: 10, specialEfficiency: 5}, ""))
        
        ; Create opponent robots
        this._createOpponents()
        
        ; Set current opponent to the first one
        this.currentOpponent := this.opponents[1]
        
        ; Initialize battle manager
        this.battleManager := BattleManager(this.playerRobot, this.currentOpponent)
    }
    
    ; Register event handlers
    _registerEventHandlers() {
        ; Game state change events
        this.events.on("stateChange", ObjBindMethod(this, "_onStateChange"))
        
        ; Battle events
        this.events.on("battleStart", ObjBindMethod(this, "_onBattleStart"))
        this.events.on("battleEnd", ObjBindMethod(this, "_onBattleEnd"))
        
        ; Robot events
        this.events.on("partEquipped", ObjBindMethod(this, "_onPartEquipped"))
        this.events.on("partRemoved", ObjBindMethod(this, "_onPartRemoved"))
        
        ; Story events
        this.events.on("storyProgress", ObjBindMethod(this, "_onStoryProgress"))
    }
    
    ; Create opponent robots
    _createOpponents() {
        ; Scavenger - Acid specialist
        scavenger := Robot("Scavenger")
        scavenger.description := "Former maintenance robot repurposed for survival"
        scavenger.equipPart("head", RobotPart("head", "Scanner Unit", "good", {accuracy: 10, critChance: 5}, "acid"))
        scavenger.equipPart("torso", RobotPart("torso", "Reinforced Chassis", "good", {health: 100, defense: 15}, "acid"))
        scavenger.equipPart("leftArm", RobotPart("leftArm", "Utility Arm", "good", {attack: 15, specialPower: 10}, "acid"))
        scavenger.equipPart("rightArm", RobotPart("rightArm", "Acid Sprayer", "good", {attack: 20, specialPower: 15}, "acid"))
        scavenger.equipPart("leftLeg", RobotPart("leftLeg", "Hydraulic Leg", "poor", {evasion: 5, speed: 8}, ""))
        scavenger.equipPart("rightLeg", RobotPart("rightLeg", "Hydraulic Leg", "poor", {evasion: 5, speed: 8}, ""))
        scavenger.equipPart("powerCore", RobotPart("powerCore", "Efficiency Core", "good", {energyRegen: 15, specialEfficiency: 10}, "acid"))
        this.opponents.Push(scavenger)
        
        ; Guardian - Ice specialist
        guardian := Robot("Guardian")
        guardian.description := "Security robot protecting abandoned alien facility"
        guardian.equipPart("head", RobotPart("head", "Sensor Array", "good", {accuracy: 8, critChance: 3}, "ice"))
        guardian.equipPart("torso", RobotPart("torso", "Heavy Plating", "epic", {health: 150, defense: 25}, "ice"))
        guardian.equipPart("leftArm", RobotPart("leftArm", "Shield Generator", "good", {attack: 10, specialPower: 20}, "ice"))
        guardian.equipPart("rightArm", RobotPart("rightArm", "Cryo Cannon", "epic", {attack: 15, specialPower: 25}, "ice"))
        guardian.equipPart("leftLeg", RobotPart("leftLeg", "Heavy Treads", "good", {evasion: 3, speed: 5}, "ice"))
        guardian.equipPart("rightLeg", RobotPart("rightLeg", "Heavy Treads", "good", {evasion: 3, speed: 5}, "ice"))
        guardian.equipPart("powerCore", RobotPart("powerCore", "Cooling Core", "good", {energyRegen: 12, specialEfficiency: 15}, "ice"))
        this.opponents.Push(guardian)
        
        ; Hunter - Lightning specialist
        hunter := Robot("Hunter")
        hunter.description := "Reconnaissance unit that developed predatory behavior"
        hunter.equipPart("head", RobotPart("head", "Targeting System", "epic", {accuracy: 15, critChance: 10}, "lightning"))
        hunter.equipPart("torso", RobotPart("torso", "Lightweight Frame", "good", {health: 80, defense: 10}, "lightning"))
        hunter.equipPart("leftArm", RobotPart("leftArm", "Shock Blade", "good", {attack: 25, specialPower: 15}, "lightning"))
        hunter.equipPart("rightArm", RobotPart("rightArm", "Tesla Coil", "epic", {attack: 20, specialPower: 25}, "lightning"))
        hunter.equipPart("leftLeg", RobotPart("leftLeg", "Speed Boosters", "epic", {evasion: 15, speed: 20}, "lightning"))
        hunter.equipPart("rightLeg", RobotPart("rightLeg", "Speed Boosters", "epic", {evasion: 15, speed: 20}, "lightning"))
        hunter.equipPart("powerCore", RobotPart("powerCore", "Surge Core", "good", {energyRegen: 18, specialEfficiency: 12}, "lightning"))
        this.opponents.Push(hunter)
        
        ; Overlord - Shadow specialist (final boss)
        overlord := Robot("Overlord")
        overlord.description := "Master control unit that orchestrated the wasteland's current state"
        overlord.equipPart("head", RobotPart("head", "Neural Network", "epic", {accuracy: 20, critChance: 15}, "shadow"))
        overlord.equipPart("torso", RobotPart("torso", "Adaptive Plating", "epic", {health: 200, defense: 20}, "shadow"))
        overlord.equipPart("leftArm", RobotPart("leftArm", "Void Manipulator", "epic", {attack: 30, specialPower: 25}, "shadow"))
        overlord.equipPart("rightArm", RobotPart("rightArm", "Shadow Projector", "epic", {attack: 25, specialPower: 30}, "shadow"))
        overlord.equipPart("leftLeg", RobotPart("leftLeg", "Gravity Defier", "epic", {evasion: 20, speed: 15}, "shadow"))
        overlord.equipPart("rightLeg", RobotPart("rightLeg", "Gravity Defier", "epic", {evasion: 20, speed: 15}, "shadow"))
        overlord.equipPart("powerCore", RobotPart("powerCore", "Dark Matter Core", "epic", {energyRegen: 25, specialEfficiency: 25}, "shadow"))
        this.opponents.Push(overlord)
    }
    
    ; Configure hotkeys
    _configureHotkeys() {
        ; Navigation
        Hotkey("Space", ObjBindMethod(this, "OnConfirm"))
        Hotkey("Escape", ObjBindMethod(this, "OnBack"))
        Hotkey("Up", ObjBindMethod(this, "OnUp"))
        Hotkey("Down", ObjBindMethod(this, "OnDown"))
        Hotkey("Left", ObjBindMethod(this, "OnLeft"))
        Hotkey("Right", ObjBindMethod(this, "OnRight"))
        
        ; Save/Load
        Hotkey("F5", ObjBindMethod(this, "SaveGame"))
        Hotkey("F9", ObjBindMethod(this, "LoadGame"))
    }
    
    ; ==================== Event Handlers ====================
    
    ; State change event handler
    _onStateChange(newState) {
        Debug("State change event: " newState, "EVENT")
        this.currentState := newState
    }
    
    ; Battle start event handler
    _onBattleStart(playerRobot, enemyRobot) {
        Debug("_onBattleStart called", "BATTLE")
        Debug("playerRobot: " (playerRobot ? playerRobot.name : "null"), "BATTLE")
        Debug("enemyRobot: " (enemyRobot ? enemyRobot.name : "null"), "BATTLE")
        Debug("this.playerRobot: " (this.playerRobot ? this.playerRobot.name : "null"), "BATTLE")
        Debug("this.currentOpponent: " (this.currentOpponent ? this.currentOpponent.name : "null"), "BATTLE")
        
        ; Initialize battle
        try {
            Debug("Attempting to create BattleManager", "BATTLE")
            this.battleManager := BattleManager(this.playerRobot, this.currentOpponent)
            Debug("battleManager initialized: " (this.battleManager ? "Yes" : "No"), "BATTLE")
            if (this.battleManager) {
                Debug("battleManager.selectedAction = " this.battleManager.selectedAction, "BATTLE")
            }
        } catch as e {
            Debug("Error creating BattleManager: " e.Message, "ERROR")
        }
    }
    
    ; Battle end event handler
    _onBattleEnd(winner, loser) {
        ; Handle battle results
        if (winner = this.playerRobot) {
            ; Player won, salvage part from opponent
            this.SalvagePart(loser)
            
            ; Progress story
            this.storyProgress++
            this.events.trigger("storyProgress", this.storyProgress)
            
            ; Check if all opponents are defeated
            if (this.storyProgress >= this.opponents.Length) {
                this.ChangeState(GameState.VICTORY)
            } else {
                ; Set next opponent
                this.currentOpponent := this.opponents[this.storyProgress + 1]
                this.ChangeState(GameState.ROBOT_CUSTOMIZATION)
            }
        } else {
            ; Player lost
            this.ChangeState(GameState.GAME_OVER)
        }
    }
    
    ; Part equipped event handler
    _onPartEquipped(robot, partType, part) {
        ; Update robot stats
        robot.calculateStats()
    }
    
    ; Part removed event handler
    _onPartRemoved(robot, partType, part) {
        ; Update robot stats
        robot.calculateStats()
    }
    
    ; Story progress event handler
    _onStoryProgress(progress) {
        ; Update story elements based on progress
    }
    
    ; ==================== Input Handlers ====================
    ; Confirm/Select action
    OnConfirm(*) {
        Debug("OnConfirm called, currentState = " this.currentState, "INFO")
        Debug("selectedMenuOption = " this.selectedMenuOption, "INFO")
        
        ; Use if-else statements instead of switch
        if (this.currentState = GameState.MAIN_MENU) {
            Debug("MAIN_MENU case entered", "STATE")
            ; Handle main menu selection
            if (this.selectedMenuOption = 1) { ; New Game
                Debug("New Game option selected", "INFO")
                ; Reset game state if needed
                this.storyProgress := 0
                this._initializeGameData()
                Debug("About to change state to STORY", "STATE")
                this.ChangeState(GameState.STORY)
                Debug("Changed to STORY state", "STATE")
            } else if (this.selectedMenuOption = 2) { ; Load Game
                Debug("Load Game option selected", "INFO")
                ; Load game functionality (not implemented yet)
                ; For now, just show a message in the console
                Debug("Load Game functionality not implemented yet", "WARN")
            } else if (this.selectedMenuOption = 3) { ; Exit
                Debug("Exit option selected", "INFO")
                this.OnExit()
            }
        } else if (this.currentState = GameState.STORY) {
            Debug("STORY case entered", "STATE")
            this.ChangeState(GameState.ROBOT_CUSTOMIZATION)
            Debug("Changed to ROBOT_CUSTOMIZATION state", "STATE")
            OutputDebug("Changed to ROBOT_CUSTOMIZATION state")
        } else if (this.currentState = GameState.ROBOT_CUSTOMIZATION) {
            this.ChangeState(GameState.BATTLE_SELECTION)
        } else if (this.currentState = GameState.BATTLE_SELECTION) {
            this.ChangeState(GameState.BATTLE)
            ; Initialize battle when entering battle state
            this.events.trigger("battleStart", this.playerRobot, this.currentOpponent)
        } else if (this.currentState = GameState.BATTLE) {
            OutputDebug("BATTLE case entered in OnConfirm")
            ; Handle battle action selection
            if (this.battleManager) {
                OutputDebug("battleManager exists, selectedAction = " this.battleManager.selectedAction)
                ; Execute the selected action
                this.battleManager.executePlayerAction()
                
                ; Check if battle ended
                if (this.battleManager.battleEnded) {
                    OutputDebug("Battle ended, winner = " this.battleManager.winner.name)
                    ; Trigger battle end event
                    this.events.trigger("battleEnd", this.battleManager.winner,
                        this.battleManager.winner = this.playerRobot ? this.currentOpponent : this.playerRobot)
                }
            } else {
                OutputDebug("ERROR: battleManager is null in BATTLE state")
            }
        } else if (this.currentState = GameState.INVENTORY) {
            ; Handle inventory selection
        } else if (this.currentState = GameState.GAME_OVER) {
            this.ChangeState(GameState.MAIN_MENU)
        } else if (this.currentState = GameState.VICTORY) {
            this.ChangeState(GameState.MAIN_MENU)
        }
    }
    
    ; Back/Menu action
    OnBack(*) {
        OutputDebug("OnBack called, currentState = " this.currentState)
        
        if (this.currentState = GameState.MAIN_MENU) {
            this.OnExit()
        } else if (this.currentState = GameState.STORY) {
            this.ChangeState(GameState.MAIN_MENU)
        } else if (this.currentState = GameState.ROBOT_CUSTOMIZATION) {
            this.ChangeState(GameState.MAIN_MENU)
        } else if (this.currentState = GameState.BATTLE_SELECTION) {
            this.ChangeState(GameState.ROBOT_CUSTOMIZATION)
        } else if (this.currentState = GameState.BATTLE) {
            ; If showing special menu, cancel it
            if (this.battleManager && this.battleManager.showingSpecialMenu) {
                this.battleManager.cancelSpecialMenu()
            } else {
                ; Confirm exit battle
                this.ChangeState(GameState.BATTLE_SELECTION)
            }
        } else if (this.currentState = GameState.INVENTORY) {
            this.ChangeState(GameState.ROBOT_CUSTOMIZATION)
        }
    }
    
    ; Navigate up
    OnUp(*) {
        ; Handle navigation based on current state
        OutputDebug("OnUp called, currentState = " this.currentState)
        
        if (this.currentState = GameState.MAIN_MENU) {
            ; Navigate up in main menu
            if (this.selectedMenuOption > 1) {
                this.selectedMenuOption--
                OutputDebug("Selected menu option changed to " this.selectedMenuOption)
            }
        } else if (this.currentState = GameState.BATTLE) {
            OutputDebug("BATTLE case entered in OnUp")
            if (this.battleManager) {
                OutputDebug("Calling battleManager.navigateUp()")
                this.battleManager.navigateUp()
            } else {
                OutputDebug("ERROR: battleManager is null in OnUp")
            }
        }
    }
    
    ; Navigate down
    OnDown(*) {
        ; Handle navigation based on current state
        OutputDebug("OnDown called, currentState = " this.currentState)
        
        if (this.currentState = GameState.MAIN_MENU) {
            ; Navigate down in main menu
            if (this.selectedMenuOption < 3) {
                this.selectedMenuOption++
                OutputDebug("Selected menu option changed to " this.selectedMenuOption)
            }
        } else if (this.currentState = GameState.BATTLE) {
            OutputDebug("BATTLE case entered in OnDown")
            if (this.battleManager) {
                OutputDebug("Calling battleManager.navigateDown()")
                this.battleManager.navigateDown()
            } else {
                OutputDebug("ERROR: battleManager is null in OnDown")
            }
        }
    }
    
    ; Navigate left
    OnLeft(*) {
        ; Handle navigation based on current state
    }
    
    ; Navigate right
    OnRight(*) {
        ; Handle navigation based on current state
    }
    
    ; ==================== Game Functions ====================
    
    ; Change game state
    ChangeState(newState) {
        Debug("Changing state from " this.currentState " to " newState, "STATE")
        this.currentState := newState  ; Directly set the state
        this.events.trigger("stateChange", newState)  ; Also trigger the event
    }
    
    ; Salvage part from defeated robot
    SalvagePart(robot) {
        ; Get random part from defeated robot based on rarity weights
        partTypes := ["head", "torso", "leftArm", "rightArm", "leftLeg", "rightLeg", "powerCore"]
        randomPartType := partTypes[Random(1, partTypes.Length)]
        
        ; Get the part from the robot
        part := robot.getPart(randomPartType)
        
        ; Add to inventory
        if (part) {
            this.inventory.Push(part)
        }
    }
    
    ; Save game
    SaveGame(*) {
        ; Implement save functionality
    }
    
    ; Load game
    LoadGame(*) {
        ; Implement load functionality
    }
    
    ; ==================== Main Game Loop ====================
    
    ; Main game loop
    GameLoop(*) {
        ; Calculate FPS
        currentTime := A_TickCount
        frameTime := currentTime - this.lastFrameTime
        this.lastFrameTime := currentTime
        
        ; Update FPS counter every 10 frames
        if (Mod(this.frameCount, 10) == 0) {
            this.fps := Round(1000 / Max(frameTime, 1))
        }
        
        this.frameCount++
        
        ; Update game state
        this.Update()
        
        ; Draw the scene
        this.Draw()
    }
    
    ; Update game state
    Update() {
        ; Update based on current state
        if (this.currentState = GameState.MAIN_MENU) {
            ; Update main menu
        } else if (this.currentState = GameState.STORY) {
            ; Update story screen
            Debug("Updating STORY state", "INFO")
        } else if (this.currentState = GameState.ROBOT_CUSTOMIZATION) {
            ; Update customization screen
        } else if (this.currentState = GameState.BATTLE_SELECTION) {
            ; Update battle selection screen
        } else if (this.currentState = GameState.BATTLE) {
            ; Update battle
        } else if (this.currentState = GameState.INVENTORY) {
            ; Update inventory screen
        } else if (this.currentState = GameState.GAME_OVER) {
            ; Update game over screen
        } else if (this.currentState = GameState.VICTORY) {
            ; Update victory screen
        } else {
            Debug("Unknown state in Update: " this.currentState, "ERROR")
        }
    }
    
    ; Draw the scene
    Draw() {
        ; Check if dimensions are valid
        if (this.width <= 0 || this.height <= 0) {
            Debug("Invalid dimensions: width=" this.width ", height=" this.height, "ERROR")
            return
        }
        
        ; Check if D2D1 object is valid
        if (!this.d2d || this.d2d == "") {
            Debug("D2D1 object is not valid", "ERROR")
            return
        }
        
        try {
            ; Begin drawing
            this.d2d.beginDraw()
            
            ; Clear background with dark color
            this.d2d.fillRectangle(0, 0, this.width, this.height, 0xFF1A1A1A)
            
            ; Draw current state indicator (debug)
            this.d2d.drawText("Current State: " this.currentState, 10, 30, 12, 0xFFFFFFFF, "Arial", "w200 h20")
            
            ; Draw based on current state
            Debug("Drawing state: " this.currentState, "INFO")
        } catch as e {
            Debug("Error in Draw method: " e.Message, "ERROR")
            return
        }
        
        try {
            ; Use if-else statements instead of switch
            if (this.currentState = GameState.MAIN_MENU) {
                Debug("Drawing MAIN_MENU", "INFO")
                this.DrawMainMenu()
            } else if (this.currentState = GameState.STORY) {
                Debug("Drawing STORY", "INFO")
                this.DrawStoryScreen()
            } else if (this.currentState = GameState.ROBOT_CUSTOMIZATION) {
                Debug("Drawing ROBOT_CUSTOMIZATION", "INFO")
                this.DrawCustomizationScreen()
            } else if (this.currentState = GameState.BATTLE_SELECTION) {
                Debug("Drawing BATTLE_SELECTION", "INFO")
                this.DrawBattleSelectionScreen()
            } else if (this.currentState = GameState.BATTLE) {
                Debug("Drawing BATTLE", "INFO")
                this.DrawBattleScreen()
            } else if (this.currentState = GameState.INVENTORY) {
                Debug("Drawing INVENTORY", "INFO")
                this.DrawInventoryScreen()
            } else if (this.currentState = GameState.GAME_OVER) {
                Debug("Drawing GAME_OVER", "INFO")
                this.DrawGameOverScreen()
            } else if (this.currentState = GameState.VICTORY) {
                Debug("Drawing VICTORY", "INFO")
                this.DrawVictoryScreen()
            } else {
                Debug("Unknown state: " this.currentState, "ERROR")
            }
            
            ; Draw FPS counter (debug)
            this.d2d.drawText("FPS: " this.fps, 10, 10, 12, 0xFFFFFFFF, "Arial", "w100 h20")
            
            ; End drawing
            this.d2d.endDraw()
        } catch as e {
            Debug("Error in Draw method (state rendering): " e.Message, "ERROR")
        }
    }
    
    ; ==================== Screen Drawing Functions ====================
    
    ; Draw main menu
    DrawMainMenu() {
        ; Draw title
        this.d2d.drawText("ROBOT BATTLE", this.width/2 - 200, 150, 72, 0xFFFFFFFF, "Arial", "w400 h80 aCenter")
        
        ; Draw menu options with highlighting for selected option
        menuOptions := ["New Game", "Load Game", "Exit"]
        menuY := [300, 350, 400]
        
        ; Draw each menu option
        for i, option in menuOptions {
            ; Set color based on selection
            color := (i = this.selectedMenuOption) ? 0xFFFFFFFF : 0xFFAAAAAA
            
            ; Draw option text
            this.d2d.drawText(option, this.width/2 - 100, menuY[i], 36, color, "Arial", "w200 h40 aCenter")
            
            ; Draw selection indicator if this is the selected option
            if (i = this.selectedMenuOption) {
                this.d2d.fillRectangle(this.width/2 - 120, menuY[i] + 18, 10, 10, 0xFFFFFFFF)
            }
        }
        
        ; Draw instructions
        this.d2d.drawText("Up/Down - Navigate", this.width/2 - 150, this.height - 130, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        this.d2d.drawText("SPACE - Select", this.width/2 - 150, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
    }
    
    ; Draw story screen
    DrawStoryScreen() {
        OutputDebug("DrawStoryScreen called")
        
        ; Draw story title
        this.d2d.drawText("THE WASTELAND", this.width/2 - 200, 100, 48, 0xFFFFFFFF, "Arial", "w400 h60 aCenter")
        
        ; Draw story text based on progress
        storyText := "In a desolate alien wasteland, robots fight for survival and supremacy.`n`n"
                   . "You are a lone robot, scavenging for parts to improve yourself.`n`n"
                   . "Defeat other robots to salvage their parts and become stronger.`n`n"
                   . "Discover the secrets of the wasteland and why it became this way."
        
        this.d2d.drawText(storyText, this.width/2 - 300, 200, 24, 0xFFFFFFFF, "Arial", "w600 h300 aCenter")
        
        ; Draw continue prompt
        this.d2d.drawText("Press SPACE to continue", this.width/2 - 150, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        
        ; Draw debug info
        this.d2d.drawText("Current State: STORY", 10, 50, 14, 0xFFFFFFFF, "Arial", "w200 h20")
        this.d2d.drawText("Press SPACE to continue to ROBOT_CUSTOMIZATION", 10, 70, 14, 0xFFFFFFFF, "Arial", "w400 h20")
    }
    
    ; Draw customization screen
    DrawCustomizationScreen() {
        ; Draw screen title
        this.d2d.drawText("ROBOT CUSTOMIZATION", this.width/2 - 250, 50, 48, 0xFFFFFFFF, "Arial", "w500 h60 aCenter")
        
        ; Draw robot preview (placeholder)
        this.d2d.fillRectangle(this.width/2 - 100, 150, 200, 300, 0xFF444444)
        
        ; Draw equipped parts list
        this.d2d.drawText("Equipped Parts:", 50, 150, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        yPos := 190
        for partType in ["head", "torso", "leftArm", "rightArm", "leftLeg", "rightLeg", "powerCore"] {
            part := this.playerRobot.getPart(partType)
            partName := part ? part.name : "None"
            partRarity := part ? part.rarity : ""
            
            ; Set color based on rarity
            color := 0xFFAAAAAA  ; Default gray
            if (partRarity = "poor")
                color := 0xFFFFFFFF  ; White
            else if (partRarity = "good")
                color := 0xFF00AAFF  ; Blue
            else if (partRarity = "epic")
                color := 0xFFAA00FF  ; Purple
            
            this.d2d.drawText(partType ": " partName, 70, yPos, 18, color, "Arial", "w300 h24")
            yPos += 30
        }
        
        ; Draw stats
        this.d2d.drawText("Stats:", this.width - 350, 150, 24, 0xFFFFFFFF, "Arial", "w100 h30")
        
        yPos := 190
        stats := this.playerRobot.getStats()
        for statName, statValue in stats {
            this.d2d.drawText(statName ": " statValue, this.width - 330, yPos, 18, 0xFFFFFFFF, "Arial", "w200 h24")
            yPos += 30
        }
        
        ; Draw navigation options
        this.d2d.drawText("I - Inventory", 50, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        this.d2d.drawText("SPACE - Continue to Battle", this.width/2 - 150, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        this.d2d.drawText("ESC - Back to Menu", this.width - 250, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w200 h30 aRight")
    }
    
    ; Draw battle selection screen
    DrawBattleSelectionScreen() {
        ; Draw screen title
        this.d2d.drawText("BATTLE SELECTION", this.width/2 - 200, 50, 48, 0xFFFFFFFF, "Arial", "w400 h60 aCenter")
        
        ; Draw opponent info
        this.d2d.drawText("Next Opponent:", this.width/2 - 150, 150, 36, 0xFFFFFFFF, "Arial", "w300 h40 aCenter")
        this.d2d.drawText(this.currentOpponent.name, this.width/2 - 150, 200, 48, 0xFFFF0000, "Arial", "w300 h60 aCenter")
        this.d2d.drawText(this.currentOpponent.description, this.width/2 - 250, 260, 24, 0xFFFFFFFF, "Arial", "w500 h60 aCenter")
        
        ; Draw opponent preview (placeholder)
        this.d2d.fillRectangle(this.width/2 - 100, 330, 200, 300, 0xFF444444)
        
        ; Draw navigation options
        this.d2d.drawText("SPACE - Start Battle", this.width/2 - 150, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        this.d2d.drawText("ESC - Back to Customization", this.width - 300, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aRight")
    }
    
    ; Draw battle screen
    DrawBattleScreen() {
        ; Draw battle arena
        this.d2d.fillRectangle(0, this.height - 200, this.width, 200, 0xFF333333)  ; Ground
        
        ; Draw player robot (placeholder)
        this.d2d.fillRectangle(200, this.height - 350, 150, 250, 0xFF0000FF)
        
        ; Draw enemy robot (placeholder)
        this.d2d.fillRectangle(this.width - 350, this.height - 350, 150, 250, 0xFFFF0000)
        
        ; Draw health bars
        ; Player health
        this.d2d.fillRectangle(50, 50, 300, 30, 0xFF333333)
        
        ; Calculate health bar width with safety check
        playerHealthRatio := (this.playerRobot && this.playerRobot.maxHealth > 0)
            ? Max(0, Min(1, this.playerRobot.health / this.playerRobot.maxHealth))
            : 0
        healthBarWidth := 300 * playerHealthRatio
        
        ; Ensure width is positive
        if (healthBarWidth > 0)
            this.d2d.fillRectangle(50, 50, healthBarWidth, 30, 0xFF00FF00)
            
        this.d2d.drawText(this.playerRobot.name, 50, 20, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        ; Enemy health
        this.d2d.fillRectangle(this.width - 350, 50, 300, 30, 0xFF333333)
        
        ; Calculate enemy health bar width with safety check
        enemyHealthRatio := (this.currentOpponent && this.currentOpponent.maxHealth > 0)
            ? Max(0, Min(1, this.currentOpponent.health / this.currentOpponent.maxHealth))
            : 0
        enemyHealthBarWidth := 300 * enemyHealthRatio
        
        ; Ensure width is positive
        if (enemyHealthBarWidth > 0)
            this.d2d.fillRectangle(this.width - 350, 50, enemyHealthBarWidth, 30, 0xFFFF0000)
            
        this.d2d.drawText(this.currentOpponent.name, this.width - 350, 20, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        ; Draw energy bars
        ; Player energy
        this.d2d.fillRectangle(50, 90, 300, 15, 0xFF333333)
        
        ; Calculate energy bar width with safety check
        playerEnergyRatio := (this.playerRobot && this.playerRobot.maxEnergy > 0)
            ? Max(0, Min(1, this.playerRobot.energy / this.playerRobot.maxEnergy))
            : 0
        energyBarWidth := 300 * playerEnergyRatio
        
        ; Ensure width is positive
        if (energyBarWidth > 0)
            this.d2d.fillRectangle(50, 90, energyBarWidth, 15, 0xFF00FFFF)
        
        ; Enemy energy
        this.d2d.fillRectangle(this.width - 350, 90, 300, 15, 0xFF333333)
        
        ; Calculate enemy energy bar width with safety check
        enemyEnergyRatio := (this.currentOpponent && this.currentOpponent.maxEnergy > 0)
            ? Max(0, Min(1, this.currentOpponent.energy / this.currentOpponent.maxEnergy))
            : 0
        enemyEnergyBarWidth := 300 * enemyEnergyRatio
        
        ; Ensure width is positive
        if (enemyEnergyBarWidth > 0)
            this.d2d.fillRectangle(this.width - 350, 90, enemyEnergyBarWidth, 15, 0xFF00FFFF)
        
        ; Check if battle manager is initialized
        Debug("DrawBattleScreen: battleManager is " (this.battleManager ? "initialized" : "null"), "BATTLE")
        if (this.battleManager) {
            ; Draw turn indicator
            turnText := this.battleManager.isPlayerTurn ? "Your Turn" : "Enemy Turn"
            turnColor := this.battleManager.isPlayerTurn ? 0xFF00FF00 : 0xFFFF0000
            this.d2d.drawText(turnText, this.width / 2 - 50, 20, 24, turnColor, "Arial", "w100 h30 aCenter")
            
            ; Draw battle actions
            actionColors := Map(1, 0xFF444444, 2, 0xFF444444, 3, 0xFF444444, 4, 0xFF444444)
            actionColors[this.battleManager.selectedAction] := 0xFF666666  ; Highlight selected action
            Debug("Battle action colors: " actionColors[1] ", " actionColors[2] ", " actionColors[3] ", " actionColors[4], "BATTLE")
            Debug("Selected action: " this.battleManager.selectedAction, "BATTLE")
            
            ; Draw main battle actions
            this.d2d.fillRoundedRectangle(50, this.height - 150, 200, 50, 10, 10, actionColors.Get(1, 0xFF444444))
            this.d2d.drawText("Attack", 150, this.height - 150, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.d2d.fillRoundedRectangle(50, this.height - 90, 200, 50, 10, 10, actionColors.Get(2, 0xFF444444))
            this.d2d.drawText("Defend", 150, this.height - 90, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.d2d.fillRoundedRectangle(260, this.height - 150, 200, 50, 10, 10, actionColors.Get(3, 0xFF444444))
            this.d2d.drawText("Special", 360, this.height - 150, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.d2d.fillRoundedRectangle(260, this.height - 90, 200, 50, 10, 10, actionColors.Get(4, 0xFF444444))
            this.d2d.drawText("Item", 360, this.height - 90, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            ; Draw special menu if showing
            if (this.battleManager.showingSpecialMenu) {
                ; Draw special abilities menu
                this.d2d.fillRectangle(50, this.height - 350, 410, 190, 0xFF222222)
                this.d2d.drawText("Special Abilities", 50, this.height - 350, 24, 0xFFFFFFFF, "Arial", "w410 h30 aCenter")
                
                ; Draw available special abilities
                yPos := this.height - 310
                for i, special in this.battleManager.availableSpecials {
                    ; Highlight selected special
                    bgColor := (i = this.battleManager.selectedSpecial) ? 0xFF666666 : 0xFF444444
                    
                    ; Set color based on element type
                    textColor := 0xFFFFFFFF  ; Default white
                    if (special.elementType = "fire") {
                        textColor := 0xFFFF5555  ; Red
                    } else if (special.elementType = "ice") {
                        textColor := 0xFF55FFFF  ; Cyan
                    } else if (special.elementType = "lightning") {
                        textColor := 0xFFFFFF55  ; Yellow
                    } else if (special.elementType = "acid") {
                        textColor := 0xFF55FF55  ; Green
                    } else if (special.elementType = "shadow") {
                        textColor := 0xFFAA55FF  ; Purple
                    }
                    
                    ; Draw special ability
                    this.d2d.fillRectangle(60, yPos, 390, 30, bgColor)
                    this.d2d.drawText(special.name " (" special.energyCost " energy)", 70, yPos, 18, textColor, "Arial", "w300 h30")
                    this.d2d.drawText(special.description, 70, yPos + 20, 14, 0xFFAAAAAA, "Arial", "w300 h20")
                    
                    yPos += 60
                }
                
                ; Draw instructions
                this.d2d.drawText("Up/Down to select, SPACE to use, ESC to cancel", 50, this.height - 160, 14, 0xFFAAAAAA, "Arial", "w410 h20 aCenter")
            }
            
            ; Draw battle log
            this.d2d.fillRectangle(this.width - 350, this.height - 150, 300, 110, 0xFF222222)
            this.d2d.drawText("Battle Log", this.width - 350, this.height - 170, 18, 0xFFFFFFFF, "Arial", "w300 h20")
            
            ; Draw battle log entries
            yPos := this.height - 140
            for i, logEntry in this.battleManager.battleLog {
                this.d2d.drawText(logEntry, this.width - 340, yPos, 14, 0xFFFFFFFF, "Arial", "w280 h20")
                yPos += 20
            }
        } else {
            ; Draw default battle actions if battle manager not initialized
            this.d2d.fillRoundedRectangle(50, this.height - 150, 200, 50, 10, 10, 0xFF444444)
            this.d2d.drawText("Attack", 150, this.height - 150, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.d2d.fillRoundedRectangle(50, this.height - 90, 200, 50, 10, 10, 0xFF444444)
            this.d2d.drawText("Defend", 150, this.height - 90, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.d2d.fillRoundedRectangle(260, this.height - 150, 200, 50, 10, 10, 0xFF444444)
            this.d2d.drawText("Special", 360, this.height - 150, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.d2d.fillRoundedRectangle(260, this.height - 90, 200, 50, 10, 10, 0xFF444444)
            this.d2d.drawText("Item", 360, this.height - 90, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            ; Draw battle log
            this.d2d.fillRectangle(this.width - 350, this.height - 150, 300, 110, 0xFF222222)
            this.d2d.drawText("Battle Log", this.width - 350, this.height - 170, 18, 0xFFFFFFFF, "Arial", "w300 h20")
            this.d2d.drawText("Battle starting...", this.width - 340, this.height - 140, 14, 0xFFFFFFFF, "Arial", "w280 h100")
        }
    }
    
    ; Draw inventory screen
    DrawInventoryScreen() {
        ; Draw screen title
        this.d2d.drawText("INVENTORY", this.width/2 - 150, 50, 48, 0xFFFFFFFF, "Arial", "w300 h60 aCenter")
        
        ; Draw inventory items
        this.d2d.drawText("Salvaged Parts:", 50, 150, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        if (this.inventory.Length = 0) {
            this.d2d.drawText("No parts in inventory", 70, 190, 18, 0xFFAAAAAA, "Arial", "w300 h24")
        } else {
            yPos := 190
            for i, part in this.inventory {
                ; Set color based on rarity
                color := 0xFFAAAAAA  ; Default gray
                if (part.rarity = "poor")
                    color := 0xFFFFFFFF  ; White
                else if (part.rarity = "good")
                    color := 0xFF00AAFF  ; Blue
                else if (part.rarity = "epic")
                    color := 0xFFAA00FF  ; Purple
                
                this.d2d.drawText(part.type ": " part.name, 70, yPos, 18, color, "Arial", "w300 h24")
                yPos += 30
                
                ; Limit display to prevent overflow
                if (i >= 10) {
                    this.d2d.drawText("... and " (this.inventory.Length - 10) " more", 70, yPos, 18, 0xFFAAAAAA, "Arial", "w300 h24")
                    break
                }
            }
        }
        
        ; Draw navigation options
        this.d2d.drawText("ESC - Back to Customization", this.width - 300, this.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aRight")
    }
    
    ; Draw game over screen
    DrawGameOverScreen() {
        ; Draw game over message
        this.d2d.drawText("GAME OVER", this.width/2 - 200, 200, 72, 0xFFFF0000, "Arial", "w400 h80 aCenter")
        
        ; Draw defeat message
        this.d2d.drawText("Your robot was defeated by " this.currentOpponent.name, 
                         this.width/2 - 300, 300, 36, 0xFFFFFFFF, "Arial", "w600 h40 aCenter")
        
        ; Draw restart prompt
        this.d2d.drawText("Press SPACE to return to main menu", 
                         this.width/2 - 250, this.height - 200, 24, 0xFFFFFFFF, "Arial", "w500 h30 aCenter")
    }
    
    ; Draw victory screen
    DrawVictoryScreen() {
        ; Draw victory message
        this.d2d.drawText("VICTORY!", this.width/2 - 150, 200, 72, 0xFF00FF00, "Arial", "w300 h80 aCenter")
        
        ; Draw victory text
        victoryText := "You have defeated all opponents and uncovered the secrets of the wasteland.`n`n"
                     . "The Overlord has been defeated, but the wasteland remains.`n`n"
                     . "Perhaps there are more secrets to discover..."
        
        this.d2d.drawText(victoryText, this.width/2 - 300, 300, 24, 0xFFFFFFFF, "Arial", "w600 h200 aCenter")
        
        ; Draw restart prompt
        this.d2d.drawText("Press SPACE to return to main menu", 
                         this.width/2 - 250, this.height - 200, 24, 0xFFFFFFFF, "Arial", "w500 h30 aCenter")
    }
    
    ; ==================== Window Event Handlers ====================
    ; Handle window resize
    OnResize(thisGui, MinMax, wSize, hSize) {
        if (MinMax = -1) ; Window is minimized
            return
            
        ; Check if dimensions are valid
        if (wSize <= 0 || hSize <= 0) {
            Debug("Invalid resize dimensions: width=" wSize ", height=" hSize, "ERROR")
            return
        }
            
        ; Update dimensions
        this.width := wSize
        this.height := hSize
        
        ; Resize the D2D1 rendering area to match the new window dimensions
        if (this.d2d && this.d2d != "") {
            try {
                this.d2d.resize(0, 0, wSize, hSize)
                Debug("D2D1 rendering area resized to match window", "INFO")
            } catch as e {
                Debug("Error resizing D2D1 rendering area: " e.Message, "ERROR")
            }
        }
        
        Debug("Window resized: width=" wSize ", height=" hSize, "INFO")
    }
    
    ; Handle exit
    OnExit(*) {
        ; Clean up resources
        SetTimer(ObjBindMethod(this, "GameLoop"), 0)
        
        ; Disable hotkeys - use try/catch to handle nonexistent hotkeys
        try Hotkey("Space", "Off")
        try Hotkey("Escape", "Off")
        try Hotkey("Up", "Off")
        try Hotkey("Down", "Off")
        try Hotkey("Left", "Off")
        try Hotkey("Right", "Off")
        try Hotkey("F5", "Off")
        try Hotkey("F9", "Off")
        
        ; Exit application
        ExitApp()
    }
}

; Create and run the game
game := RobotBattleGame()
