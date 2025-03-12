;==================================================================================================================
; Fighter Jet Drawing
;==================================================================================================================
; Description:    Creates a detailed fighter jet drawing using Direct2D graphics
;                 Demonstrates complex shape composition and color usage
;
; Features:       - Realistic fighter jet design with multiple components
;                 - Detailed cockpit, wings, engines, and weaponry
;                 - Color gradients and shading for depth
;                 - Animated engine exhaust
;
; Usage:          Run the script to view the fighter jet drawing
;
; Hotkeys:        F10 - Reload script
;                 F12 - Exit application
;
; Dependencies:   - D2D1.ahk library
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   10/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\d2d1.ahk

; ==================== Initialization ====================
; Create GUI window
mainGui := Gui("+Resize", "Fighter Jet Drawing")
mainGui.Show("w1000 h700")

; Initialize D2D1 instance
d2d := D2D1(mainGui.hwnd, 0, 0, 1000, 700)

; Set up close event
mainGui.OnEvent("Close", (*) => ExitApp())

; ==================== Color Definitions ====================
; Define colors
jetBodyColor := 0xFF2F4F4F      ; Dark slate gray
jetHighlightColor := 0xFF4682B4  ; Steel blue
jetCockpitColor := 0xAA87CEEB    ; Sky blue (semi-transparent)
jetEngineColor := 0xFF696969     ; Dim gray
jetMissileColor := 0xFF708090    ; Slate gray
jetWarningColor := 0xFFFF4500    ; Orange red
jetMetalColor := 0xFFA9A9A9      ; Dark gray
jetShadowColor := 0xFF1A1A1A     ; Very dark gray
jetExhaustColor := 0xFFCD5C5C    ; Indian red
jetExhaustGlowColor := 0xFFFF6347 ; Tomato red

; ==================== Animation Variables ====================
exhaustFlicker := 0
animationCounter := 0

; ==================== Timer Setup ====================
; 60fps refresh rate
timerFn := Draw.Bind(d2d)
SetTimer(timerFn, 16)

; ==================== Drawing Functions ====================
; Main drawing function
; @param {D2D1} d2d - D2D1 instance
Draw(d2d) {
    ; Update animation variables
    global exhaustFlicker, animationCounter
    animationCounter++
    if (Mod(animationCounter, 5) = 0)
        exhaustFlicker := !exhaustFlicker
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background with sky gradient
    drawSkyBackground(d2d)
    
    ; Draw fighter jet
    drawFighterJet(d2d, 500, 350, exhaustFlicker)
    
    ; Draw title
    d2d.drawText("F-22 Raptor", 20, 20, 24, 0xFFFFFFFF, "Arial", "w300 aLeft")
    d2d.drawText("Advanced Tactical Fighter", 20, 50, 16, 0xFFDDDDDD, "Arial", "w300 aLeft")
    
    ; End drawing
    d2d.endDraw()
}

; Draw sky background with gradient
; @param {D2D1} d2d - D2D1 instance
drawSkyBackground(d2d) {
    ; Draw gradient sky background
    steps := 20
    height := 700
    stepHeight := height / steps
    
    Loop steps {
        i := A_Index - 1  ; To get values 0 to steps-1
        
        ; Calculate color components (darker at top, lighter at bottom)
        r := Round(100 + (155 * i / steps))
        g := Round(150 + (105 * i / steps))
        b := Round(200 + (55 * i / steps))
        
        ; Create color
        color := (0xFF << 24) | (r << 16) | (g << 8) | b
        
        ; Draw gradient rectangle
        d2d.fillRectangle(0, i * stepHeight, 1000, stepHeight, color)
    }
    
    ; Add some clouds
    d2d.fillCircle(200, 100, 40, 0xAAFFFFFF)
    d2d.fillCircle(240, 90, 50, 0xAAFFFFFF)
    d2d.fillCircle(280, 110, 35, 0xAAFFFFFF)
    
    d2d.fillCircle(700, 150, 50, 0xAAFFFFFF)
    d2d.fillCircle(750, 140, 60, 0xAAFFFFFF)
    d2d.fillCircle(800, 160, 45, 0xAAFFFFFF)
}

; Draw the fighter jet
; @param {D2D1} d2d - D2D1 instance
; @param {Number} centerX - Center X coordinate
; @param {Number} centerY - Center Y coordinate
; @param {Boolean} exhaustOn - Whether to show engine exhaust
drawFighterJet(d2d, centerX, centerY, exhaustOn) {
    global jetBodyColor, jetHighlightColor, jetCockpitColor, jetEngineColor
    global jetMissileColor, jetWarningColor, jetMetalColor, jetShadowColor
    global jetExhaustColor, jetExhaustGlowColor
    
    ; ==================== Draw Engine Exhaust (behind) ====================
    if (exhaustOn) {
        ; Left engine exhaust
        d2d.fillCircle(centerX - 40, centerY + 15, 12, jetExhaustGlowColor)
        d2d.fillCircle(centerX - 50, centerY + 15, 8, 0xFFFFFF00)
        
        ; Right engine exhaust
        d2d.fillCircle(centerX + 40, centerY + 15, 12, jetExhaustGlowColor)
        d2d.fillCircle(centerX + 50, centerY + 15, 8, 0xFFFFFF00)
    }
    
    ; ==================== Draw Main Body (Fuselage) ====================
    ; Main fuselage (body)
    d2d.fillRoundedRectangle(centerX - 150, centerY - 20, 300, 40, 10, 10, jetBodyColor)
    
    ; Nose cone
    d2d.fillPolygon([
        [centerX - 150, centerY - 20],
        [centerX - 150, centerY + 20],
        [centerX - 200, centerY]
    ], jetBodyColor)
    
    ; Rear fuselage (tapered)
    d2d.fillPolygon([
        [centerX + 150, centerY - 20],
        [centerX + 150, centerY + 20],
        [centerX + 200, centerY - 10],
        [centerX + 200, centerY + 10]
    ], jetBodyColor)
    
    ; ==================== Draw Wings ====================
    ; Left main wing
    d2d.fillPolygon([
        [centerX - 100, centerY - 5],
        [centerX - 50, centerY - 5],
        [centerX - 120, centerY - 80],
        [centerX - 150, centerY - 80]
    ], jetHighlightColor)
    
    ; Right main wing
    d2d.fillPolygon([
        [centerX + 100, centerY - 5],
        [centerX + 50, centerY - 5],
        [centerX + 120, centerY - 80],
        [centerX + 150, centerY - 80]
    ], jetHighlightColor)
    
    ; Left rear wing (horizontal stabilizer)
    d2d.fillPolygon([
        [centerX + 120, centerY - 5],
        [centerX + 150, centerY - 5],
        [centerX + 180, centerY - 40],
        [centerX + 160, centerY - 40]
    ], jetHighlightColor)
    
    ; Right rear wing (horizontal stabilizer)
    d2d.fillPolygon([
        [centerX + 120, centerY + 5],
        [centerX + 150, centerY + 5],
        [centerX + 180, centerY + 40],
        [centerX + 160, centerY + 40]
    ], jetHighlightColor)
    
    ; ==================== Draw Vertical Stabilizers (Tail Fins) ====================
    ; Main vertical stabilizer
    d2d.fillPolygon([
        [centerX + 140, centerY - 20],
        [centerX + 180, centerY - 20],
        [centerX + 170, centerY - 70],
        [centerX + 150, centerY - 70]
    ], jetHighlightColor)
    
    ; Left angled vertical stabilizer
    d2d.fillPolygon([
        [centerX + 130, centerY - 15],
        [centerX + 160, centerY - 15],
        [centerX + 150, centerY - 50],
        [centerX + 130, centerY - 40]
    ], jetBodyColor)
    
    ; Right angled vertical stabilizer
    d2d.fillPolygon([
        [centerX + 130, centerY + 15],
        [centerX + 160, centerY + 15],
        [centerX + 150, centerY + 50],
        [centerX + 130, centerY + 40]
    ], jetBodyColor)
    
    ; ==================== Draw Engines ====================
    ; Left engine housing
    d2d.fillRoundedRectangle(centerX - 80, centerY + 5, 100, 20, 10, 10, jetEngineColor)
    d2d.drawRoundedRectangle(centerX - 80, centerY + 5, 100, 20, 10, 10, jetMetalColor, 1, 1)
    
    ; Right engine housing
    d2d.fillRoundedRectangle(centerX - 20, centerY + 5, 100, 20, 10, 10, jetEngineColor)
    d2d.drawRoundedRectangle(centerX - 20, centerY + 5, 100, 20, 10, 10, jetMetalColor, 1, 1)
    
    ; Engine intakes
    d2d.fillCircle(centerX - 80, centerY + 15, 10, jetShadowColor)
    d2d.fillCircle(centerX - 20, centerY + 15, 10, jetShadowColor)
    
    ; ==================== Draw Cockpit ====================
    ; Cockpit canopy
    d2d.fillRoundedRectangle(centerX - 120, centerY - 30, 70, 20, 10, 10, jetCockpitColor)
    d2d.drawRoundedRectangle(centerX - 120, centerY - 30, 70, 20, 10, 10, jetMetalColor, 1, 1)
    
    ; Cockpit frame lines
    d2d.drawLine(centerX - 100, centerY - 30, centerX - 100, centerY - 10, jetMetalColor, 1, 1)
    d2d.drawLine(centerX - 80, centerY - 30, centerX - 80, centerY - 10, jetMetalColor, 1, 1)
    
    ; ==================== Draw Weapons ====================
    ; Left wing missile
    d2d.fillRoundedRectangle(centerX - 130, centerY - 60, 30, 8, 4, 4, jetMissileColor)
    d2d.fillPolygon([
        [centerX - 100, centerY - 60],
        [centerX - 100, centerY - 52],
        [centerX - 90, centerY - 56]
    ], jetMissileColor)
    
    ; Right wing missile
    d2d.fillRoundedRectangle(centerX + 100, centerY - 60, 30, 8, 4, 4, jetMissileColor)
    d2d.fillPolygon([
        [centerX + 130, centerY - 60],
        [centerX + 130, centerY - 52],
        [centerX + 140, centerY - 56]
    ], jetMissileColor)
    
    ; ==================== Draw Details ====================
    ; Warning lights
    d2d.fillCircle(centerX - 180, centerY, 3, jetWarningColor)
    d2d.fillCircle(centerX + 190, centerY - 10, 3, jetWarningColor)
    d2d.fillCircle(centerX + 190, centerY + 10, 3, jetWarningColor)
    
    ; Canopy reflection highlight
    d2d.drawLine(centerX - 110, centerY - 28, centerX - 60, centerY - 28, 0x88FFFFFF, 2, 1)
    
    ; Wing edge highlights
    d2d.drawLine(centerX - 120, centerY - 80, centerX - 150, centerY - 80, 0x88FFFFFF, 1, 1)
    d2d.drawLine(centerX + 120, centerY - 80, centerX + 150, centerY - 80, 0x88FFFFFF, 1, 1)
    
    ; Tail edge highlights
    d2d.drawLine(centerX + 170, centerY - 70, centerX + 150, centerY - 70, 0x88FFFFFF, 1, 1)
}

; ==================== Cleanup Function ====================
cleanupResources() {
    global d2d, timerFn
    
    ; Stop the timer
    SetTimer(timerFn, 0)
    
    ; Clean up Direct2D resources
    d2d.cleanup()
}

; ==================== Hotkeys ====================
Hotkey "F10", (*) => Reload()  ; F10 to reload
Hotkey "F12", (*) => ExitApp()  ; F12 to exit

; Ensure cleanup on exit
OnExit((*) => cleanupResources())
