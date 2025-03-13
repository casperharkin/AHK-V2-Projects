;==================================================================================================================
; Game Renderer
;==================================================================================================================
; Description:    Handles all rendering functions for the Rustborn game
;                 Responsible for drawing UI elements based on game state
;
; Features:       - State-based rendering
;                 - UI element drawing
;                 - Animation and visual effects
;
; Usage:          Include this file and use GameRenderer class methods
;
; Dependencies:   - AutoHotkey v2.0
;                 - D2D1.ahk library
;                 - GameState.ahk
;
; Author:         CasperHarkin
; Version:        0.1.0
; Last Updated:   13/03/2025
;==================================================================================================================

#Include GameState.ahk
#Include PlayerRobotImage.ahk

; ==================== Game Renderer Class ====================
class GameRenderer {
    ; Reference to game instance
    game := ""
    
    ; Constructor
    __New(gameInstance) {
        this.game := gameInstance
    }
    
    ; Main draw method - delegates to appropriate draw function based on game state
    Draw() {
        ; Check if dimensions are valid
        if (this.game.width <= 0 || this.game.height <= 0) {
            Debug("Invalid dimensions: width=" this.game.width ", height=" this.game.height, "ERROR")
            return
        }
        
        ; Check if D2D1 object is valid
        if (!this.game.d2d || this.game.d2d == "") {
            Debug("D2D1 object is not valid", "ERROR")
            return
        }
        
        try {
            ; Begin drawing
            this.game.d2d.beginDraw()
            
            ; Clear background with dark color
            this.game.d2d.fillRectangle(0, 0, this.game.width, this.game.height, 0xFF1A1A1A)
            
            ; Draw current state indicator (debug)
            this.game.d2d.drawText("Current State: " this.game.currentState, 10, 30, 12, 0xFFFFFFFF, "Arial", "w200 h20")
            
            ; Draw based on current state
            Debug("Drawing state: " this.game.currentState, "INFO")
        } catch as e {
            Debug("Error in Draw method: " e.Message, "ERROR")
            return
        }
        
        try {
            ; Use if-else statements instead of switch
            if (this.game.currentState = GameState.MAIN_MENU) {
                Debug("Drawing MAIN_MENU", "INFO")
                this.DrawMainMenu()
            } else if (this.game.currentState = GameState.STORY) {
                Debug("Drawing STORY", "INFO")
                this.DrawStoryScreen()
            } else if (this.game.currentState = GameState.ROBOT_CUSTOMIZATION) {
                Debug("Drawing ROBOT_CUSTOMIZATION", "INFO")
                this.DrawCustomizationScreen()
            } else if (this.game.currentState = GameState.BATTLE_SELECTION) {
                Debug("Drawing BATTLE_SELECTION", "INFO")
                this.DrawBattleSelectionScreen()
            } else if (this.game.currentState = GameState.BATTLE) {
                Debug("Drawing BATTLE", "INFO")
                this.DrawBattleScreen()
            } else if (this.game.currentState = GameState.INVENTORY) {
                Debug("Drawing INVENTORY", "INFO")
                this.DrawInventoryScreen()
            } else if (this.game.currentState = GameState.GAME_OVER) {
                Debug("Drawing GAME_OVER", "INFO")
                this.DrawGameOverScreen()
            } else if (this.game.currentState = GameState.VICTORY) {
                Debug("Drawing VICTORY", "INFO")
                this.DrawVictoryScreen()
            } else if (this.game.currentState = GameState.SETTINGS) {
                Debug("Drawing SETTINGS", "INFO")
                this.DrawSettingsMenu()
            } else {
                Debug("Unknown state: " this.game.currentState, "ERROR")
            }
            
            ; Draw FPS counter (debug)
            this.game.d2d.drawText("FPS: " this.game.fps, 10, 10, 12, 0xFFFFFFFF, "Arial", "w100 h20")
            
            ; Draw tutorial elements if tutorial manager is initialized
            if (this.game.tutorialManager) {
                this.game.tutorialManager.draw(this.game.d2d)
            }
            
            ; Draw notification if active
            this.DrawNotification()
            
            ; End drawing
            this.game.d2d.endDraw()
        } catch as e {
            Debug("Error in Draw method (state rendering): " e.Message, "ERROR")
        }
    }
    
    ; Draw notification
    DrawNotification() {
        if (this.game.notification && this.game.notification != "") {
            elapsedTime := A_TickCount - this.game.notification.startTime
            
            if (elapsedTime < this.game.notification.duration) {
                ; Calculate fade effect
                alpha := 255
                if (elapsedTime > this.game.notification.duration - 500) {
                    fadeProgress := (elapsedTime - (this.game.notification.duration - 500)) / 500
                    alpha := 255 * (1 - fadeProgress)
                }
                
                ; Create color with alpha
                color := (Floor(alpha) << 24) | (this.game.notification.color & 0x00FFFFFF)
                
                ; Draw notification background
                notifWidth := 400
                notifHeight := 40
                notifX := (this.game.width - notifWidth) / 2
                notifY := 100
                
                this.game.d2d.fillRoundedRectangle(notifX, notifY, notifWidth, notifHeight, 10, 10, (Floor(alpha * 0.7) << 24) | 0x000000)
                this.game.d2d.drawText(this.game.notification.message, notifX + 20, notifY + 10, 18, color, "Arial", "w" (notifWidth - 40) " h" (notifHeight - 20) " aCenter vCenter")
            } else {
                ; Clear notification after duration
                this.game.notification := ""
            }
        }
    }
    
    ; Draw main menu
    DrawMainMenu() {
        ; Draw title
        this.game.d2d.drawText("ROBOT BATTLE", this.game.width/2 - 200, 150, 72, 0xFFFFFFFF, "Arial", "w400 h80 aCenter")
        
        ; Draw menu options with highlighting for selected option
        menuOptions := ["New Game", "Load Game", "Settings", "Exit"]
        menuY := [300, 350, 400, 450]
        
        ; Draw each menu option
        for i, option in menuOptions {
            ; Set color based on selection
            color := (i = this.game.selectedMenuOption) ? 0xFFFFFFFF : 0xFFAAAAAA
            
            ; Draw option text
            this.game.d2d.drawText(option, this.game.width/2 - 100, menuY[i], 36, color, "Arial", "w200 h40 aCenter")
            
            ; Draw selection indicator if this is the selected option
            if (i = this.game.selectedMenuOption) {
                this.game.d2d.fillRectangle(this.game.width/2 - 120, menuY[i] + 18, 10, 10, 0xFFFFFFFF)
            }
            
            ; Show save slot info for Load Game option
            if (i = 1 && this.game.saveSystem) { ; Load Game
                ; Check for save files
                saveCount := 0
                saveInfo := ""
                
                for slot in [1, 2, 3, 4, 5] {
                    if (this.game.saveSystem.saveExists(slot)) {
                        saveCount++
                        info := this.game.saveSystem.getSaveInfo(slot)
                        if (info && saveInfo = "") {
                            saveInfo := "Slot " slot ": " info.saveDate
                        }
                    }
                }
                
                ; Display save info
                if (saveCount > 0) {
                    this.game.d2d.drawText(saveCount " save" (saveCount > 1 ? "s" : "") " available", this.game.width/2 - 100, menuY[i] + 40, 16, 0xFF00AAFF, "Arial", "w200 h20 aCenter")
                    if (saveInfo != "") {
                        this.game.d2d.drawText(saveInfo, this.game.width/2 - 150, menuY[i] + 60, 14, 0xFFAAAAAA, "Arial", "w300 h20 aCenter")
                    }
                } else {
                    this.game.d2d.drawText("No saves available", this.game.width/2 - 100, menuY[i] + 40, 16, 0xFFAAAAAA, "Arial", "w200 h20 aCenter")
                }
            }
        }
        
        ; Draw version info
        this.game.d2d.drawText("Version 0.1.0", 20, this.game.height - 30, 14, 0xFFAAAAAA, "Arial", "w100 h20")
        
        ; Draw instructions
        this.game.d2d.drawText("Up/Down - Navigate", this.game.width/2 - 150, this.game.height - 130, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        this.game.d2d.drawText("SPACE - Select", this.game.width/2 - 150, this.game.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        this.game.d2d.drawText("F5 - Save Game | F9 - Load Game", this.game.width/2 - 200, this.game.height - 70, 18, 0xFFFFFFFF, "Arial", "w400 h30 aCenter")
    }
    
    ; Draw story screen
    DrawStoryScreen() {
        OutputDebug("DrawStoryScreen called")
        
        ; Draw story title
        this.game.d2d.drawText("THE WASTELAND", this.game.width/2 - 200, 100, 48, 0xFFFFFFFF, "Arial", "w400 h60 aCenter")
        
        ; Draw story text based on progress
        storyText := "In a desolate alien wasteland, robots fight for survival and supremacy.`n`n"
                   . "You are a lone robot, scavenging for parts to improve yourself.`n`n"
                   . "Defeat other robots to salvage their parts and become stronger.`n`n"
                   . "Discover the secrets of the wasteland and why it became this way."
        
        this.game.d2d.drawText(storyText, this.game.width/2 - 300, 200, 24, 0xFFFFFFFF, "Arial", "w600 h300 aCenter")
        
        ; Draw continue prompt
        this.game.d2d.drawText("Press SPACE to continue", this.game.width/2 - 150, this.game.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        
        ; Draw debug info
        this.game.d2d.drawText("Current State: STORY", 10, 50, 14, 0xFFFFFFFF, "Arial", "w200 h20")
        this.game.d2d.drawText("Press SPACE to continue to ROBOT_CUSTOMIZATION", 10, 70, 14, 0xFFFFFFFF, "Arial", "w400 h20")
    }
    
    ; Draw customization screen
    DrawCustomizationScreen() {
        ; Draw background
        this.game.d2d.fillRectangle(0, 0, this.game.width, this.game.height, 0xFF1A1A1A)
        
        ; Draw screen title
        this.game.d2d.drawText("ROBOT CUSTOMIZATION", this.game.width/2 - 250, 30, 48, 0xFFFFFFFF, "Arial", "w500 h60 aCenter")
        
        ; Draw robot preview in center
        previewX := this.game.width/2
        previewY := this.game.height/2 - 50
        
        ; Use robot visualization if available (placeholder for now)
        this.game.d2d.fillRectangle(previewX - 100, previewY - 150, 200, 300, 0xFF444444)
        
        ; Draw part selection panel on left
        panelWidth := 300
        panelHeight := 500
        panelX := 50
        panelY := 120
        
        ; Draw panel background
        this.game.d2d.fillRoundedRectangle(panelX, panelY, panelWidth, panelHeight, 10, 10, 0xFF222222)
        this.game.d2d.drawText("EQUIPPED PARTS", panelX + panelWidth/2 - 80, panelY + 10, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        ; Draw part list with selection
        yPos := panelY + 50
        partTypes := ["head", "torso", "leftArm", "rightArm", "leftLeg", "rightLeg", "powerCore"]
        partNames := ["Head", "Torso", "Left Arm", "Right Arm", "Left Leg", "Right Leg", "Power Core"]
        
        ; Add selected part type property if it doesn't exist
        if (!HasProp(this.game, "selectedPartType"))
            this.game.selectedPartType := "head"
        
        for i, partType in partTypes {
            ; Determine if this part is selected
            isSelected := (this.game.selectedPartType = partType)
            
            ; Draw selection background if selected
            if (isSelected) {
                this.game.d2d.fillRoundedRectangle(panelX + 10, yPos - 5, panelWidth - 20, 60, 5, 5, 0xFF444444)
            }
            
            ; Get part info
            part := this.game.playerRobot.getPart(partType)
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
            
            ; Draw part type and name
            this.game.d2d.drawText(partNames[i], panelX + 20, yPos, 20, 0xFFFFFFFF, "Arial", "w150 h24")
            this.game.d2d.drawText(partName, panelX + 20, yPos + 25, 16, color, "Arial", "w260 h20")
            
            ; Draw element icon if present
            if (part && part.elementType != "") {
                elementColor := 0xFFFFFFFF
                if (part.elementType = "fire")
                    elementColor := 0xFFFF5500
                else if (part.elementType = "ice")
                    elementColor := 0xFF00FFFF
                else if (part.elementType = "lightning")
                    elementColor := 0xFFFFFF00
                else if (part.elementType = "acid")
                    elementColor := 0xFF00FF00
                else if (part.elementType = "shadow")
                    elementColor := 0xFFAA00FF
                    
                this.game.d2d.fillEllipse(panelX + panelWidth - 30, yPos + 20, 10, 10, elementColor)
            }
            
            yPos += 70
        }
        
        ; Draw stats panel on right
        panelX := this.game.width - 350
        
        ; Draw panel background
        this.game.d2d.fillRoundedRectangle(panelX, panelY, panelWidth, panelHeight, 10, 10, 0xFF222222)
        this.game.d2d.drawText("ROBOT STATS", panelX + panelWidth/2 - 70, panelY + 10, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        ; Draw stats with bars
        yPos := panelY + 50
        stats := this.game.playerRobot.getStats()
        
        ; Calculate max values for stats
        maxValues := Map(
            "Health", 300,
            "Energy", 200,
            "Attack", 100,
            "Defense", 100,
            "Speed", 50,
            "Accuracy", 50,
            "Evasion", 50,
            "Crit Chance", 40
        )
        
        ; Draw each stat with bar
        for statName, statValue in stats {
            ; Parse numeric value from stat
            numericValue := statValue
            if (InStr(statValue, "/")) {
                parts := StrSplit(statValue, "/")
                numericValue := Trim(parts[1])
            } else if (InStr(statValue, "%")) {
                numericValue := SubStr(statValue, 1, StrLen(statValue) - 1)
            }
            
            ; Calculate bar width
            maxValue := maxValues.Has(statName) ? maxValues[statName] : 100
            barWidth := (numericValue / maxValue) * (panelWidth - 40)
            barWidth := Min(panelWidth - 40, Max(10, barWidth))  ; Clamp bar width
            
            ; Determine bar color based on stat
            barColor := 0xFF00AAFF  ; Default blue
            if (statName = "Health")
                barColor := 0xFF00FF00  ; Green
            else if (statName = "Energy")
                barColor := 0xFF00FFFF  ; Cyan
            else if (statName = "Attack")
                barColor := 0xFFFF5500  ; Orange
            else if (statName = "Defense")
                barColor := 0xFFAAAAAA  ; Gray
            else if (statName = "Crit Chance")
                barColor := 0xFFFFFF00  ; Yellow
            
            ; Draw stat name and value
            this.game.d2d.drawText(statName, panelX + 20, yPos, 18, 0xFFFFFFFF, "Arial", "w150 h24")
            this.game.d2d.drawText(statValue, panelX + panelWidth - 60, yPos, 18, 0xFFFFFFFF, "Arial", "w50 h24 aRight")
            
            ; Draw stat bar background
            this.game.d2d.fillRoundedRectangle(panelX + 20, yPos + 25, panelWidth - 40, 15, 5, 5, 0xFF333333)
            
            ; Draw stat bar
            if (barWidth > 0)
                this.game.d2d.fillRoundedRectangle(panelX + 20, yPos + 25, barWidth, 15, 5, 5, barColor)
            
            yPos += 50
        }
        
        ; Draw navigation buttons
        this.game.d2d.drawText("Up/Down - Select Part   |   I - Inventory   |   SPACE - Continue   |   ESC - Back",
            this.game.width/2, this.game.height - 30, 16, 0xFFAAAAAA, "Arial", "w600 h20 aCenter")
    }
    
    ; Draw battle selection screen
    DrawBattleSelectionScreen() {
        ; Draw screen title
        this.game.d2d.drawText("BATTLE SELECTION", this.game.width/2 - 200, 50, 48, 0xFFFFFFFF, "Arial", "w400 h60 aCenter")
        
        ; Draw opponent info
        this.game.d2d.drawText("Next Opponent:", this.game.width/2 - 150, 150, 36, 0xFFFFFFFF, "Arial", "w300 h40 aCenter")
        this.game.d2d.drawText(this.game.currentOpponent.name, this.game.width/2 - 150, 200, 48, 0xFFFF0000, "Arial", "w300 h60 aCenter")
        this.game.d2d.drawText(this.game.currentOpponent.description, this.game.width/2 - 250, 260, 24, 0xFFFFFFFF, "Arial", "w500 h60 aCenter")
        
        ; Draw opponent preview (placeholder)
        this.game.d2d.fillRectangle(this.game.width/2 - 100, 330, 200, 300, 0xFF444444)
        
        ; Draw navigation options
        this.game.d2d.drawText("SPACE - Start Battle", this.game.width/2 - 150, this.game.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aCenter")
        this.game.d2d.drawText("ESC - Back to Customization", this.game.width - 300, this.game.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aRight")
    }
    
    ; Draw battle screen
    DrawBattleScreen() {
        ; Draw battle arena
        this.game.d2d.fillRectangle(0, this.game.height - 200, this.game.width, 200, 0xFF333333)  ; Ground
        
        ; Draw player robot using the PlayerRobotImage module
        if (IsSet(DrawPlayerRobot)) {
            ; Use the detailed robot drawing function if available - 4x larger
            DrawPlayerRobot(this.game.d2d, 275, this.game.height - 100, 600, 1000, this.game.playerRobot, false)
        } else {
            ; Fallback to placeholder if module not included
            this.game.d2d.fillRectangle(200, this.game.height - 350, 150, 250, 0xFF0000FF)
        }
        
        ; Draw enemy robot using the same function but with different colors
        if (IsSet(DrawPlayerRobot)) {
            ; Use the detailed robot drawing function for enemy - 4x larger
            DrawPlayerRobot(this.game.d2d, this.game.width - 275, this.game.height - 100, 600, 1000, this.game.currentOpponent, true)
        } else {
            ; Fallback to placeholder if module not included
            this.game.d2d.fillRectangle(this.game.width - 350, this.game.height - 350, 150, 250, 0xFFFF0000)
        }
        
        ; Draw health bars
        ; Player health
        this.game.d2d.fillRectangle(50, 50, 300, 30, 0xFF333333)
        
        ; Calculate health bar width with safety check
        playerHealthRatio := (this.game.playerRobot && this.game.playerRobot.maxHealth > 0)
            ? Max(0, Min(1, this.game.playerRobot.health / this.game.playerRobot.maxHealth))
            : 0
        healthBarWidth := 300 * playerHealthRatio
        
        ; Ensure width is positive
        if (healthBarWidth > 0)
            this.game.d2d.fillRectangle(50, 50, healthBarWidth, 30, 0xFF00FF00)
            
        this.game.d2d.drawText(this.game.playerRobot.name, 50, 20, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        ; Enemy health
        this.game.d2d.fillRectangle(this.game.width - 350, 50, 300, 30, 0xFF333333)
        
        ; Calculate enemy health bar width with safety check
        enemyHealthRatio := (this.game.currentOpponent && this.game.currentOpponent.maxHealth > 0)
            ? Max(0, Min(1, this.game.currentOpponent.health / this.game.currentOpponent.maxHealth))
            : 0
        enemyHealthBarWidth := 300 * enemyHealthRatio
        
        ; Ensure width is positive
        if (enemyHealthBarWidth > 0)
            this.game.d2d.fillRectangle(this.game.width - 350, 50, enemyHealthBarWidth, 30, 0xFFFF0000)
            
        this.game.d2d.drawText(this.game.currentOpponent.name, this.game.width - 350, 20, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        ; Draw energy bars
        ; Player energy
        this.game.d2d.fillRectangle(50, 90, 300, 15, 0xFF333333)
        
        ; Calculate energy bar width with safety check
        playerEnergyRatio := (this.game.playerRobot && this.game.playerRobot.maxEnergy > 0)
            ? Max(0, Min(1, this.game.playerRobot.energy / this.game.playerRobot.maxEnergy))
            : 0
        energyBarWidth := 300 * playerEnergyRatio
        
        ; Ensure width is positive
        if (energyBarWidth > 0)
            this.game.d2d.fillRectangle(50, 90, energyBarWidth, 15, 0xFF00FFFF)
        
        ; Enemy energy
        this.game.d2d.fillRectangle(this.game.width - 350, 90, 300, 15, 0xFF333333)
        
        ; Calculate enemy energy bar width with safety check
        enemyEnergyRatio := (this.game.currentOpponent && this.game.currentOpponent.maxEnergy > 0)
            ? Max(0, Min(1, this.game.currentOpponent.energy / this.game.currentOpponent.maxEnergy))
            : 0
        enemyEnergyBarWidth := 300 * enemyEnergyRatio
        
        ; Ensure width is positive
        if (enemyEnergyBarWidth > 0)
            this.game.d2d.fillRectangle(this.game.width - 350, 90, enemyEnergyBarWidth, 15, 0xFF00FFFF)
        
        ; Check if battle manager is initialized
        Debug("DrawBattleScreen: battleManager is " (this.game.battleManager ? "initialized" : "null"), "BATTLE")
        if (this.game.battleManager) {
            ; Draw turn indicator
            turnText := this.game.battleManager.isPlayerTurn ? "Your Turn" : "Enemy Turn"
            turnColor := this.game.battleManager.isPlayerTurn ? 0xFF00FF00 : 0xFFFF0000
            this.game.d2d.drawText(turnText, this.game.width / 2 - 50, 20, 24, turnColor, "Arial", "w100 h30 aCenter")
            
            ; Draw battle actions with improved visuals
            actionColors := Map(
                1, this.game.battleManager.selectedAction = 1 ? 0xFF0088FF : 0xFF444444,
                2, this.game.battleManager.selectedAction = 2 ? 0xFF0088FF : 0xFF444444,
                3, this.game.battleManager.selectedAction = 3 ? 0xFF0088FF : 0xFF444444,
                4, this.game.battleManager.selectedAction = 4 ? 0xFF0088FF : 0xFF444444
            )
            Debug("Battle action colors: " actionColors[1] ", " actionColors[2] ", " actionColors[3] ", " actionColors[4], "BATTLE")
            Debug("Selected action: " this.game.battleManager.selectedAction, "BATTLE")
            
            ; Draw action panel background
            actionPanelX := 50
            actionPanelY := this.game.height - 160
            actionPanelWidth := 470
            actionPanelHeight := 120
            this.game.d2d.fillRoundedRectangle(actionPanelX, actionPanelY, actionPanelWidth, actionPanelHeight, 10, 10, 0xFF222222)
            
            ; Draw action buttons with icons and labels
            buttonSize := 100
            spacing := 10
            startX := actionPanelX + 25
            startY := actionPanelY + 10
            
            ; Attack button
            this.game.d2d.fillRoundedRectangle(startX, startY, buttonSize, buttonSize, 8, 8, actionColors[1])
            this.game.d2d.drawText("⚔️", startX + buttonSize/2, startY + buttonSize/2 - 15, 32, 0xFFFFFFFF, "Arial", "w40 h40 aCenter vCenter")
            this.game.d2d.drawText("Attack", startX + buttonSize/2, startY + buttonSize - 20, 16, 0xFFFFFFFF, "Arial", "w80 h20 aCenter")
            
            ; Defend button
            this.game.d2d.fillRoundedRectangle(startX + buttonSize + spacing, startY, buttonSize, buttonSize, 8, 8, actionColors[2])
            this.game.d2d.drawText("🛡️", startX + buttonSize + spacing + buttonSize/2, startY + buttonSize/2 - 15, 32, 0xFFFFFFFF, "Arial", "w40 h40 aCenter vCenter")
            this.game.d2d.drawText("Defend", startX + buttonSize + spacing + buttonSize/2, startY + buttonSize - 20, 16, 0xFFFFFFFF, "Arial", "w80 h20 aCenter")
            
            ; Special button
            this.game.d2d.fillRoundedRectangle(startX + 2 * (buttonSize + spacing), startY, buttonSize, buttonSize, 8, 8, actionColors[3])
            this.game.d2d.drawText("✨", startX + 2 * (buttonSize + spacing) + buttonSize/2, startY + buttonSize/2 - 15, 32, 0xFFFFFFFF, "Arial", "w40 h40 aCenter vCenter")
            this.game.d2d.drawText("Special", startX + 2 * (buttonSize + spacing) + buttonSize/2, startY + buttonSize - 20, 16, 0xFFFFFFFF, "Arial", "w80 h20 aCenter")
            
            ; Item button
            this.game.d2d.fillRoundedRectangle(startX + 3 * (buttonSize + spacing), startY, buttonSize, buttonSize, 8, 8, actionColors[4])
            this.game.d2d.drawText("🧪", startX + 3 * (buttonSize + spacing) + buttonSize/2, startY + buttonSize/2 - 15, 32, 0xFFFFFFFF, "Arial", "w40 h40 aCenter vCenter")
            this.game.d2d.drawText("Item", startX + 3 * (buttonSize + spacing) + buttonSize/2, startY + buttonSize - 20, 16, 0xFFFFFFFF, "Arial", "w80 h20 aCenter")
            
            ; Draw special menu if showing
            if (this.game.battleManager.showingSpecialMenu) {
                ; Draw special abilities menu
                this.game.d2d.fillRectangle(50, this.game.height - 350, 410, 190, 0xFF222222)
                this.game.d2d.drawText("Special Abilities", 50, this.game.height - 350, 24, 0xFFFFFFFF, "Arial", "w410 h30 aCenter")
                
                ; Draw available special abilities
                yPos := this.game.height - 310
                for i, special in this.game.battleManager.availableSpecials {
                    ; Highlight selected special
                    bgColor := (i = this.game.battleManager.selectedSpecial) ? 0xFF666666 : 0xFF444444
                    
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
                    this.game.d2d.fillRectangle(60, yPos, 390, 30, bgColor)
                    this.game.d2d.drawText(special.name " (" special.energyCost " energy)", 70, yPos, 18, textColor, "Arial", "w300 h30")
                    this.game.d2d.drawText(special.description, 70, yPos + 20, 14, 0xFFAAAAAA, "Arial", "w300 h20")
                    
                    yPos += 60
                }
                
                ; Draw instructions
                this.game.d2d.drawText("Up/Down to select, SPACE to use, ESC to cancel", 50, this.game.height - 160, 14, 0xFFAAAAAA, "Arial", "w410 h20 aCenter")
            } else if (this.game.battleManager.showingItemMenu) {
                ; Draw items menu
                this.game.d2d.fillRectangle(50, this.game.height - 350, 410, 190, 0xFF222222)
                this.game.d2d.drawText("Items", 50, this.game.height - 350, 24, 0xFFFFFFFF, "Arial", "w410 h30 aCenter")
                
                ; Draw available items
                if (this.game.itemInventory.Length > 0) {
                    yPos := this.game.height - 310
                    for i, item in this.game.itemInventory {
                        ; Highlight selected item
                        bgColor := (i = this.game.battleManager.selectedItem) ? 0xFF666666 : 0xFF444444
                        
                        ; Set color based on item type
                        textColor := 0xFFFFFFFF  ; Default white
                        if (item.type = "healing") {
                            textColor := 0xFF55FF55  ; Green
                        } else if (item.type = "buff") {
                            textColor := 0xFF55FFFF  ; Cyan
                        } else if (item.type = "utility") {
                            textColor := 0xFFFFFF55  ; Yellow
                        }
                        
                        ; Draw item
                        this.game.d2d.fillRectangle(60, yPos, 390, 30, bgColor)
                        this.game.d2d.drawText(item.name, 70, yPos, 18, textColor, "Arial", "w300 h30")
                        this.game.d2d.drawText(item.description, 70, yPos + 20, 14, 0xFFAAAAAA, "Arial", "w300 h20")
                        
                        yPos += 60
                        
                        ; Limit display to prevent overflow
                        if (i >= 3) {
                            this.game.d2d.drawText("... and " (this.game.itemInventory.Length - 3) " more", 70, yPos, 14, 0xFFAAAAAA, "Arial", "w300 h20")
                            break
                        }
                    }
                } else {
                    this.game.d2d.drawText("No items available", 255, this.game.height - 280, 18, 0xFFAAAAAA, "Arial", "w200 h30 aCenter")
                }
                
                ; Draw instructions
                this.game.d2d.drawText("Up/Down to select, SPACE to use, ESC to cancel", 50, this.game.height - 160, 14, 0xFFAAAAAA, "Arial", "w410 h20 aCenter")
            }
            
            ; Draw battle log
            this.game.d2d.fillRectangle(this.game.width - 350, this.game.height - 150, 300, 110, 0xFF222222)
            this.game.d2d.drawText("Battle Log", this.game.width - 350, this.game.height - 170, 18, 0xFFFFFFFF, "Arial", "w300 h20")
            
            ; Draw battle log entries
            yPos := this.game.height - 140
            for i, logEntry in this.game.battleManager.battleLog {
                this.game.d2d.drawText(logEntry, this.game.width - 340, yPos, 14, 0xFFFFFFFF, "Arial", "w280 h20")
                yPos += 20
            }
        } else {
            ; Draw default battle actions if battle manager not initialized
            this.game.d2d.fillRoundedRectangle(50, this.game.height - 150, 200, 50, 10, 10, 0xFF444444)
            this.game.d2d.drawText("Attack", 150, this.game.height - 150, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.game.d2d.fillRoundedRectangle(50, this.game.height - 90, 200, 50, 10, 10, 0xFF444444)
            this.game.d2d.drawText("Defend", 150, this.game.height - 90, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.game.d2d.fillRoundedRectangle(260, this.game.height - 150, 200, 50, 10, 10, 0xFF444444)
            this.game.d2d.drawText("Special", 360, this.game.height - 150, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            this.game.d2d.fillRoundedRectangle(260, this.game.height - 90, 200, 50, 10, 10, 0xFF444444)
            this.game.d2d.drawText("Item", 360, this.game.height - 90, 24, 0xFFFFFFFF, "Arial", "w200 h50 aCenter vCenter")
            
            ; Draw battle log
            this.game.d2d.fillRectangle(this.game.width - 350, this.game.height - 150, 300, 110, 0xFF222222)
            this.game.d2d.drawText("Battle Log", this.game.width - 350, this.game.height - 170, 18, 0xFFFFFFFF, "Arial", "w300 h20")
            this.game.d2d.drawText("Battle starting...", this.game.width - 340, this.game.height - 140, 14, 0xFFFFFFFF, "Arial", "w280 h100")
        }
    }
    
    ; Draw inventory screen
    DrawInventoryScreen() {
        ; Draw screen title
        this.game.d2d.drawText("INVENTORY", this.game.width/2 - 150, 50, 48, 0xFFFFFFFF, "Arial", "w300 h60 aCenter")
        
        ; Draw inventory items
        this.game.d2d.drawText("Salvaged Parts:", 50, 150, 24, 0xFFFFFFFF, "Arial", "w200 h30")
        
        if (this.game.inventory.Length = 0) {
            this.game.d2d.drawText("No parts in inventory", 70, 190, 18, 0xFFAAAAAA, "Arial", "w300 h24")
        } else {
            yPos := 190
            for i, part in this.game.inventory {
                ; Set color based on rarity
                color := 0xFFAAAAAA  ; Default gray
                if (part.rarity = "poor")
                    color := 0xFFFFFFFF  ; White
                else if (part.rarity = "good")
                    color := 0xFF00AAFF  ; Blue
                else if (part.rarity = "epic")
                    color := 0xFFAA00FF  ; Purple
                
                this.game.d2d.drawText(part.type ": " part.name, 70, yPos, 18, color, "Arial", "w300 h24")
                yPos += 30
                
                ; Limit display to prevent overflow
                if (i >= 10) {
                    this.game.d2d.drawText("... and " (this.game.inventory.Length - 10) " more", 70, yPos, 18, 0xFFAAAAAA, "Arial", "w300 h24")
                    break
                }
            }
        }
        
        ; Draw navigation options
        this.game.d2d.drawText("ESC - Back to Customization", this.game.width - 300, this.game.height - 100, 24, 0xFFFFFFFF, "Arial", "w300 h30 aRight")
    }
    
    ; Draw game over screen
    DrawGameOverScreen() {
        ; Draw game over message
        this.game.d2d.drawText("GAME OVER", this.game.width/2 - 200, 200, 72, 0xFFFF0000, "Arial", "w400 h80 aCenter")
        
        ; Draw defeat message
        this.game.d2d.drawText("Your robot was defeated by " this.game.currentOpponent.name, 
                         this.game.width/2 - 300, 300, 36, 0xFFFFFFFF, "Arial", "w600 h40 aCenter")
        
        ; Draw restart prompt
        this.game.d2d.drawText("Press SPACE to return to main menu", 
                         this.game.width/2 - 250, this.game.height - 200, 24, 0xFFFFFFFF, "Arial", "w500 h30 aCenter")
    }
    
    ; Draw victory screen
    DrawVictoryScreen() {
        ; Draw victory message
        this.game.d2d.drawText("VICTORY!", this.game.width/2 - 150, 200, 72, 0xFF00FF00, "Arial", "w300 h80 aCenter")
        
        ; Draw victory text
        victoryText := "You have defeated all opponents and uncovered the secrets of the wasteland.`n`n"
                     . "The Overlord has been defeated, but the wasteland remains.`n`n"
                     . "Perhaps there are more secrets to discover..."
        
        this.game.d2d.drawText(victoryText, this.game.width/2 - 300, 300, 24, 0xFFFFFFFF, "Arial", "w600 h200 aCenter")
        
        ; Draw restart prompt
        this.game.d2d.drawText("Press SPACE to return to main menu",
                         this.game.width/2 - 250, this.game.height - 200, 24, 0xFFFFFFFF, "Arial", "w500 h30 aCenter")
    }
    
    ; Draw settings menu
    DrawSettingsMenu() {
        ; Draw semi-transparent overlay
        this.game.d2d.fillRectangle(0, 0, this.game.width, this.game.height, 0xDD000000)
        
        ; Draw settings panel
        panelWidth := 500
        panelHeight := 400
        panelX := (this.game.width - panelWidth) / 2
        panelY := (this.game.height - panelHeight) / 2
        
        ; Draw panel background
        this.game.d2d.fillRoundedRectangle(panelX, panelY, panelWidth, panelHeight, 15, 15, 0xFF222222)
        this.game.d2d.drawText("SETTINGS", panelX + panelWidth/2, panelY + 20, 28, 0xFFFFFFFF, "Arial", "w150 h40 aCenter")
        
        ; Draw settings options
        optionHeight := 50
        spacing := 10
        
        ; Tutorial toggle - Option 1
        optionY := panelY + 80
        isSelected := (this.game.selectedSettingsOption = 1)
        bgColor := isSelected ? 0xFF444444 : 0xFF333333
        
        this.game.d2d.fillRoundedRectangle(panelX + 30, optionY, panelWidth - 60, optionHeight, 8, 8, bgColor)
        this.game.d2d.drawText("Tutorials", panelX + 50, optionY + optionHeight/2, 18, 0xFFFFFFFF, "Arial", "w100 h30 vCenter")
        
        ; Draw toggle switch for tutorials
        toggleWidth := 80
        toggleHeight := 30
        toggleX := panelX + panelWidth - 50 - toggleWidth
        toggleY := optionY + (optionHeight - toggleHeight) / 2
        
        ; Draw toggle background
        toggleBgColor := this.game.tutorialManager.enabled ? 0xFF00AAFF : 0xFF666666
        this.game.d2d.fillRoundedRectangle(toggleX, toggleY, toggleWidth, toggleHeight, toggleHeight/2, toggleHeight/2, toggleBgColor)
        
        ; Draw toggle knob
        knobSize := toggleHeight - 6
        knobX := this.game.tutorialManager.enabled ? toggleX + toggleWidth - knobSize - 3 : toggleX + 3
        knobY := toggleY + 3
        this.game.d2d.fillEllipse(knobX + knobSize/2, knobY + knobSize/2, knobSize/2, knobSize/2, 0xFFFFFFFF)
        
        ; Draw toggle text
        toggleText := this.game.tutorialManager.enabled ? "ON" : "OFF"
        toggleTextX := this.game.tutorialManager.enabled ? toggleX + 15 : toggleX + toggleWidth - 15
        toggleTextColor := this.game.tutorialManager.enabled ? 0xFFFFFFFF : 0xFFAAAAAA
        this.game.d2d.drawText(toggleText, toggleTextX, toggleY + toggleHeight/2, 14, toggleTextColor, "Arial", "w30 h20 vCenter")
        
        ; Super Attack toggle - Option 2
        optionY := panelY + 80 + optionHeight + spacing
        isSelected := (this.game.selectedSettingsOption = 2)
        bgColor := isSelected ? 0xFF444444 : 0xFF333333
        
        this.game.d2d.fillRoundedRectangle(panelX + 30, optionY, panelWidth - 60, optionHeight, 8, 8, bgColor)
        this.game.d2d.drawText("Super Attack (1000)", panelX + 50, optionY + optionHeight/2, 18, 0xFFFFFFFF, "Arial", "w200 h30 vCenter")
        
        ; Draw toggle switch for cheat mode
        toggleX := panelX + panelWidth - 50 - toggleWidth
        toggleY := optionY + (optionHeight - toggleHeight) / 2
        
        ; Draw toggle background
        toggleBgColor := this.game.cheatModeEnabled ? 0xFFFF5500 : 0xFF666666
        this.game.d2d.fillRoundedRectangle(toggleX, toggleY, toggleWidth, toggleHeight, toggleHeight/2, toggleHeight/2, toggleBgColor)
        
        ; Draw toggle knob
        knobX := this.game.cheatModeEnabled ? toggleX + toggleWidth - knobSize - 3 : toggleX + 3
        knobY := toggleY + 3
        this.game.d2d.fillEllipse(knobX + knobSize/2, knobY + knobSize/2, knobSize/2, knobSize/2, 0xFFFFFFFF)
        
        ; Draw toggle text
        toggleText := this.game.cheatModeEnabled ? "ON" : "OFF"
        toggleTextX := this.game.cheatModeEnabled ? toggleX + 15 : toggleX + toggleWidth - 15
        toggleTextColor := this.game.cheatModeEnabled ? 0xFFFFFFFF : 0xFFAAAAAA
        this.game.d2d.drawText(toggleText, toggleTextX, toggleY + toggleHeight/2, 14, toggleTextColor, "Arial", "w30 h20 vCenter")
        
        ; Draw instructions
        this.game.d2d.drawText("Up/Down - Navigate   |   SPACE - Toggle   |   ESC - Close",
            panelX + panelWidth/2, panelY + panelHeight - 30, 14, 0xFFAAAAAA, "Arial", "w400 h20 aCenter")
    }
}