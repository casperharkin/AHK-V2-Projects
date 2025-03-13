;==================================================================================================================
; Tutorial System
;==================================================================================================================
; Description:    A tutorial system for guiding new players through the Rustborn game
;                 Provides contextual tooltips and instructions based on game state
;
; Features:       - State-based tutorial progression
;                 - Customizable tooltip messages
;                 - Toggle-able tutorial system
;                 - Step-by-step guidance
;
; Usage:          Initialize with TutorialManager() and call update() and draw() methods
;
; Dependencies:   - AutoHotkey v2.0
;                 - D2D1.ahk library
;
; Author:         CasperHarkin
; Version:        0.1.0
; Last Updated:   13/03/2025
;==================================================================================================================

; ==================== Tutorial Manager Class ====================
class TutorialManager {
    ; Tutorial properties
    enabled := true
    currentStep := 1
    showTooltip := false
    tooltipMessage := ""
    tooltipPosition := {x: 0, y: 0}
    tooltipWidth := 300
    tooltipHeight := 100
    
    ; Tutorial steps by game state
    tutorialSteps := Map()
    
    ; Constructor
    __New() {
        ; Initialize tutorial steps for each game state
        this._initializeTutorialSteps()
    }
    
    ; Initialize tutorial steps
    _initializeTutorialSteps() {
        ; Main menu tutorial steps
        this.tutorialSteps["MAIN_MENU"] := [
            {
                message: "Welcome to Rustborn! Use Up/Down keys to navigate the menu and SPACE to select an option.",
                position: {x: 512, y: 450},
                width: 400,
                height: 80
            }
        ]
        
        ; Story tutorial steps
        this.tutorialSteps["STORY"] := [
            {
                message: "This is the story screen. Read the background of the game world here.",
                position: {x: 512, y: 500},
                width: 400,
                height: 80
            },
            {
                message: "Press SPACE to continue to the robot customization screen.",
                position: {x: 512, y: 550},
                width: 400,
                height: 60
            }
        ]
        
        ; Robot customization tutorial steps
        this.tutorialSteps["ROBOT_CUSTOMIZATION"] := [
            {
                message: "This is the robot customization screen. Here you can view your robot's parts and stats.",
                position: {x: 512, y: 100},
                width: 500,
                height: 80
            },
            {
                message: "The left panel shows your equipped parts. Different colors indicate part rarity.",
                position: {x: 200, y: 200},
                width: 300,
                height: 80
            },
            {
                message: "The right panel shows your robot's stats. Bars indicate relative strength.",
                position: {x: 800, y: 200},
                width: 300,
                height: 80
            },
            {
                message: "Press SPACE to continue to battle selection.",
                position: {x: 512, y: 700},
                width: 400,
                height: 60
            }
        ]
        
        ; Battle selection tutorial steps
        this.tutorialSteps["BATTLE_SELECTION"] := [
            {
                message: "This is the battle selection screen. Here you can see information about your next opponent.",
                position: {x: 512, y: 100},
                width: 500,
                height: 80
            },
            {
                message: "Press SPACE to start the battle or ESC to go back to customization.",
                position: {x: 512, y: 700},
                width: 450,
                height: 60
            }
        ]
        
        ; Battle tutorial steps
        this.tutorialSteps["BATTLE"] := [
            {
                message: "This is the battle screen. Your robot is on the left, and the enemy is on the right.",
                position: {x: 512, y: 120},
                width: 500,
                height: 80
            },
            {
                message: "The bars at the top show health (green) and energy (blue) for both robots.",
                position: {x: 512, y: 70},
                width: 500,
                height: 60
            },
            {
                message: "Use the action buttons at the bottom to fight. Attack deals damage, Defend reduces incoming damage.",
                position: {x: 300, y: 600},
                width: 500,
                height: 80
            },
            {
                message: "Special abilities use energy but are more powerful. Items can provide various effects.",
                position: {x: 300, y: 600},
                width: 500,
                height: 80
            },
            {
                message: "The battle log on the right shows what happened during the battle.",
                position: {x: 800, y: 600},
                width: 300,
                height: 80
            }
        ]
        
        ; Inventory tutorial steps
        this.tutorialSteps["INVENTORY"] := [
            {
                message: "This is the inventory screen. Here you can see parts you've salvaged from defeated robots.",
                position: {x: 512, y: 120},
                width: 500,
                height: 80
            },
            {
                message: "Different colors indicate part rarity: White (common), Blue (good), Purple (epic).",
                position: {x: 512, y: 200},
                width: 500,
                height: 60
            }
        ]
        
        ; Settings tutorial steps
        this.tutorialSteps["SETTINGS"] := [
            {
                message: "This is the settings screen. Here you can customize game options.",
                position: {x: 512, y: 200},
                width: 400,
                height: 60
            },
            {
                message: "You can toggle tutorials on/off using the switch.",
                position: {x: 512, y: 250},
                width: 400,
                height: 60
            }
        ]
    }
    
    ; Update tutorial based on game state
    update(gameState, gameInstance) {
        ; Skip if tutorials are disabled
        if (!this.enabled)
            return
            
        ; Check if there are tutorial steps for this state
        if (!this.tutorialSteps.Has(gameState))
            return
            
        ; Get steps for current state
        stateSteps := this.tutorialSteps[gameState]
        
        ; Check if current step is valid for this state
        if (this.currentStep <= stateSteps.Length) {
            ; Show tooltip with current step message
            this.showTooltip := true
            currentStepData := stateSteps[this.currentStep]
            this.tooltipMessage := currentStepData.message
            this.tooltipPosition := currentStepData.position
            
            ; Use custom dimensions if provided
            if (HasProp(currentStepData, "width"))
                this.tooltipWidth := currentStepData.width
            if (HasProp(currentStepData, "height"))
                this.tooltipHeight := currentStepData.height
        } else {
            ; No more steps for this state
            this.showTooltip := false
        }
    }
    
    ; Draw tutorial elements
    draw(d2d) {
        ; Skip if tutorials are disabled or no tooltip to show
        if (!this.enabled || !this.showTooltip)
            return
            
        ; Draw tooltip background
        tooltipX := this.tooltipPosition.x - this.tooltipWidth / 2
        tooltipY := this.tooltipPosition.y - this.tooltipHeight / 2
        
        ; Draw semi-transparent background
        d2d.fillRoundedRectangle(tooltipX, tooltipY, this.tooltipWidth, this.tooltipHeight, 10, 10, 0xDD000000)
        d2d.drawRoundedRectangle(tooltipX, tooltipY, this.tooltipWidth, this.tooltipHeight, 10, 10, 0xFF00AAFF, 2)
        
        ; Draw tooltip text
        d2d.drawText(this.tooltipMessage, tooltipX + 15, tooltipY + 15, 16, 0xFFFFFFFF, "Arial", "w" (this.tooltipWidth - 30) " h" (this.tooltipHeight - 30))
        
        ; Draw continue prompt
        d2d.drawText("Press SPACE to continue", tooltipX + this.tooltipWidth - 150, tooltipY + this.tooltipHeight - 25, 12, 0xFFAAAAAA, "Arial", "w140 h20")
    }
    
    ; Move to next tutorial step
    nextStep() {
        ; Skip if tutorials are disabled
        if (!this.enabled)
            return
            
        ; Increment step counter
        this.currentStep++
        
        ; Hide tooltip until next update
        this.showTooltip := false
    }
    
    ; Reset tutorial for a specific state
    resetStateProgress(gameState) {
        ; Reset step counter for the specified state
        this.currentStep := 1
    }
    
    ; Reset all tutorial progress
    resetAllProgress() {
        ; Reset step counter for all states
        this.currentStep := 1
    }
}