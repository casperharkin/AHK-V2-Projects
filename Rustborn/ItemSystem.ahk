;==================================================================================================================
; Item System
;==================================================================================================================
; Description:    Manages consumable items for the Rustborn game
;                 Provides healing, buffs, and utility effects during battle
;
; Features:       - Item creation and management
;                 - Item effects implementation
;                 - Inventory management for items
;
; Usage:          Include this file and use ItemSystem class methods
;                 Example: itemSystem.useItem(game, "Repair Kit")
;
; Dependencies:   - AutoHotkey v2.0
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   13/03/2025
;==================================================================================================================

; ==================== Item Class ====================
class Item {
    ; Item properties
    name := ""
    description := ""
    type := ""  ; "healing", "buff", "utility"
    rarity := "common"  ; "common", "uncommon", "rare"
    effect := {}
    
    ; Constructor
    __New(name, description, type, rarity, effect) {
        this.name := name
        this.description := description
        this.type := type
        this.rarity := rarity
        this.effect := effect
    }
    
    ; Use the item on a target
    use(target) {
        result := {success: false, message: ""}
        
        ; Apply effect based on item type
        if (this.type = "healing") {
            ; Healing items restore health
            if (this.effect.Has("healthRestore")) {
                oldHealth := target.health
                target.health := Min(target.health + this.effect["healthRestore"], target.maxHealth)
                healAmount := target.health - oldHealth
                
                result.success := true
                result.message := target.name " restored " healAmount " health"
            }
            
            ; Energy restoration
            if (this.effect.Has("energyRestore")) {
                oldEnergy := target.energy
                target.energy := Min(target.energy + this.effect["energyRestore"], target.maxEnergy)
                energyAmount := target.energy - oldEnergy
                
                result.success := true
                result.message := result.message ? result.message "`nand " energyAmount " energy" : target.name " restored " energyAmount " energy"
            }
        } else if (this.type = "buff") {
            ; Buff items temporarily increase stats
            if (this.effect.Has("attackBoost")) {
                target._attack += this.effect["attackBoost"]
                
                result.success := true
                result.message := target.name "'s attack increased by " this.effect["attackBoost"]
            }
            
            if (this.effect.Has("defenseBoost")) {
                target._defense += this.effect["defenseBoost"]
                
                result.success := true
                result.message := result.message ? result.message "`nand defense increased by " this.effect["defenseBoost"] : target.name "'s defense increased by " this.effect["defenseBoost"]
            }
            
            if (this.effect.Has("speedBoost")) {
                target._speed += this.effect["speedBoost"]
                
                result.success := true
                result.message := result.message ? result.message "`nand speed increased by " this.effect["speedBoost"] : target.name "'s speed increased by " this.effect["speedBoost"]
            }
            
            if (this.effect.Has("accuracyBoost")) {
                target._accuracy += this.effect["accuracyBoost"]
                
                result.success := true
                result.message := result.message ? result.message "`nand accuracy increased by " this.effect["accuracyBoost"] : target.name "'s accuracy increased by " this.effect["accuracyBoost"]
            }
            
            if (this.effect.Has("evasionBoost")) {
                target._evasion += this.effect["evasionBoost"]
                
                result.success := true
                result.message := result.message ? result.message "`nand evasion increased by " this.effect["evasionBoost"] : target.name "'s evasion increased by " this.effect["evasionBoost"]
            }
            
            if (this.effect.Has("critChanceBoost")) {
                target._critChance += this.effect["critChanceBoost"]
                
                result.success := true
                result.message := result.message ? result.message "`nand crit chance increased by " this.effect["critChanceBoost"] : target.name "'s crit chance increased by " this.effect["critChanceBoost"]
            }
        } else if (this.type = "utility") {
            ; Utility items have special effects
            if (this.effect.Has("clearDebuffs")) {
                ; Implementation would depend on debuff system
                result.success := true
                result.message := "Cleared all debuffs from " target.name
            }
            
            if (this.effect.Has("revive")) {
                if (target.health <= 0) {
                    target.health := target.maxHealth * this.effect["revive"]
                    
                    result.success := true
                    result.message := target.name " was revived with " target.health " health"
                } else {
                    result.success := false
                    result.message := target.name " is already active"
                }
            }
        }
        
        return result
    }
}

; ==================== Item System Class ====================
class ItemSystem {
    ; Item system properties
    itemTemplates := Map()
    
    ; Constructor
    __New() {
        ; Initialize item templates
        this._initializeItemTemplates()
    }
    
    ; Initialize item templates
    _initializeItemTemplates() {
        ; Healing items
        this.itemTemplates["Repair Kit"] := Item("Repair Kit", "Restores 50 health points", "healing", "common", Map("healthRestore", 50))
        this.itemTemplates["Advanced Repair Kit"] := Item("Advanced Repair Kit", "Restores 100 health points", "healing", "uncommon", Map("healthRestore", 100))
        this.itemTemplates["Full Repair System"] := Item("Full Repair System", "Restores all health points", "healing", "rare", Map("healthRestore", 999))
        
        this.itemTemplates["Energy Cell"] := Item("Energy Cell", "Restores 30 energy points", "healing", "common", Map("energyRestore", 30))
        this.itemTemplates["Power Pack"] := Item("Power Pack", "Restores 60 energy points", "healing", "uncommon", Map("energyRestore", 60))
        this.itemTemplates["Fusion Core"] := Item("Fusion Core", "Restores health and energy", "healing", "rare", Map("healthRestore", 75, "energyRestore", 75))
        
        ; Buff items
        this.itemTemplates["Attack Module"] := Item("Attack Module", "Increases attack by 15", "buff", "common", Map("attackBoost", 15))
        this.itemTemplates["Defense Module"] := Item("Defense Module", "Increases defense by 15", "buff", "common", Map("defenseBoost", 15))
        this.itemTemplates["Speed Module"] := Item("Speed Module", "Increases speed by 10", "buff", "common", Map("speedBoost", 10))
        this.itemTemplates["Targeting System"] := Item("Targeting System", "Increases accuracy by 20", "buff", "uncommon", Map("accuracyBoost", 20))
        this.itemTemplates["Evasion System"] := Item("Evasion System", "Increases evasion by 15", "buff", "uncommon", Map("evasionBoost", 15))
        this.itemTemplates["Critical Module"] := Item("Critical Module", "Increases critical hit chance by 10%", "buff", "rare", Map("critChanceBoost", 10))
        
        ; Utility items
        this.itemTemplates["EMP Grenade"] := Item("EMP Grenade", "Clears all debuffs", "utility", "uncommon", Map("clearDebuffs", true))
        this.itemTemplates["Emergency Reboot"] := Item("Emergency Reboot", "Revives a defeated robot with 50% health", "utility", "rare", Map("revive", 0.5))
    }
    
    ; Create a new item instance from a template
    createItem(itemName) {
        if (this.itemTemplates.Has(itemName)) {
            template := this.itemTemplates[itemName]
            return Item(template.name, template.description, template.type, template.rarity, template.effect.Clone())
        }
        
        return ""
    }
    
    ; Get all available item names
    getItemNames() {
        names := []
        for name, _ in this.itemTemplates {
            names.Push(name)
        }
        return names
    }
    
    ; Get items by type
    getItemsByType(type) {
        items := []
        for name, item in this.itemTemplates {
            if (item.type = type) {
                items.Push(name)
            }
        }
        return items
    }
    
    ; Get items by rarity
    getItemsByRarity(rarity) {
        items := []
        for name, item in this.itemTemplates {
            if (item.rarity = rarity) {
                items.Push(name)
            }
        }
        return items
    }
    
    ; Use an item from inventory on a target
    useItem(game, itemName, target := "") {
        ; Find the item in inventory
        itemIndex := 0
        for i, item in game.itemInventory {
            if (item.name = itemName) {
                itemIndex := i
                break
            }
        }
        
        ; If item not found, return failure
        if (itemIndex = 0) {
            return {success: false, message: "Item not found in inventory"}
        }
        
        ; Get the item
        item := game.itemInventory[itemIndex]
        
        ; Set default target to player robot if not specified
        if (target = "") {
            target := game.playerRobot
        }
        
        ; Use the item
        result := item.use(target)
        
        ; If successful, remove the item from inventory
        if (result.success) {
            game.itemInventory.RemoveAt(itemIndex)
        }
        
        return result
    }
    
    ; Add a random item to inventory based on rarity weights
    addRandomItem(game, rarityWeights := "") {
        ; Default rarity weights if not specified
        if (rarityWeights = "") {
            rarityWeights := {common: 70, uncommon: 25, rare: 5}
        }
        
        ; Determine rarity based on weights
        roll := Random(1, 100)
        rarity := "common"
        
        if (roll > rarityWeights.common) {
            if (roll > rarityWeights.common + rarityWeights.uncommon) {
                rarity := "rare"
            } else {
                rarity := "uncommon"
            }
        }
        
        ; Get items of the selected rarity
        items := this.getItemsByRarity(rarity)
        
        ; If no items of this rarity, try common
        if (items.Length = 0) {
            items := this.getItemsByRarity("common")
        }
        
        ; If still no items, return failure
        if (items.Length = 0) {
            return {success: false, message: "No items available"}
        }
        
        ; Select a random item
        randomItem := items[Random(1, items.Length)]
        
        ; Create and add the item to inventory
        item := this.createItem(randomItem)
        if (item) {
            ; Initialize itemInventory if it doesn't exist
            if (!game.HasOwnProp("itemInventory")) {
                game.itemInventory := []
            }
            
            game.itemInventory.Push(item)
            return {success: true, message: "Added " item.name " to inventory", item: item}
        }
        
        return {success: false, message: "Failed to create item"}
    }
}