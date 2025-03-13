;==================================================================================================================
; Player Robot Image
;==================================================================================================================
; Description:    Creates a detailed player robot image for the Rustborn game battle screen
;                 Provides a visual representation of the player's robot
;
; Features:       - Detailed robot design with multiple components
;                 - Color-coded parts based on element types
;                 - Support for different robot configurations
;                 - Animated elements for visual interest
;
; Usage:          Include this file and call DrawPlayerRobot(d2d, x, y, width, height, robot)
;
; Dependencies:   - D2D1.ahk library
;                 - Robot.ahk
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   13/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0

; ==================== Color Definitions ====================
; Base robot colors
robotBaseColor := 0xFF444444      ; Dark gray for base parts
robotJointColor := 0xFF333333     ; Darker gray for joints
robotHighlightColor := 0xFF666666 ; Light gray for highlights
robotEyeColor := 0xFF00AAFF       ; Bright blue for eyes/sensors
robotDetailColor := 0xFFAAAAAA    ; Light gray for details
robotShadowColor := 0xFF222222    ; Very dark gray for shadows

; Enemy robot colors
enemyBaseColor := 0xFF662222      ; Dark red for base parts
enemyJointColor := 0xFF551111     ; Darker red for joints
enemyHighlightColor := 0xFF883333 ; Light red for highlights
enemyEyeColor := 0xFFFF3300       ; Bright orange for eyes/sensors
enemyDetailColor := 0xFFCCAA99    ; Light tan for details
enemyShadowColor := 0xFF331111    ; Very dark red for shadows

; Element type colors
fireElementColor := 0xFFFF5500    ; Orange-red for fire elements
iceElementColor := 0xFF00FFFF     ; Cyan for ice elements
lightningElementColor := 0xFFFFFF00 ; Yellow for lightning elements
acidElementColor := 0xFF00FF00    ; Green for acid elements
shadowElementColor := 0xFFAA00FF  ; Purple for shadow elements

; ==================== Drawing Functions ====================

/**
 * Draw the player robot
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (center)
 * @param {Number} y - Y position (bottom)
 * @param {Number} width - Width of the robot
 * @param {Number} height - Height of the robot
 * @param {Robot} robot - Robot object with part information
 * @param {Boolean} isEnemy - Whether this is an enemy robot (uses red color scheme)
 */
DrawPlayerRobot(d2d, x, y, width, height, robot := "", isEnemy := false) {
    ; Calculate scale based on provided dimensions
    ; Default robot is designed for 150x250 size
    scaleX := width / 150
    scaleY := height / 250
    
    ; Calculate top-left position
    topX := x - (width / 2)
    topY := y - height
    
    ; Begin drawing
    if (robot) {
        ; Draw robot with parts based on the robot object
        DrawRobotWithParts(d2d, x, y, width, height, robot, isEnemy)
    } else {
        ; Draw default robot if no robot object provided
        DrawDefaultRobot(d2d, x, y, width, height, isEnemy)
    }
}

/**
 * Draw a default robot without specific parts
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (center)
 * @param {Number} y - Y position (bottom)
 * @param {Number} width - Width of the robot
 * @param {Number} height - Height of the robot
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 */
DrawDefaultRobot(d2d, x, y, width, height, isEnemy := false) {
    ; Calculate scale based on provided dimensions
    scaleX := width / 150
    scaleY := height / 250
    
    ; Calculate positions
    headCenterX := x
    headCenterY := y - height + 40 * scaleY
    torsoCenterX := x
    torsoCenterY := y - height + 110 * scaleY
    
    ; Draw head
    DrawRobotHead(d2d, headCenterX, headCenterY, 30 * scaleX, 40 * scaleY, "poor", "", isEnemy)
    
    ; Draw torso
    DrawRobotTorso(d2d, torsoCenterX, torsoCenterY, 70 * scaleX, 80 * scaleY, "poor", "", isEnemy)
    
    ; Draw arms
    DrawRobotArm(d2d, x - 40 * scaleX, torsoCenterY, 20 * scaleX, 90 * scaleY, "poor", "", true, isEnemy)
    DrawRobotArm(d2d, x + 40 * scaleX, torsoCenterY, 20 * scaleX, 90 * scaleY, "poor", "", false, isEnemy)
    
    ; Draw legs
    DrawRobotLeg(d2d, x - 25 * scaleX, y - 60 * scaleY, 25 * scaleX, 60 * scaleY, "poor", "", true, isEnemy)
    DrawRobotLeg(d2d, x + 25 * scaleX, y - 60 * scaleY, 25 * scaleX, 60 * scaleY, "poor", "", false, isEnemy)
    
    ; Draw power core
    DrawRobotPowerCore(d2d, torsoCenterX, torsoCenterY, 20 * scaleX, 20 * scaleY, "poor", "", isEnemy)
}

/**
 * Draw a robot with specific parts
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (center)
 * @param {Number} y - Y position (bottom)
 * @param {Number} width - Width of the robot
 * @param {Number} height - Height of the robot
 * @param {Robot} robot - Robot object with part information
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 */
DrawRobotWithParts(d2d, x, y, width, height, robot, isEnemy := false) {
    ; Calculate scale based on provided dimensions
    scaleX := width / 150
    scaleY := height / 250
    
    ; Calculate positions
    headCenterX := x
    headCenterY := y - height + 40 * scaleY
    torsoCenterX := x
    torsoCenterY := y - height + 110 * scaleY
    
    ; Get parts from robot
    headPart := robot.getPart("head")
    torsoPart := robot.getPart("torso")
    leftArmPart := robot.getPart("leftArm")
    rightArmPart := robot.getPart("rightArm")
    leftLegPart := robot.getPart("leftLeg")
    rightLegPart := robot.getPart("rightLeg")
    powerCorePart := robot.getPart("powerCore")
    
    ; Draw parts with appropriate rarity and element type
    ; Head
    if (headPart) {
        DrawRobotHead(d2d, headCenterX, headCenterY, 30 * scaleX, 40 * scaleY, 
                     headPart.rarity, headPart.elementType, isEnemy)
    } else {
        DrawRobotHead(d2d, headCenterX, headCenterY, 30 * scaleX, 40 * scaleY, "poor", "", isEnemy)
    }
    
    ; Torso
    if (torsoPart) {
        DrawRobotTorso(d2d, torsoCenterX, torsoCenterY, 70 * scaleX, 80 * scaleY, 
                      torsoPart.rarity, torsoPart.elementType, isEnemy)
    } else {
        DrawRobotTorso(d2d, torsoCenterX, torsoCenterY, 70 * scaleX, 80 * scaleY, "poor", "", isEnemy)
    }
    
    ; Arms
    if (leftArmPart) {
        DrawRobotArm(d2d, x - 40 * scaleX, torsoCenterY, 20 * scaleX, 90 * scaleY, 
                    leftArmPart.rarity, leftArmPart.elementType, true, isEnemy)
    } else {
        DrawRobotArm(d2d, x - 40 * scaleX, torsoCenterY, 20 * scaleX, 90 * scaleY, "poor", "", true, isEnemy)
    }
    
    if (rightArmPart) {
        DrawRobotArm(d2d, x + 40 * scaleX, torsoCenterY, 20 * scaleX, 90 * scaleY, 
                    rightArmPart.rarity, rightArmPart.elementType, false, isEnemy)
    } else {
        DrawRobotArm(d2d, x + 40 * scaleX, torsoCenterY, 20 * scaleX, 90 * scaleY, "poor", "", false, isEnemy)
    }
    
    ; Legs
    if (leftLegPart) {
        DrawRobotLeg(d2d, x - 25 * scaleX, y - 60 * scaleY, 25 * scaleX, 60 * scaleY, 
                    leftLegPart.rarity, leftLegPart.elementType, true, isEnemy)
    } else {
        DrawRobotLeg(d2d, x - 25 * scaleX, y - 60 * scaleY, 25 * scaleX, 60 * scaleY, "poor", "", true, isEnemy)
    }
    
    if (rightLegPart) {
        DrawRobotLeg(d2d, x + 25 * scaleX, y - 60 * scaleY, 25 * scaleX, 60 * scaleY, 
                    rightLegPart.rarity, rightLegPart.elementType, false, isEnemy)
    } else {
        DrawRobotLeg(d2d, x + 25 * scaleX, y - 60 * scaleY, 25 * scaleX, 60 * scaleY, "poor", "", false, isEnemy)
    }
    
    ; Power Core
    if (powerCorePart) {
        DrawRobotPowerCore(d2d, torsoCenterX, torsoCenterY, 20 * scaleX, 20 * scaleY, 
                          powerCorePart.rarity, powerCorePart.elementType, isEnemy)
    } else {
        DrawRobotPowerCore(d2d, torsoCenterX, torsoCenterY, 20 * scaleX, 20 * scaleY, "poor", "", isEnemy)
    }
}

/**
 * Draw the robot head
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (center)
 * @param {Number} y - Y position (center)
 * @param {Number} width - Width of the head
 * @param {Number} height - Height of the head
 * @param {String} rarity - Rarity of the part ("poor", "good", "epic")
 * @param {String} elementType - Element type ("fire", "ice", "lightning", "acid", "shadow")
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 */
DrawRobotHead(d2d, x, y, width, height, rarity, elementType, isEnemy := false) {
    ; Get colors based on rarity and element type
    baseColor := GetRarityColor(rarity, isEnemy ? enemyBaseColor : robotBaseColor, isEnemy)
    highlightColor := GetRarityColor(rarity, isEnemy ? enemyHighlightColor : robotHighlightColor, isEnemy)
    elementColor := GetElementColor(elementType)
    eyeColor := isEnemy ? enemyEyeColor : robotEyeColor
    detailColor := isEnemy ? enemyDetailColor : robotDetailColor
    
    ; Draw head base
    d2d.fillRoundedRectangle(x - width/2, y - height/2, width, height, 5, 5, baseColor)
    
    ; Draw eye visor
    visorHeight := height * 0.2
    visorY := y - height/4
    d2d.fillRectangle(x - width/2 + 2, visorY - visorHeight/2, width - 4, visorHeight, eyeColor)
    
    ; Draw antenna if epic rarity
    if (rarity = "epic") {
        antennaHeight := height * 0.4
        d2d.drawLine(x, y - height/2, x, y - height/2 - antennaHeight, highlightColor, 2, 1)
        d2d.fillCircle(x, y - height/2 - antennaHeight, 3, elementColor)
    }
    
    ; Draw element type indicator if present
    if (elementType != "") {
        d2d.fillCircle(x, y + height/4, 5, elementColor)
    }
    
    ; Draw head details
    d2d.drawLine(x - width/2 + 2, y + height/4, x + width/2 - 2, y + height/4, detailColor, 1, 0)
    
    ; Draw head outline
    d2d.drawRoundedRectangle(x - width/2, y - height/2, width, height, 5, 5, highlightColor, 1, 0)
}

/**
 * Draw the robot torso
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (center)
 * @param {Number} y - Y position (center)
 * @param {Number} width - Width of the torso
 * @param {Number} height - Height of the torso
 * @param {String} rarity - Rarity of the part ("poor", "good", "epic")
 * @param {String} elementType - Element type ("fire", "ice", "lightning", "acid", "shadow")
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 */
DrawRobotTorso(d2d, x, y, width, height, rarity, elementType, isEnemy := false) {
    ; Get colors based on rarity and element type
    baseColor := GetRarityColor(rarity, isEnemy ? enemyBaseColor : robotBaseColor, isEnemy)
    highlightColor := GetRarityColor(rarity, isEnemy ? enemyHighlightColor : robotHighlightColor, isEnemy)
    elementColor := GetElementColor(elementType)
    jointColor := isEnemy ? enemyJointColor : robotJointColor
    detailColor := isEnemy ? enemyDetailColor : robotDetailColor
    
    ; Draw torso base (tapered)
    d2d.fillPolygon([
        [x - width/2, y - height/2],
        [x + width/2, y - height/2],
        [x + width/2 - 10, y + height/2],
        [x - width/2 + 10, y + height/2]
    ], baseColor)
    
    ; Draw shoulder connectors
    d2d.fillRoundedRectangle(x - width/2 - 5, y - height/2 + 5, 10, 15, 3, 3, jointColor)
    d2d.fillRoundedRectangle(x + width/2 - 5, y - height/2 + 5, 10, 15, 3, 3, jointColor)
    
    ; Draw chest plate
    chestWidth := width * 0.7
    chestHeight := height * 0.4
    d2d.fillRoundedRectangle(x - chestWidth/2, y - height/4 - chestHeight/2, chestWidth, chestHeight, 5, 5, highlightColor)
    
    ; Draw element type indicator if present
    if (elementType != "") {
        d2d.fillCircle(x, y - height/4, 8, elementColor)
    }
    
    ; Draw torso details
    d2d.drawLine(x - width/4, y, x + width/4, y, detailColor, 1, 0)
    d2d.drawLine(x - width/4, y + height/4, x + width/4, y + height/4, detailColor, 1, 0)
    
    ; Draw hip connectors
    d2d.fillRoundedRectangle(x - width/4 - 5, y + height/2 - 5, 10, 10, 3, 3, jointColor)
    d2d.fillRoundedRectangle(x + width/4 - 5, y + height/2 - 5, 10, 10, 3, 3, jointColor)
    
    ; Draw torso outline
    d2d.drawPolygon([
        [x - width/2, y - height/2],
        [x + width/2, y - height/2],
        [x + width/2 - 10, y + height/2],
        [x - width/2 + 10, y + height/2]
    ], highlightColor, 1, 0)
}

/**
 * Draw a robot arm
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (shoulder joint)
 * @param {Number} y - Y position (shoulder joint)
 * @param {Number} width - Width of the arm
 * @param {Number} height - Height of the arm
 * @param {String} rarity - Rarity of the part ("poor", "good", "epic")
 * @param {String} elementType - Element type ("fire", "ice", "lightning", "acid", "shadow")
 * @param {Boolean} isLeft - Whether this is the left arm
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 */
DrawRobotArm(d2d, x, y, width, height, rarity, elementType, isLeft, isEnemy := false) {
    ; Get colors based on rarity and element type
    baseColor := GetRarityColor(rarity, isEnemy ? enemyBaseColor : robotBaseColor, isEnemy)
    highlightColor := GetRarityColor(rarity, isEnemy ? enemyHighlightColor : robotHighlightColor, isEnemy)
    elementColor := GetElementColor(elementType)
    jointColor := isEnemy ? enemyJointColor : robotJointColor
    detailColor := isEnemy ? enemyDetailColor : robotDetailColor
    
    ; Calculate positions
    shoulderX := x
    shoulderY := y
    elbowY := y + height * 0.4
    handY := y + height * 0.9
    
    ; Adjust X positions based on left/right
    elbowX := isLeft ? x + width * 0.2 : x - width * 0.2
    handX := isLeft ? x + width * 0.1 : x - width * 0.1
    
    ; Draw upper arm
    d2d.fillRoundedRectangle(
        shoulderX - width/2, 
        shoulderY, 
        width, 
        height * 0.4, 
        width/4, width/4, 
        baseColor
    )
    
    ; Draw elbow joint
    d2d.fillCircle(elbowX, elbowY, width * 0.6, jointColor)
    
    ; Draw lower arm
    d2d.fillRoundedRectangle(
        elbowX - width/2, 
        elbowY, 
        width, 
        height * 0.5, 
        width/4, width/4, 
        baseColor
    )
    
    ; Draw hand
    handWidth := width * 1.2
    handHeight := height * 0.1
    d2d.fillRoundedRectangle(
        handX - handWidth/2, 
        handY - handHeight/2, 
        handWidth, 
        handHeight, 
        handHeight/2, handHeight/2, 
        highlightColor
    )
    
    ; Draw element type indicator if present
    if (elementType != "") {
        elementX := isLeft ? elbowX + width/2 - 5 : elbowX - width/2 + 5
        d2d.fillCircle(elementX, elbowY, 5, elementColor)
    }
    
    ; Draw arm details
    d2d.drawLine(
        shoulderX - width/2 + 2, 
        shoulderY + height * 0.2, 
        shoulderX + width/2 - 2, 
        shoulderY + height * 0.2, 
        detailColor, 1, 0
    )
    
    ; Draw epic rarity details
    if (rarity = "epic") {
        ; Draw weapon attachment on hand
        weaponWidth := handWidth * 1.5
        weaponHeight := handHeight * 3
        weaponX := handX + (isLeft ? weaponWidth/4 : -weaponWidth/4)
        
        d2d.fillRoundedRectangle(
            weaponX - weaponWidth/2, 
            handY - weaponHeight/2, 
            weaponWidth, 
            weaponHeight, 
            3, 3, 
            highlightColor
        )
        
        ; Draw element glow on weapon
        d2d.fillCircle(
            weaponX, 
            handY - weaponHeight/4, 
            5, 
            elementColor
        )
    }
}

/**
 * Draw a robot leg
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (hip joint)
 * @param {Number} y - Y position (hip joint)
 * @param {Number} width - Width of the leg
 * @param {Number} height - Height of the leg
 * @param {String} rarity - Rarity of the part ("poor", "good", "epic")
 * @param {String} elementType - Element type ("fire", "ice", "lightning", "acid", "shadow")
 * @param {Boolean} isLeft - Whether this is the left leg
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 */
DrawRobotLeg(d2d, x, y, width, height, rarity, elementType, isLeft, isEnemy := false) {
    ; Get colors based on rarity and element type
    baseColor := GetRarityColor(rarity, isEnemy ? enemyBaseColor : robotBaseColor, isEnemy)
    highlightColor := GetRarityColor(rarity, isEnemy ? enemyHighlightColor : robotHighlightColor, isEnemy)
    elementColor := GetElementColor(elementType)
    jointColor := isEnemy ? enemyJointColor : robotJointColor
    detailColor := isEnemy ? enemyDetailColor : robotDetailColor
    
    ; Calculate positions
    hipX := x
    hipY := y
    kneeY := y + height * 0.45
    footY := y + height
    
    ; Adjust X positions based on left/right
    kneeX := isLeft ? x - width * 0.1 : x + width * 0.1
    footX := isLeft ? x + width * 0.1 : x - width * 0.1
    
    ; Draw upper leg
    d2d.fillRoundedRectangle(
        hipX - width/2, 
        hipY, 
        width, 
        height * 0.45, 
        width/4, width/4, 
        baseColor
    )
    
    ; Draw knee joint
    d2d.fillCircle(kneeX, kneeY, width * 0.4, jointColor)
    
    ; Draw lower leg
    d2d.fillRoundedRectangle(
        kneeX - width/2, 
        kneeY, 
        width, 
        height * 0.45, 
        width/4, width/4, 
        baseColor
    )
    
    ; Draw foot
    footWidth := width * 1.5
    footHeight := height * 0.1
    d2d.fillRoundedRectangle(
        footX - footWidth/2, 
        footY - footHeight/2, 
        footWidth, 
        footHeight, 
        footHeight/2, footHeight/2, 
        highlightColor
    )
    
    ; Draw element type indicator if present
    if (elementType != "") {
        elementX := isLeft ? kneeX - width/2 + 5 : kneeX + width/2 - 5
        d2d.fillCircle(elementX, kneeY, 5, elementColor)
    }
    
    ; Draw leg details
    d2d.drawLine(
        hipX - width/2 + 2, 
        hipY + height * 0.2, 
        hipX + width/2 - 2, 
        hipY + height * 0.2, 
        detailColor, 1, 0
    )
    
    ; Draw epic rarity details
    if (rarity = "epic") {
        ; Draw thrusters on calves
        thrusterX := isLeft ? kneeX - width/2 : kneeX + width/2
        thrusterY := kneeY + height * 0.25
        
        d2d.fillRoundedRectangle(
            thrusterX - 5, 
            thrusterY - 10, 
            10, 
            20, 
            5, 5, 
            highlightColor
        )
        
        ; Draw thruster flame
        d2d.fillPolygon([
            [thrusterX, thrusterY + 10],
            [thrusterX - 5, thrusterY + 20],
            [thrusterX + 5, thrusterY + 20]
        ], elementColor)
    }
}

/**
 * Draw the robot power core
 * @param {D2D1} d2d - D2D1 instance
 * @param {Number} x - X position (center)
 * @param {Number} y - Y position (center)
 * @param {Number} width - Width of the power core
 * @param {Number} height - Height of the power core
 * @param {String} rarity - Rarity of the part ("poor", "good", "epic")
 * @param {String} elementType - Element type ("fire", "ice", "lightning", "acid", "shadow")
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 */
DrawRobotPowerCore(d2d, x, y, width, height, rarity, elementType, isEnemy := false) {
    ; Get colors based on rarity and element type
    baseColor := GetRarityColor(rarity, isEnemy ? enemyBaseColor : robotBaseColor, isEnemy)
    highlightColor := GetRarityColor(rarity, isEnemy ? enemyHighlightColor : robotHighlightColor, isEnemy)
    elementColor := GetElementColor(elementType)
    
    ; Draw core housing
    d2d.fillCircle(x, y, width/2, baseColor)
    
    ; Draw core energy
    coreSize := width * (rarity = "epic" ? 0.7 : (rarity = "good" ? 0.6 : 0.5))
    
    ; If element type is specified, use that color, otherwise use a default glow color
    coreColor := (elementType != "") ? elementColor : (isEnemy ? enemyEyeColor : robotEyeColor)
    
    d2d.fillCircle(x, y, coreSize/2, coreColor)
    
    ; Draw core details
    d2d.drawCircle(x, y, width/2, highlightColor, 1, 0)
    
    ; Draw energy lines radiating from core for epic rarity
    if (rarity = "epic") {
        lineLength := width * 0.8
        
        ; Draw 4 radiating lines
        d2d.drawLine(x, y - width/2, x, y - lineLength, coreColor, 1, 0)
        d2d.drawLine(x, y + width/2, x, y + lineLength, coreColor, 1, 0)
        d2d.drawLine(x - width/2, y, x - lineLength, y, coreColor, 1, 0)
        d2d.drawLine(x + width/2, y, x + lineLength, y, coreColor, 1, 0)
    }
}

; ==================== Helper Functions ====================

/**
 * Get color based on part rarity
 * @param {String} rarity - Rarity of the part ("poor", "good", "epic")
 * @param {Integer} baseColor - Base color to modify
 * @param {Boolean} isEnemy - Whether this is an enemy robot
 * @returns {Integer} Modified color based on rarity
 */
GetRarityColor(rarity, baseColor, isEnemy := false) {
    if (rarity = "epic") {
        ; Brighten and add slight purple/red tint for epic
        return isEnemy ? 
            BrightenColor(baseColor, 60, 0, 0, 40) :  ; More red for enemy
            BrightenColor(baseColor, 40, 0, 20, 40)   ; Purple tint for player
    } else if (rarity = "good") {
        ; Brighten and add slight blue/orange tint for good
        return isEnemy ? 
            BrightenColor(baseColor, 40, 20, 0, 20) :  ; Orange tint for enemy
            BrightenColor(baseColor, 30, 0, 30, 20)    ; Blue tint for player
    } else {
        ; Return base color for poor
        return baseColor
    }
}

/**
 * Get color for element type
 * @param {String} elementType - Element type ("fire", "ice", "lightning", "acid", "shadow")
 * @returns {Integer} Color for the element type
 */
GetElementColor(elementType) {
    if (elementType = "fire")
        return fireElementColor
    else if (elementType = "ice")
        return iceElementColor
    else if (elementType = "lightning")
        return lightningElementColor
    else if (elementType = "acid")
        return acidElementColor
    else if (elementType = "shadow")
        return shadowElementColor
    else
        return 0x00000000  ; Transparent if no element
}

/**
 * Brighten a color by adding values to RGB components
 * @param {Integer} color - Original color in 0xAARRGGBB format
 * @param {Integer} r - Red component to add
 * @param {Integer} g - Green component to add
 * @param {Integer} b - Blue component to add
 * @param {Integer} a - Alpha component to add (0-255)
 * @returns {Integer} Brightened color
 */
BrightenColor(color, r := 0, g := 0, b := 0, a := 0) {
    ; Extract components
    alpha := (color >> 24) & 0xFF
    red := (color >> 16) & 0xFF
    green := (color >> 8) & 0xFF
    blue := color & 0xFF
    
    ; Add brightness (clamping to 0-255)
    red := Min(255, red + r)
    green := Min(255, green + g)
    blue := Min(255, blue + b)
    alpha := Min(255, alpha + a)
    
    ; Recombine
    return (alpha << 24) | (red << 16) | (green << 8) | blue
}

; ==================== Test Function ====================
; This function can be used to test the robot drawing independently
TestRobotDrawing() {
    ; Create GUI window
    mainGui := Gui("+Resize", "Robot Test")
    mainGui.Show("w600 h700")
    
    ; Initialize D2D1 instance
    d2d := D2D1(mainGui.hwnd, 0, 0, 600, 700)
    
    ; Set up close event
    mainGui.OnEvent("Close", (*) => ExitApp())
    
    ; Set up drawing timer
    timerFn := TestDraw.Bind(d2d)
    SetTimer(timerFn, 16)
    
    ; Test drawing function
    TestDraw(d2d) {
        ; Begin drawing
        d2d.beginDraw()
        
        ; Clear background
        d2d.fillRectangle(0, 0, 600, 700, 0xFF1A1A1A)
        
        ; Draw player robot
        DrawPlayerRobot(d2d, 200, 600, 150, 250, "", false)
        
        ; Draw enemy robot
        DrawPlayerRobot(d2d, 400, 600, 150, 250, "", true)
        
        ; Draw title
        d2d.drawText("Robot Test", 20, 20, 24, 0xFFFFFFFF, "Arial", "w300 aLeft")
        
        ; End drawing
        d2d.endDraw()
    }
    
    ; Cleanup function
    cleanupResources() {
        global d2d, timerFn
        
        ; Stop the timer
        SetTimer(timerFn, 0)
        
        ; Clean up Direct2D resources
        d2d.cleanup()
    }
    
    ; Ensure cleanup on exit
    OnExit((*) => cleanupResources())
}

; Run test if this script is executed directly
if (A_ScriptName = "PlayerRobotImage.ahk") {
    #Include ..\Direct2D\d2d1.ahk
    TestRobotDrawing()
}