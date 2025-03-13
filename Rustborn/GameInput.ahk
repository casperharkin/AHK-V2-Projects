;==================================================================================================================
; Game Input Handler
;==================================================================================================================
; Description:    Handles all input for the Rustborn game
;                 Processes keyboard input based on game state
;
; Features:       - State-based input handling
;                 - Hotkey configuration
;                 - Navigation controls
;
; Usage:          Include this file and use GameInput class methods
;
; Dependencies:   - AutoHotkey v2.0
;                 - GameState.ahk
;
; Author:         CasperHarkin
; Version:        0.1.0
; Last Updated:   13/03/2025
;==================================================================================================================

#Include GameState.ahk

; ==================== Game Input Handler Class ====================
class GameInput {
    ; Reference to game instance
    game := ""
    
    ; Constructor
    __New(gameInstance) {
        this.game := gameInstance
        
        ; Configure hotkeys
        this._configureHotkeys()
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
        Hotkey("F5", ObjBindMethod(this.game, "SaveGame"))
        Hotkey("F9", ObjBindMethod(this.game, "LoadGame"))
    }
    
    ; Confirm/Select action
    OnConfirm(*) {
        Debug("OnConfirm called, currentState = " this.game.currentState, "INFO")
        Debug("selectedMenuOption = " this.game.selectedMenuOption, "INFO")
        
        ; Use if-else statements instead of switch
        if (this.game.currentState = GameState.MAIN_MENU) {
            Debug("MAIN_MENU case entered", "STATE")
            ; Handle main menu selection
            if (this.game.selectedMenuOption = 1) { ; New Game
                Debug("New Game option selected", "INFO")
                ; Reset game state if needed
                this.game.storyProgress := 0
                this.game._initializeGameData()
                Debug("About to change state to STORY", "STATE")
                this.game.ChangeState(GameState.STORY)
                Debug("Changed to STORY state", "STATE")
            } else if (this.game.selectedMenuOption = 2) { ; Load Game
                Debug("Load Game option selected", "INFO")
                ; Check if any save files exist
                saveExists := false
                for slot in [1, 2, 3, 4, 5] {
                    if (this.game.saveSystem.saveExists(slot)) {
                        saveExists := true
                        break
                    }
                }
                
                if (saveExists) {
                    ; Load the first available save
                    for slot in [1, 2, 3, 4, 5] {
                        if (this.game.saveSystem.saveExists(slot)) {
                            this.game.LoadGame(slot)
                            break
                        }
                    }
                } else {
                    ; No save files found
                    this.game.showNotification("No save files found", 0xFFFFAA00)
                    Debug("No save files found", "WARN")
                }
            } else if (this.game.selectedMenuOption = 3) { ; Settings
                Debug("Settings option selected", "INFO")
                this.game.ChangeState(GameState.SETTINGS)
            } else if (this.game.selectedMenuOption = 4) { ; Exit
                Debug("Exit option selected", "INFO")
                this.game.OnExit()
            }
        } else if (this.game.currentState = GameState.STORY) {
            Debug("STORY case entered", "STATE")
            this.game.ChangeState(GameState.ROBOT_CUSTOMIZATION)
            Debug("Changed to ROBOT_CUSTOMIZATION state", "STATE")
            OutputDebug("Changed to ROBOT_CUSTOMIZATION state")
        } else if (this.game.currentState = GameState.ROBOT_CUSTOMIZATION) {
            this.game.ChangeState(GameState.BATTLE_SELECTION)
        } else if (this.game.currentState = GameState.BATTLE_SELECTION) {
            this.game.ChangeState(GameState.BATTLE)
            ; Initialize battle when entering battle state
            this.game.events.trigger("battleStart", this.game.playerRobot, this.game.currentOpponent)
        } else if (this.game.currentState = GameState.BATTLE) {
            OutputDebug("BATTLE case entered in OnConfirm")
            ; Handle battle action selection
            if (this.game.battleManager) {
                OutputDebug("battleManager exists, selectedAction = " this.game.battleManager.selectedAction)
                ; Execute the selected action
                this.game.battleManager.executePlayerAction()
                
                ; Check if battle ended
                if (this.game.battleManager.battleEnded) {
                    OutputDebug("Battle ended, winner = " this.game.battleManager.winner.name)
                    ; Trigger battle end event
                    this.game.events.trigger("battleEnd", this.game.battleManager.winner,
                        this.game.battleManager.winner = this.game.playerRobot ? this.game.currentOpponent : this.game.playerRobot)
                }
            } else {
                OutputDebug("ERROR: battleManager is null in BATTLE state")
            }
        } else if (this.game.currentState = GameState.INVENTORY) {
            ; Handle inventory selection
        } else if (this.game.currentState = GameState.SETTINGS) {
            ; Handle settings selection
            if (this.game.selectedSettingsOption = 1) { ; Tutorial toggle
                ; Toggle tutorial
                if (this.game.tutorialManager) {
                    this.game.tutorialManager.enabled := !this.game.tutorialManager.enabled
                }
            } else if (this.game.selectedSettingsOption = 2) { ; Super Attack toggle
                ; Toggle cheat mode
                this.game.cheatModeEnabled := !this.game.cheatModeEnabled
                
                ; Show notification
                if (this.game.cheatModeEnabled) {
                    this.game.showNotification("Super Attack Enabled!", 0xFFFF5500)
                } else {
                    this.game.showNotification("Super Attack Disabled", 0xFF00AAFF)
                }
            }
        } else if (this.game.currentState = GameState.GAME_OVER) {
            this.game.ChangeState(GameState.MAIN_MENU)
        } else if (this.game.currentState = GameState.VICTORY) {
            this.game.ChangeState(GameState.MAIN_MENU)
        }
        
        ; Progress tutorial if active
        if (this.game.tutorialManager && this.game.tutorialManager.showTooltip) {
            this.game.tutorialManager.nextStep()
        }
    }
    
    ; Back/Menu action
    OnBack(*) {
        OutputDebug("OnBack called, currentState = " this.game.currentState)
        
        if (this.game.currentState = GameState.MAIN_MENU) {
            this.game.OnExit()
        } else if (this.game.currentState = GameState.STORY) {
            this.game.ChangeState(GameState.MAIN_MENU)
        } else if (this.game.currentState = GameState.ROBOT_CUSTOMIZATION) {
            this.game.ChangeState(GameState.MAIN_MENU)
        } else if (this.game.currentState = GameState.BATTLE_SELECTION) {
            this.game.ChangeState(GameState.ROBOT_CUSTOMIZATION)
        } else if (this.game.currentState = GameState.BATTLE) {
            ; If showing special menu or item menu, cancel it
            if (this.game.battleManager && this.game.battleManager.showingSpecialMenu) {
                this.game.battleManager.cancelSpecialMenu()
            } else if (this.game.battleManager && this.game.battleManager.showingItemMenu) {
                this.game.battleManager.cancelItemMenu()
            } else {
                ; Confirm exit battle
                this.game.ChangeState(GameState.BATTLE_SELECTION)
            }
        } else if (this.game.currentState = GameState.INVENTORY) {
            this.game.ChangeState(GameState.ROBOT_CUSTOMIZATION)
        } else if (this.game.currentState = GameState.SETTINGS) {
            this.game.ChangeState(GameState.MAIN_MENU)
        }
    }
    
    ; Navigate up
    OnUp(*) {
        ; Handle navigation based on current state
        OutputDebug("OnUp called, currentState = " this.game.currentState)
        
        if (this.game.currentState = GameState.MAIN_MENU) {
            ; Navigate up in main menu
            if (this.game.selectedMenuOption > 1) {
                this.game.selectedMenuOption--
                OutputDebug("Selected menu option changed to " this.game.selectedMenuOption)
            }
        } else if (this.game.currentState = GameState.BATTLE) {
            OutputDebug("BATTLE case entered in OnUp")
            if (this.game.battleManager) {
                OutputDebug("Calling battleManager.navigateUp()")
                this.game.battleManager.navigateUp()
            } else {
                OutputDebug("ERROR: battleManager is null in OnUp")
            }
        } else if (this.game.currentState = GameState.SETTINGS) {
            ; Navigate up in settings menu
            if (this.game.selectedSettingsOption > 1) {
                this.game.selectedSettingsOption--
            }
        }
    }
    
    ; Navigate down
    OnDown(*) {
        ; Handle navigation based on current state
        OutputDebug("OnDown called, currentState = " this.game.currentState)
        
        if (this.game.currentState = GameState.MAIN_MENU) {
            ; Navigate down in main menu
            if (this.game.selectedMenuOption < 4) {
                this.game.selectedMenuOption++
                OutputDebug("Selected menu option changed to " this.game.selectedMenuOption)
            }
        } else if (this.game.currentState = GameState.BATTLE) {
            OutputDebug("BATTLE case entered in OnDown")
            if (this.game.battleManager) {
                OutputDebug("Calling battleManager.navigateDown()")
                this.game.battleManager.navigateDown()
            } else {
                OutputDebug("ERROR: battleManager is null in OnDown")
            }
        } else if (this.game.currentState = GameState.SETTINGS) {
            ; Navigate down in settings menu
            if (this.game.selectedSettingsOption < 2) { ; Now we have 2 options
                this.game.selectedSettingsOption++
            }
        }
    }
    
    ; Navigate left
    OnLeft(*) {
        ; Handle navigation based on current state
        if (this.game.currentState = GameState.ROBOT_CUSTOMIZATION) {
            ; Navigate through part types
            partTypes := ["head", "torso", "leftArm", "rightArm", "leftLeg", "rightLeg", "powerCore"]
            currentIndex := 0
            
            ; Find current index
            for i, partType in partTypes {
                if (this.game.selectedPartType = partType) {
                    currentIndex := i
                    break
                }
            }
            
            ; Move to previous part type (with wrap-around)
            if (currentIndex > 1) {
                this.game.selectedPartType := partTypes[currentIndex - 1]
            } else {
                this.game.selectedPartType := partTypes[partTypes.Length]
            }
        }
    }
    
    ; Navigate right
    OnRight(*) {
        ; Handle navigation based on current state
        if (this.game.currentState = GameState.ROBOT_CUSTOMIZATION) {
            ; Navigate through part types
            partTypes := ["head", "torso", "leftArm", "rightArm", "leftLeg", "rightLeg", "powerCore"]
            currentIndex := 0
            
            ; Find current index
            for i, partType in partTypes {
                if (this.game.selectedPartType = partType) {
                    currentIndex := i
                    break
                }
            }
            
            ; Move to next part type (with wrap-around)
            if (currentIndex < partTypes.Length) {
                this.game.selectedPartType := partTypes[currentIndex + 1]
            } else {
                this.game.selectedPartType := partTypes[1]
            }
        }
    }
}