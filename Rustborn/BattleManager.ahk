#Include .\Robot.ahk

; ==================== Battle Manager Class ====================
class BattleManager {
    ; Battle properties
    playerRobot := ""
    enemyRobot := ""
    isPlayerTurn := true
    battleLog := []
    selectedAction := 1  ; 1 = Attack, 2 = Defend, 3 = Special, 4 = Item
    battleEnded := false
    winner := ""
    
    ; Special ability selection
    showingSpecialMenu := false
    selectedSpecial := 1
    availableSpecials := []
    
    ; Constructor
    __New(playerRobot, enemyRobot) {
        OutputDebug("BattleManager constructor called")
        this.playerRobot := playerRobot
        this.enemyRobot := enemyRobot
        this.isPlayerTurn := true
        this.battleLog := ["Battle started!"]
        this.battleEnded := false
        this.selectedAction := 1  ; Explicitly set to 1 (Attack)
        
        OutputDebug("playerRobot: " (playerRobot ? playerRobot.name : "null"))
        OutputDebug("enemyRobot: " (enemyRobot ? enemyRobot.name : "null"))
        
        ; Reset robots for battle
        this.playerRobot.health := this.playerRobot.maxHealth
        this.playerRobot.energy := this.playerRobot.maxEnergy
        this.enemyRobot.health := this.enemyRobot.maxHealth
        this.enemyRobot.energy := this.enemyRobot.maxEnergy
        
        ; Initialize battle state
        this.playerRobot.isDefending := false
        this.playerRobot.willEvade := false
        this.enemyRobot.isDefending := false
        this.enemyRobot.willEvade := false
        
        ; Determine available special abilities based on equipped parts
        this.updateAvailableSpecials()
        
        OutputDebug("BattleManager initialized, selectedAction = " this.selectedAction)
    }
    
    ; Update available special abilities based on equipped parts
    updateAvailableSpecials() {
        this.availableSpecials := []
        
        ; Check each part for elemental types
        for partType, part in this.playerRobot.parts {
            if (part != "" && part.elementType != "") {
                ; Check if we already have this element type
                elementExists := false
                for special in this.availableSpecials {
                    if (special.elementType = part.elementType) {
                        elementExists := true
                        break
                    }
                }
                
                ; If not, add it
                if (!elementExists) {
                    ; Create special ability based on element type
                    special := {}
                    special.elementType := part.elementType
                    
                    ; Set ability name and description based on element type
                    if (part.elementType = "fire") {
                        special.name := "Flame Burst"
                        special.description := "Fire damage + burn effect"
                        special.energyCost := 20
                        special.power := 1.2
                    } else if (part.elementType = "ice") {
                        special.name := "Frost Beam"
                        special.description := "Ice damage + slow effect"
                        special.energyCost := 15
                        special.power := 1.0
                    } else if (part.elementType = "lightning") {
                        special.name := "Shock Strike"
                        special.description := "Lightning damage + critical chance"
                        special.energyCost := 25
                        special.power := 1.3
                    } else if (part.elementType = "acid") {
                        special.name := "Corrosive Spray"
                        special.description := "Acid damage + defense reduction"
                        special.energyCost := 20
                        special.power := 1.1
                    } else if (part.elementType = "shadow") {
                        special.name := "Phantom Strike"
                        special.description := "Shadow damage + evasion chance"
                        special.energyCost := 30
                        special.power := 1.4
                    }
                    
                    this.availableSpecials.Push(special)
                }
            }
        }
    }
    
    ; Execute player action
    executePlayerAction() {
        if (this.battleEnded)
            return
            
        if (!this.isPlayerTurn)
            return
            
        result := {}
        
        OutputDebug("Executing player action: " this.selectedAction)
        
        ; Execute selected action
        if (this.selectedAction = 1) {  ; Attack
            result := this.playerRobot.attack(this.enemyRobot)
            if (result.hit) {
                this.addToBattleLog(this.playerRobot.name " attacks for " result.damage " damage" (result.critical ? " (Critical Hit!)" : ""))
            } else {
                this.addToBattleLog(this.playerRobot.name "'s attack missed!")
            }
        } else if (this.selectedAction = 2) {  ; Defend
            this.playerRobot.isDefending := true
            this.addToBattleLog(this.playerRobot.name " is defending")
        } else if (this.selectedAction = 3) {  ; Special
            if (this.showingSpecialMenu) {
                ; Use selected special ability
                if (this.selectedSpecial <= this.availableSpecials.Length) {
                    special := this.availableSpecials[this.selectedSpecial]
                    
                    ; Check if enough energy
                    if (this.playerRobot.energy >= special.energyCost) {
                        ; Use energy
                        this.playerRobot.energy -= special.energyCost
                        
                        ; Calculate damage
                        baseDamage := this.playerRobot.attack * special.power
                        
                        ; Apply special effects based on element type
                        if (special.elementType = "fire") {
                            ; Fire does extra damage
                            finalDamage := Round(baseDamage * 1.2)
                            this.enemyRobot.health -= finalDamage
                            this.addToBattleLog(this.playerRobot.name " uses " special.name " for " finalDamage " fire damage!")
                        } else if (special.elementType = "ice") {
                            ; Ice slows enemy (reduce speed temporarily)
                            finalDamage := Round(baseDamage)
                            this.enemyRobot.health -= finalDamage
                            this.enemyRobot._speed := this.enemyRobot._speed * 0.7  ; Reduce speed by 30%
                            this.addToBattleLog(this.playerRobot.name " uses " special.name " for " finalDamage " ice damage and slows the enemy!")
                        } else if (special.elementType = "lightning") {
                            ; Lightning has high crit chance
                            isCritical := Random(1, 100) <= 40  ; 40% crit chance
                            damageMultiplier := isCritical ? 2.0 : 1.0
                            finalDamage := Round(baseDamage * damageMultiplier)
                            this.enemyRobot.health -= finalDamage
                            this.addToBattleLog(this.playerRobot.name " uses " special.name " for " finalDamage " lightning damage" (isCritical ? " (Critical Hit!)" : ""))
                        } else if (special.elementType = "acid") {
                            ; Acid reduces defense
                            finalDamage := Round(baseDamage)
                            this.enemyRobot.health -= finalDamage
                            this.enemyRobot._defense := this.enemyRobot._defense * 0.8  ; Reduce defense by 20%
                            this.addToBattleLog(this.playerRobot.name " uses " special.name " for " finalDamage " acid damage and corrodes enemy defense!")
                        } else if (special.elementType = "shadow") {
                            ; Shadow has chance to evade next attack
                            finalDamage := Round(baseDamage)
                            this.enemyRobot.health -= finalDamage
                            this.playerRobot.willEvade := true
                            this.addToBattleLog(this.playerRobot.name " uses " special.name " for " finalDamage " shadow damage and gains evasion!")
                        }
                        
                        ; Ensure health doesn't go below 0
                        if (this.enemyRobot.health < 0)
                            this.enemyRobot.health := 0
                    } else {
                        this.addToBattleLog("Not enough energy to use " special.name "!")
                        return  ; Don't end turn if not enough energy
                    }
                }
                
                ; Hide special menu after using ability
                this.showingSpecialMenu := false
            } else {
                ; Show special menu
                this.showingSpecialMenu := true
                return  ; Don't end turn when showing menu
            }
        } else if (this.selectedAction = 4) {  ; Item (not implemented yet)
            this.addToBattleLog("No items available")
            return  ; Don't end turn if action not available
        }
        
        ; Check if battle ended
        if (this.enemyRobot.health <= 0) {
            this.battleEnded := true
            this.winner := this.playerRobot
            this.addToBattleLog(this.enemyRobot.name " was defeated!")
            return
        }
        
        ; End player turn
        this.isPlayerTurn := false
        
        ; Regenerate some energy
        energyRegen := 5 + (this.playerRobot.maxEnergy / 20)  ; Base + 5% of max
        this.playerRobot.energy := Min(this.playerRobot.energy + energyRegen, this.playerRobot.maxEnergy)
        
        ; Schedule enemy turn
        SetTimer(ObjBindMethod(this, "executeEnemyAction"), -1000)  ; 1 second delay
    }
    
    ; Execute enemy action
    executeEnemyAction() {
        if (this.battleEnded)
            return
            
        if (this.isPlayerTurn)
            return
            
        ; Determine enemy action
        ; Simple AI: 70% chance to attack, 20% chance to defend, 10% chance to use special
        actionRoll := Random(1, 100)
        
        if (actionRoll <= 70) {
            ; Attack
            if (this.playerRobot.willEvade) {
                this.addToBattleLog(this.enemyRobot.name "'s attack was evaded!")
                this.playerRobot.willEvade := false
            } else {
                result := this.enemyRobot.attack(this.playerRobot)
                
                ; Apply defense bonus if defending
                if (this.playerRobot.isDefending && result.hit) {
                    result.damage := Round(result.damage * 0.5)  ; Reduce damage by 50%
                    this.addToBattleLog(this.playerRobot.name " reduced damage by defending!")
                }
                
                if (result.hit) {
                    this.addToBattleLog(this.enemyRobot.name " attacks for " result.damage " damage" (result.critical ? " (Critical Hit!)" : ""))
                } else {
                    this.addToBattleLog(this.enemyRobot.name "'s attack missed!")
                }
            }
        } else if (actionRoll <= 90) {
            ; Defend
            this.enemyRobot.isDefending := true
            this.addToBattleLog(this.enemyRobot.name " is defending")
        } else {
            ; Use special ability if has energy
            if (this.enemyRobot.energy >= 20) {
                ; Find an elemental part
                elementalPart := ""
                for partType, part in this.enemyRobot.parts {
                    if (part != "" && part.elementType != "") {
                        elementalPart := part
                        break
                    }
                }
                
                if (elementalPart != "") {
                    ; Use energy
                    this.enemyRobot.energy -= 20
                    
                    ; Calculate damage
                    baseDamage := this.enemyRobot.attack * 1.2
                    finalDamage := Round(baseDamage)
                    
                    ; Apply damage
                    if (this.playerRobot.isDefending) {
                        finalDamage := Round(finalDamage * 0.5)  ; Reduce damage by 50%
                        this.addToBattleLog(this.playerRobot.name " reduced damage by defending!")
                    }
                    
                    this.playerRobot.health -= finalDamage
                    
                    ; Ensure health doesn't go below 0
                    if (this.playerRobot.health < 0)
                        this.playerRobot.health := 0
                        
                    this.addToBattleLog(this.enemyRobot.name " uses a " elementalPart.elementType " ability for " finalDamage " damage!")
                } else {
                    ; No elemental part, just attack
                    result := this.enemyRobot.attack(this.playerRobot)
                    if (result.hit) {
                        this.addToBattleLog(this.enemyRobot.name " attacks for " result.damage " damage" (result.critical ? " (Critical Hit!)" : ""))
                    } else {
                        this.addToBattleLog(this.enemyRobot.name "'s attack missed!")
                    }
                }
            } else {
                ; Not enough energy, just attack
                result := this.enemyRobot.attack(this.playerRobot)
                if (result.hit) {
                    this.addToBattleLog(this.enemyRobot.name " attacks for " result.damage " damage" (result.critical ? " (Critical Hit!)" : ""))
                } else {
                    this.addToBattleLog(this.enemyRobot.name "'s attack missed!")
                }
            }
        }
        
        ; Check if battle ended
        if (this.playerRobot.health <= 0) {
            this.battleEnded := true
            this.winner := this.enemyRobot
            this.addToBattleLog(this.playerRobot.name " was defeated!")
            return
        }
        
        ; Reset defending status
        this.playerRobot.isDefending := false
        this.enemyRobot.isDefending := false
        
        ; End enemy turn
        this.isPlayerTurn := true
        
        ; Regenerate some energy
        energyRegen := 5 + (this.enemyRobot.maxEnergy / 20)  ; Base + 5% of max
        this.enemyRobot.energy := Min(this.enemyRobot.energy + energyRegen, this.enemyRobot.maxEnergy)
    }
    
    ; Add message to battle log
    addToBattleLog(message) {
        this.battleLog.Push(message)
        
        ; Keep log at a reasonable size
        if (this.battleLog.Length > 10)
            this.battleLog.RemoveAt(1)
    }
    
    ; Navigate battle menu
    navigateUp() {
        OutputDebug("navigateUp called, selectedAction = " this.selectedAction)
        if (this.showingSpecialMenu) {
            ; Navigate special menu
            if (this.selectedSpecial > 1) {
                this.selectedSpecial--
                OutputDebug("selectedSpecial changed to " this.selectedSpecial)
            }
        } else {
            ; Navigate main menu
            if (this.selectedAction > 1) {
                this.selectedAction--
                OutputDebug("selectedAction changed to " this.selectedAction)
            }
        }
    }
    
    navigateDown() {
        OutputDebug("navigateDown called, selectedAction = " this.selectedAction)
        if (this.showingSpecialMenu) {
            ; Navigate special menu
            if (this.selectedSpecial < this.availableSpecials.Length) {
                this.selectedSpecial++
                OutputDebug("selectedSpecial changed to " this.selectedSpecial)
            }
        } else {
            ; Navigate main menu
            if (this.selectedAction < 4) {
                this.selectedAction++
                OutputDebug("selectedAction changed to " this.selectedAction)
            }
        }
    }
    
    ; Cancel special menu
    cancelSpecialMenu() {
        if (this.showingSpecialMenu) {
            this.showingSpecialMenu := false
        }
    }
}