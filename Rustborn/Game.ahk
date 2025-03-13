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
; Last Updated:   13/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\Direct2D\d2d1.ahk
#Include .\Robot.ahk
#Include .\BattleManager.ahk
#Include .\Debug.ahk
#Include .\SaveSystem.ahk
#Include .\ItemSystem.ahk
#Include .\Tutorial.ahk
#Include .\GameState.ahk
#Include .\GameRenderer.ahk
#Include .\GameInput.ahk

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
    renderer := ""
    inputHandler := ""
    
    ; Game data
    playerRobot := ""
    opponents := []
    currentOpponent := ""
    inventory := []
    itemInventory := []
    storyProgress := 0
    battleManager := ""
    saveSystem := ""
    itemSystem := ""
    
    ; Menu properties
    selectedMenuOption := 1  ; 1 = New Game, 2 = Load Game, 3 = Settings, 4 = Exit
    
    ; Animation properties
    frameCount := 0
    lastFrameTime := 0
    fps := 0
    
    ; Notification properties
    notification := ""
    
    ; Tutorial properties
    tutorialManager := ""
    
    ; Settings properties
    showSettings := false
    selectedSettingsOption := 1
    cheatModeEnabled := true
    
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
        
        ; Initialize save system
        this.saveSystem := SaveSystem()
        
        ; Initialize item system
        this.itemSystem := ItemSystem()
        
        ; Add some starter items
        this.itemSystem.addRandomItem(this)
        this.itemSystem.addRandomItem(this)
        
        ; Initialize tutorial manager
        this.tutorialManager := TutorialManager()
        
        ; Initialize renderer
        this.renderer := GameRenderer(this)
        
        ; Initialize input handler
        this.inputHandler := GameInput(this)
        
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
        this.battleManager := BattleManager(this.playerRobot, this.currentOpponent, this)
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
            this.battleManager := BattleManager(this.playerRobot, this.currentOpponent, this)
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
            
            ; Add a random item as reward
            if (this.itemSystem) {
                itemResult := this.itemSystem.addRandomItem(this)
                if (itemResult.success) {
                    Debug("Added " itemResult.item.name " to inventory", "SUCCESS")
                    this.showNotification("Found " itemResult.item.name)
                }
            }
            
            ; Progress story
            this.storyProgress++
            this.events.trigger("storyProgress", this.storyProgress)
            
            ; Auto-save the game after winning a battle
            if (this.saveSystem) {
                this.saveSystem.autoSave(this)
                Debug("Auto-saved game after battle victory", "SUCCESS")
            }
            
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
    SaveGame(slot := 1, *) {
        ; Save game to specified slot
        success := this.saveSystem.saveGame(this, slot)
        
        if (success) {
            Debug("Game saved to slot " slot, "SUCCESS")
            
            ; Show save notification
            this.showNotification("Game saved to slot " slot)
        } else {
            Debug("Failed to save game to slot " slot, "ERROR")
            
            ; Show error notification
            this.showNotification("Failed to save game", 0xFFFF0000)
        }
        
        return success
    }
    
    ; Load game
    LoadGame(slot := 1, *) {
        ; Load game from specified slot
        if (!this.saveSystem.saveExists(slot)) {
            Debug("No save found in slot " slot, "WARN")
            
            ; Show notification
            this.showNotification("No save found in slot " slot, 0xFFFFAA00)
            return false
        }
        
        success := this.saveSystem.loadGame(this, slot)
        
        if (success) {
            Debug("Game loaded from slot " slot, "SUCCESS")
            
            ; Show load notification
            this.showNotification("Game loaded from slot " slot)
            
            ; Update UI state
            this.ChangeState(this.currentState)
        } else {
            Debug("Failed to load game from slot " slot, "ERROR")
            
            ; Show error notification
            this.showNotification("Failed to load game", 0xFFFF0000)
        }
        
        return success
    }
    
    ; Show notification
    showNotification(message, color := 0xFF00FF00, duration := 2000) {
        ; Store notification data
        this.notification := {
            message: message,
            color: color,
            startTime: A_TickCount,
            duration: duration
        }
        
        ; Notification will be shown in Draw method
        Debug("Showing notification: " message, "INFO")
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
        this.renderer.Draw()
    }
    
    ; Update game state
    Update() {
        ; Update tutorial if enabled
        if (this.tutorialManager) {
            this.tutorialManager.update(this.currentState, this)
        }
        
        ; Apply cheat mode if enabled
        if (this.cheatModeEnabled && this.playerRobot) {
            ; Set player attack to 1000 when cheat mode is enabled
            this.playerRobot.attack := 1000
        }
        
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
        } else if (this.currentState = GameState.SETTINGS) {
            ; Update settings screen
        } else if (this.currentState = GameState.GAME_OVER) {
            ; Update game over screen
        } else if (this.currentState = GameState.VICTORY) {
            ; Update victory screen
        } else {
            Debug("Unknown state in Update: " this.currentState, "ERROR")
        }
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
