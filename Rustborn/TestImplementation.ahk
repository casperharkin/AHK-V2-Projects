;==================================================================================================================
; Rustborn Implementation Test
;==================================================================================================================
; Description:    Tests the implementation of the Rustborn game features
;                 Focuses on Save/Load System and Item System
;
; Features:       - Tests Save/Load functionality
;                 - Tests Item System functionality
;                 - Verifies game state persistence
;
; Usage:          Run the script to test the implementation
;
; Dependencies:   - AutoHotkey v2.0
;                 - Rustborn game files
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   13/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include SaveSystem.ahk
#Include ItemSystem.ahk
#Include Debug.ahk

; ==================== Test Functions ====================

; Test Save System
TestSaveSystem() {
    Debug("Testing Save System...", "INFO")
    
    ; Create a save system
    saveSystem := SaveSystem()
    
    ; Create a mock game object
    mockGame := {
        currentState: "TEST_STATE",
        storyProgress: 2,
        selectedMenuOption: 1,
        playerRobot: {
            name: "TestBot",
            description: "A test robot",
            health: 100,
            maxHealth: 100,
            energy: 80,
            maxEnergy: 100,
            attack: 20,
            defense: 15,
            speed: 10,
            accuracy: 12,
            evasion: 8,
            critChance: 5,
            parts: Map(
                "head", {
                    type: "head",
                    name: "Test Head",
                    rarity: "good",
                    elementType: "fire",
                    statBoosts: Map("accuracy", 5, "critChance", 2)
                }
            )
        },
        opponents: [
            {
                name: "TestEnemy",
                description: "A test enemy",
                health: 80,
                maxHealth: 100,
                energy: 70,
                maxEnergy: 100,
                attack: 15,
                defense: 10,
                speed: 8,
                accuracy: 10,
                evasion: 5,
                critChance: 3,
                parts: Map()
            }
        ],
        inventory: [
            {
                type: "torso",
                name: "Test Torso",
                rarity: "epic",
                elementType: "ice",
                statBoosts: Map("health", 50, "defense", 20)
            }
        ],
        itemInventory: []
    }
    
    ; Test saving
    Debug("Saving mock game to slot 1...", "INFO")
    success := saveSystem.saveGame(mockGame, 1)
    
    if (success) {
        Debug("Save successful", "SUCCESS")
    } else {
        Debug("Save failed", "ERROR")
        return false
    }
    
    ; Test loading
    Debug("Loading mock game from slot 1...", "INFO")
    loadedGame := {
        currentState: "",
        storyProgress: 0,
        selectedMenuOption: 0,
        playerRobot: {
            name: "",
            description: "",
            health: 0,
            maxHealth: 0,
            energy: 0,
            maxEnergy: 0,
            attack: 0,
            defense: 0,
            speed: 0,
            accuracy: 0,
            evasion: 0,
            critChance: 0,
            parts: Map()
        },
        opponents: [],
        inventory: [],
        itemInventory: []
    }
    
    success := saveSystem.loadGame(loadedGame, 1)
    
    if (success) {
        Debug("Load successful", "SUCCESS")
        
        ; Verify loaded data
        if (loadedGame.currentState = mockGame.currentState &&
            loadedGame.storyProgress = mockGame.storyProgress &&
            loadedGame.selectedMenuOption = mockGame.selectedMenuOption) {
            Debug("Game state verified", "SUCCESS")
        } else {
            Debug("Game state verification failed", "ERROR")
            return false
        }
    } else {
        Debug("Load failed", "ERROR")
        return false
    }
    
    Debug("Save System test completed successfully", "SUCCESS")
    return true
}

; Test Item System
TestItemSystem() {
    Debug("Testing Item System...", "INFO")
    
    ; Create an item system
    itemSystem := ItemSystem()
    
    ; Create a mock game object
    mockGame := {
        itemInventory: []
    }
    
    ; Test adding random items
    Debug("Adding random items...", "INFO")
    for i in [1, 2, 3, 4, 5] {
        result := itemSystem.addRandomItem(mockGame)
        if (result.success) {
            Debug("Added item: " result.item.name, "SUCCESS")
        } else {
            Debug("Failed to add item", "ERROR")
            return false
        }
    }
    
    ; Verify items were added
    if (mockGame.itemInventory.Length = 5) {
        Debug("Item addition verified: " mockGame.itemInventory.Length " items", "SUCCESS")
    } else {
        Debug("Item addition verification failed", "ERROR")
        return false
    }
    
    ; Test using an item
    Debug("Testing item usage...", "INFO")
    
    ; Create a mock robot
    mockRobot := {
        name: "TestBot",
        health: 50,
        maxHealth: 100,
        energy: 40,
        maxEnergy: 100
    }
    
    ; Add a specific item for testing
    repairKit := itemSystem.createItem("Repair Kit")
    mockGame.itemInventory.Push(repairKit)
    
    ; Create a mock robot object
    mockGame.playerRobot := mockRobot
    
    ; Use the item
    Debug("Using Repair Kit on robot with health: " mockRobot.health, "INFO")
    result := itemSystem.useItem(mockGame, "Repair Kit")
    
    if (result.success) {
        Debug("Item used successfully: " result.message, "SUCCESS")
        
        ; Verify item effect
        if (mockRobot.health > 50) {
            Debug("Item effect verified: health increased to " mockRobot.health, "SUCCESS")
        } else {
            Debug("Item effect verification failed", "ERROR")
            return false
        }
        
        ; Verify item was removed from inventory
        if (mockGame.itemInventory.Length = 5) {
            Debug("Item removal verified", "SUCCESS")
        } else {
            Debug("Item removal verification failed", "ERROR")
            return false
        }
    } else {
        Debug("Item usage failed: " result.message, "ERROR")
        return false
    }
    
    Debug("Item System test completed successfully", "SUCCESS")
    return true
}

; Run tests
RunTests() {
    Debug("Starting Rustborn implementation tests...", "INFO")
    
    ; Test Save System
    saveSystemResult := TestSaveSystem()
    
    ; Test Item System
    itemSystemResult := TestItemSystem()
    
    ; Report results
    if (saveSystemResult && itemSystemResult) {
        Debug("All tests passed successfully!", "SUCCESS")
        MsgBox("All tests passed successfully!", "Test Results", "Icon64")
    } else {
        Debug("Some tests failed", "ERROR")
        MsgBox("Some tests failed. Check the log for details.", "Test Results", "Icon16")
    }
}

; Run the tests
RunTests()