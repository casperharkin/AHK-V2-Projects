; ==================== Robot Class ====================
class Robot {
    ; Robot properties
    name := ""
    description := ""
    
    ; Stats
    health := 100
    maxHealth := 100
    energy := 100
    maxEnergy := 100
    
    ; Derived stats - define properties with getters and setters
    _attack := 10
    _defense := 10
    _speed := 10
    _accuracy := 10
    _evasion := 10
    _critChance := 5
    
    ; Battle state
    isDefending := false
    willEvade := false
    
    attack {
        get => this._attack
        set => this._attack := value
    }
    
    defense {
        get => this._defense
        set => this._defense := value
    }
    
    speed {
        get => this._speed
        set => this._speed := value
    }
    
    accuracy {
        get => this._accuracy
        set => this._accuracy := value
    }
    
    evasion {
        get => this._evasion
        set => this._evasion := value
    }
    
    critChance {
        get => this._critChance
        set => this._critChance := value
    }
    
    ; Parts
    parts := Map()
    
    ; Constructor
    __New(name) {
        this.name := name
        
        ; Initialize empty parts
        this.parts := Map(
            "head", "",
            "torso", "",
            "leftArm", "",
            "rightArm", "",
            "leftLeg", "",
            "rightLeg", "",
            "powerCore", ""
        )
    }
    
    ; Equip default parts
    equipDefaultParts() {
        this.equipPart("head", RobotPart("head", "Basic Sensor", "poor", {accuracy: 5, critChance: 2}, ""))
        this.equipPart("torso", RobotPart("torso", "Basic Frame", "poor", {health: 50, defense: 5}, ""))
        this.equipPart("leftArm", RobotPart("leftArm", "Basic Manipulator", "poor", {attack: 5, specialPower: 0}, ""))
        this.equipPart("rightArm", RobotPart("rightArm", "Basic Manipulator", "poor", {attack: 5, specialPower: 0}, ""))
        this.equipPart("leftLeg", RobotPart("leftLeg", "Basic Actuator", "poor", {evasion: 2, speed: 5}, ""))
        this.equipPart("rightLeg", RobotPart("rightLeg", "Basic Actuator", "poor", {evasion: 2, speed: 5}, ""))
        this.equipPart("powerCore", RobotPart("powerCore", "Basic Core", "poor", {energyRegen: 5, specialEfficiency: 0}, ""))
    }
    
    ; Equip a part
    equipPart(partType, part) {
        ; Store old part
        oldPart := this.parts[partType]
        
        ; Equip new part
        this.parts[partType] := part
        
        ; Recalculate stats
        this.calculateStats()
        
        ; Return old part
        return oldPart
    }
    
    ; Remove a part
    removePart(partType) {
        ; Store old part
        oldPart := this.parts[partType]
        
        ; Remove part
        this.parts[partType] := ""
        
        ; Recalculate stats
        this.calculateStats()
        
        ; Return old part
        return oldPart
    }
    
    ; Get a part
    getPart(partType) {
        return this.parts[partType]
    }
    
    ; Calculate stats based on equipped parts
    calculateStats() {
        ; Reset to base stats
        this.maxHealth := 100
        this.maxEnergy := 100
        this._attack := 10
        this._defense := 10
        this._speed := 10
        this._accuracy := 10
        this._evasion := 10
        this._critChance := 5
        
        ; Add stats from parts
        for partType, part in this.parts {
            if (part = "")
                continue
                
            ; Add stat boosts from part
            for statName, statValue in part.statBoosts.OwnProps() {
                if (statName = "health") {
                    this.maxHealth += statValue
                } else if (statName = "energyRegen") {
                    this.maxEnergy += statValue
                } else if (statName = "attack") {
                    this._attack += statValue
                } else if (statName = "defense") {
                    this._defense += statValue
                } else if (statName = "speed") {
                    this._speed += statValue
                } else if (statName = "accuracy") {
                    this._accuracy += statValue
                } else if (statName = "evasion") {
                    this._evasion += statValue
                } else if (statName = "critChance") {
                    this._critChance += statValue
                }
            }
        }
        
        ; Set current health and energy to max if they exceed it
        this.health := Min(this.health, this.maxHealth)
        this.energy := Min(this.energy, this.maxEnergy)
    }
    
    ; Get all stats as a map
    getStats() {
        return Map(
            "Health", this.health "/" this.maxHealth,
            "Energy", this.energy "/" this.maxEnergy,
            "Attack", this.attack,
            "Defense", this.defense,
            "Speed", this.speed,
            "Accuracy", this.accuracy,
            "Evasion", this.evasion,
            "Crit Chance", this.critChance "%"
        )
    }
    
    ; Attack another robot
    attack(target) {
        ; Calculate hit chance
        hitChance := (this.accuracy / (this.accuracy + target.evasion)) * 100
        
        ; Check if attack hits
        if (Random(1, 100) <= hitChance) {
            ; Calculate if critical hit
            isCritical := Random(1, 100) <= this.critChance
            
            ; Calculate damage
            baseDamage := this.attack
            damageMultiplier := isCritical ? 1.5 : 1.0
            damageReduction := target.defense / 100
            
            finalDamage := Round(baseDamage * damageMultiplier * (1 - damageReduction))
            
            ; Apply damage
            target.health -= finalDamage
            if (target.health < 0)
                target.health := 0
                
            ; Return result
            return {hit: true, damage: finalDamage, critical: isCritical}
        } else {
            ; Attack missed
            return {hit: false, damage: 0, critical: false}
        }
    }
    
    ; Defend (reduce incoming damage next turn)
    defend() {
        ; Implement defense boost
    }
    
    ; Use special ability
    useSpecialAbility(target) {
        ; Implement special ability based on parts
    }
}

; ==================== Robot Part Class ====================
class RobotPart {
    ; Part properties
    type := ""
    name := ""
    rarity := "poor"  ; poor, good, epic
    statBoosts := Map()
    elementType := ""  ; fire, ice, lightning, acid, shadow
    
    ; Constructor
    __New(type, name, rarity, statBoosts, elementType := "") {
        this.type := type
        this.name := name
        this.rarity := rarity
        this.statBoosts := statBoosts
        this.elementType := elementType
    }
}