;==================================================================================================================
; Save System
;==================================================================================================================
; Description:    Handles saving and loading game data for Rustborn
;                 Uses JSON format for structured data storage
;
; Features:       - Save game state to JSON files
;                 - Load game state from JSON files
;                 - Multiple save slots
;                 - Auto-save functionality
;
; Usage:          Include this file and use SaveSystem class methods
;                 Example: saveSystem.saveGame(game, 1) to save to slot 1
;
; Dependencies:   - AutoHotkey v2.0
;                 - JSON.ahk library
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   13/03/2025
;==================================================================================================================

; ==================== Save System Class ====================
class SaveSystem {
    ; Save properties
    savePath := A_ScriptDir "\Saves\"
    maxSaveSlots := 5
    autoSaveEnabled := true
    
    ; Constructor
    __New() {
        ; Create saves directory if it doesn't exist
        if (!DirExist(this.savePath)) {
            DirCreate(this.savePath)
            Debug("Created saves directory: " this.savePath, "SUCCESS")
        }
    }
    
    ; Save game to specified slot
    saveGame(game, slot := 0) {
        ; Validate slot number
        if (slot < 0 || slot > this.maxSaveSlots) {
            Debug("Invalid save slot: " slot, "ERROR")
            return false
        }
        
        ; Determine file name (slot 0 is auto-save)
        fileName := slot = 0 ? "autosave.json" : "save" slot ".json"
        filePath := this.savePath fileName
        
        ; Create save data structure
        saveData := this._createSaveData(game)
        
        ; Convert to JSON
        jsonString := this._objectToJson(saveData)
        
        ; Save to file
        try {
            FileDelete(filePath)
            FileAppend(jsonString, filePath)
            Debug("Game saved to " filePath, "SUCCESS")
            return true
        } catch as e {
            Debug("Error saving game: " e.Message, "ERROR")
            return false
        }
    }
    
    ; Load game from specified slot
    loadGame(game, slot := 0) {
        ; Validate slot number
        if (slot < 0 || slot > this.maxSaveSlots) {
            Debug("Invalid save slot: " slot, "ERROR")
            return false
        }
        
        ; Determine file name (slot 0 is auto-save)
        fileName := slot = 0 ? "autosave.json" : "save" slot ".json"
        filePath := this.savePath fileName
        
        ; Check if save file exists
        if (!FileExist(filePath)) {
            Debug("Save file does not exist: " filePath, "WARN")
            return false
        }
        
        ; Load JSON from file
        try {
            jsonString := FileRead(filePath)
            saveData := this._jsonToObject(jsonString)
            
            ; Apply save data to game
            this._applySaveData(game, saveData)
            
            Debug("Game loaded from " filePath, "SUCCESS")
            return true
        } catch as e {
            Debug("Error loading game: " e.Message, "ERROR")
            return false
        }
    }
    
    ; Check if save exists in specified slot
    saveExists(slot := 0) {
        ; Determine file name
        fileName := slot = 0 ? "autosave.json" : "save" slot ".json"
        filePath := this.savePath fileName
        
        return FileExist(filePath) ? true : false
    }
    
    ; Get save info (date, player level, etc.) for a slot
    getSaveInfo(slot := 0) {
        ; Determine file name
        fileName := slot = 0 ? "autosave.json" : "save" slot ".json"
        filePath := this.savePath fileName
        
        ; Check if save file exists
        if (!FileExist(filePath)) {
            return ""
        }
        
        ; Load JSON from file
        try {
            jsonString := FileRead(filePath)
            saveData := this._jsonToObject(jsonString)
            
            ; Extract basic info
            info := {
                saveDate: saveData.metadata.saveDate,
                playerName: saveData.playerRobot.name,
                storyProgress: saveData.gameState.storyProgress,
                defeatedOpponents: saveData.gameState.storyProgress
            }
            
            return info
        } catch as e {
            Debug("Error reading save info: " e.Message, "ERROR")
            return ""
        }
    }
    
    ; Auto-save game
    autoSave(game) {
        if (this.autoSaveEnabled) {
            return this.saveGame(game, 0)
        }
        return false
    }
    
    ; Enable/disable auto-save
    setAutoSave(enabled) {
        this.autoSaveEnabled := enabled
        Debug("Auto-save " (enabled ? "enabled" : "disabled"), "INFO")
    }
    
    ; ==================== Private Methods ====================
    
    ; Create save data structure from game object
    _createSaveData(game) {
        saveData := {}
        
        ; Add metadata
        saveData.metadata := {
            version: "1.0.0",
            saveDate: FormatTime(, "yyyy-MM-dd HH:mm:ss")
        }
        
        ; Add game state
        saveData.gameState := {
            currentState: game.currentState,
            storyProgress: game.storyProgress,
            selectedMenuOption: game.selectedMenuOption
        }
        
        ; Add player robot data
        saveData.playerRobot := this._serializeRobot(game.playerRobot)
        
        ; Add opponents data
        saveData.opponents := []
        for opponent in game.opponents {
            saveData.opponents.Push(this._serializeRobot(opponent))
        }
        
        ; Add inventory data
        saveData.inventory := []
        for part in game.inventory {
            saveData.inventory.Push(this._serializeRobotPart(part))
        }
        
        return saveData
    }
    
    ; Apply save data to game object
    _applySaveData(game, saveData) {
        ; Apply game state
        game.currentState := saveData.gameState.currentState
        game.storyProgress := saveData.gameState.storyProgress
        game.selectedMenuOption := saveData.gameState.selectedMenuOption
        
        ; Apply player robot data
        this._deserializeRobot(game.playerRobot, saveData.playerRobot)
        
        ; Apply opponents data
        for i, opponentData in saveData.opponents {
            if (i <= game.opponents.Length) {
                this._deserializeRobot(game.opponents[i], opponentData)
            }
        }
        
        ; Apply inventory data
        game.inventory := []
        for partData in saveData.inventory {
            game.inventory.Push(this._deserializeRobotPart(partData))
        }
        
        ; Set current opponent based on story progress
        if (game.storyProgress < game.opponents.Length) {
            game.currentOpponent := game.opponents[game.storyProgress + 1]
        }
        
        ; Initialize battle manager with current data
        game.battleManager := BattleManager(game.playerRobot, game.currentOpponent)
    }
    
    ; Serialize robot object to plain object
    _serializeRobot(robot) {
        robotData := {}
        
        ; Basic properties
        robotData.name := robot.name
        robotData.description := robot.description
        robotData.health := robot.health
        robotData.maxHealth := robot.maxHealth
        robotData.energy := robot.energy
        robotData.maxEnergy := robot.maxEnergy
        
        ; Stats
        robotData.attack := robot.attack
        robotData.defense := robot.defense
        robotData.speed := robot.speed
        robotData.accuracy := robot.accuracy
        robotData.evasion := robot.evasion
        robotData.critChance := robot.critChance
        
        ; Parts
        robotData.parts := {}
        for partType, part in robot.parts {
            if (part != "") {
                robotData.parts[partType] := this._serializeRobotPart(part)
            } else {
                robotData.parts[partType] := ""
            }
        }
        
        return robotData
    }
    
    ; Deserialize robot data to robot object
    _deserializeRobot(robot, robotData) {
        ; Basic properties
        robot.name := robotData.name
        robot.description := robotData.description
        robot.health := robotData.health
        robot.maxHealth := robotData.maxHealth
        robot.energy := robotData.energy
        robot.maxEnergy := robotData.maxEnergy
        
        ; Stats
        robot.attack := robotData.attack
        robot.defense := robotData.defense
        robot.speed := robotData.speed
        robot.accuracy := robotData.accuracy
        robot.evasion := robotData.evasion
        robot.critChance := robotData.critChance
        
        ; Parts
        for partType, partData in robotData.parts {
            if (partData != "") {
                part := this._deserializeRobotPart(partData)
                robot.equipPart(partType, part)
            } else {
                robot.removePart(partType)
            }
        }
    }
    
    ; Serialize robot part to plain object
    _serializeRobotPart(part) {
        partData := {}
        
        partData.type := part.type
        partData.name := part.name
        partData.rarity := part.rarity
        partData.elementType := part.elementType
        
        ; Convert stat boosts map to object
        partData.statBoosts := {}
        for stat, value in part.statBoosts.OwnProps() {
            partData.statBoosts[stat] := value
        }
        
        return partData
    }
    
    ; Deserialize part data to robot part object
    _deserializeRobotPart(partData) {
        ; Convert stat boosts object to map
        statBoosts := Map()
        for stat, value in partData.statBoosts.OwnProps() {
            statBoosts[stat] := value
        }
        
        return RobotPart(partData.type, partData.name, partData.rarity, statBoosts, partData.elementType)
    }
    
    ; Convert object to JSON string
    _objectToJson(obj) {
        ; Simple JSON conversion for AHK objects
        ; This is a basic implementation - a more robust JSON library would be better for production
        
        if (IsObject(obj)) {
            if (obj is Array) {
                ; Handle arrays
                items := []
                for value in obj {
                    items.Push(this._objectToJson(value))
                }
                return "[" (items.Length > 0 ? " " items.Join(", ") " " : "") "]"
            } else {
                ; Handle objects/maps
                items := []
                for key, value in obj.OwnProps() {
                    items.Push('"' key '": ' this._objectToJson(value))
                }
                return "{" (items.Length > 0 ? " " items.Join(", ") " " : "") "}"
            }
        } else if (IsNumber(obj)) {
            ; Handle numbers
            return obj
        } else if (obj == true) {
            return "true"
        } else if (obj == false) {
            return "false"
        } else if (obj == "") {
            return '""'
        } else {
            ; Handle strings
            return '"' StrReplace(StrReplace(StrReplace(StrReplace(obj, 
                '\', '\\'), '"', '\"'), '`n', '\n'), '`r', '\r') '"'
        }
    }
    
    ; Convert JSON string to object
    _jsonToObject(jsonString) {
        ; This is a placeholder for a proper JSON parser
        ; In a real implementation, you would use a robust JSON library
        ; For now, we'll use a simple eval-based approach for demonstration
        
        ; WARNING: This is not secure for production use!
        ; A proper JSON library should be used instead
        
        ; For demonstration purposes only
        try {
            ; Parse JSON using a simple regex-based approach
            ; This is a very basic implementation and won't handle all JSON cases correctly
            
            ; Replace JSON syntax with AHK syntax
            ahkScript := jsonString
            
            ; Replace object notation
            ahkScript := RegExReplace(ahkScript, "\{", "Map(")
            ahkScript := RegExReplace(ahkScript, "\}", ")")
            
            ; Replace array notation
            ahkScript := RegExReplace(ahkScript, "\[", "[")
            ahkScript := RegExReplace(ahkScript, "\]", "]")
            
            ; Replace property names
            ahkScript := RegExReplace(ahkScript, '("([^"]+)"\s*:)', "$2,")
            
            ; Execute the script to create the object
            ; NOTE: This is dangerous and should not be used in production!
            ; A proper JSON parser should be used instead
            
            ; For demonstration only - in reality, use a proper JSON library
            return Map()  ; Placeholder - would return the parsed object
        } catch as e {
            Debug("Error parsing JSON: " e.Message, "ERROR")
            return Map()
        }
    }
}