;==================================================================================================================
; Modern Slider GUI with Direct2D
;==================================================================================================================
; Description:    A modern GUI implementation with Direct2D featuring a customizable slider
;                 Demonstrates creating interactive UI components with Direct2D
;
; Features:       - Modern-looking slider with customizable appearance
;                 - Real-time value display via tooltip
;                 - Smooth animations and transitions
;                 - Event-driven architecture
;                 - Responsive layout
;
; Usage:          Run the script to see the slider in action
;                 Click and drag the slider handle to change values
;
; Hotkeys:        Escape - Exit application
;
; Dependencies:   - AutoHotkey v2.0+
;                 - D2D1.ahk library
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
mainGui := Gui("+AlwaysOnTop +Resize", "Modern Slider GUI with Direct2D")
mainGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(mainGui.hwnd, 0, 0, 800, 600)

; Set up close event
mainGui.OnEvent("Close", (*) => ExitApp())

; ==================== Theme Colors ====================
bgColor := 0xFF2D2D30       ; Dark background
accentColor := 0xFF0078D7    ; Blue accent
textColor := 0xFFFFFFFF      ; White text

; ==================== Slider Properties ====================
; Position and dimensions
sliderX := 250
sliderY := 285
sliderWidth := 300
sliderHeight := 30

; Value properties
sliderMin := 0
sliderMax := 100
sliderValue := 50

; Appearance
trackColor := 0xFF555555
trackFillColor := accentColor
handleColor := 0xFFFFFFFF
handleHoverColor := 0xFFE0E0E0
handleRadius := Min(sliderHeight / 2 - 2, 12)
trackHeight := Min(sliderHeight / 3, 6)

; Interaction state
isDragging := false
isHovering := false
lastMouseX := 0
lastMouseY := 0

; ==================== Mouse Input Functions ====================
; Get mouse position relative to the window
GetMousePos(&mouseX, &mouseY) {
    ; Get mouse position
    CoordMode "Mouse", "Screen"
    MouseGetPos &screenX, &screenY
    
    ; Convert to client coordinates
    pt := Buffer(8, 0)
    NumPut("int", screenX, pt, 0)
    NumPut("int", screenY, pt, 4)
    DllCall("ScreenToClient", "Ptr", mainGui.hwnd, "Ptr", pt)
    
    ; Return values
    mouseX := NumGet(pt, 0, "int")
    mouseY := NumGet(pt, 4, "int")
}

; Check if mouse is over the slider
IsMouseOverSlider(mouseX, mouseY) {
    return (mouseX >= sliderX && mouseX <= sliderX + sliderWidth &&
            mouseY >= sliderY && mouseY <= sliderY + sliderHeight)
}

; Update slider value based on mouse position
UpdateSliderValue(mouseX) {
    ; Calculate value based on position
    relativeX := Max(0, Min(sliderWidth, mouseX - sliderX))
    valueRatio := relativeX / sliderWidth
    newValue := sliderMin + valueRatio * (sliderMax - sliderMin)
    
    ; Set the new value
    SetSliderValue(Round(newValue))
}

; Set slider value
SetSliderValue(value) {
    global sliderValue
    
    ; Clamp value to min/max range
    newValue := Max(sliderMin, Min(sliderMax, value))
    
    ; Only update if value has changed
    if (newValue != sliderValue) {
        sliderValue := newValue
        
        ; Show tooltip with current value
        ToolTip("Value: " sliderValue)
        
        ; Hide tooltip after 2 seconds
        SetTimer () => ToolTip(), -2000
    }
}

; ==================== Drawing Functions ====================
; Draw the slider
DrawSlider() {
    global d2d, sliderX, sliderY, sliderWidth, sliderHeight
    global trackColor, trackFillColor, handleColor, handleHoverColor
    global handleRadius, trackHeight, isHovering, sliderValue, sliderMin, sliderMax
    
    ; Calculate track position
    trackY := sliderY + sliderHeight / 2 - trackHeight / 2
    
    ; Calculate handle position based on current value
    valueRatio := (sliderValue - sliderMin) / (sliderMax - sliderMin)
    handleX := sliderX + valueRatio * sliderWidth
    handleY := sliderY + sliderHeight / 2
    
    ; Draw track background
    d2d.fillRoundedRectangle(
        sliderX, 
        trackY, 
        sliderWidth, 
        trackHeight, 
        trackHeight / 2, 
        trackHeight / 2, 
        trackColor
    )
    
    ; Draw filled portion of track
    d2d.fillRoundedRectangle(
        sliderX, 
        trackY, 
        sliderWidth * valueRatio, 
        trackHeight, 
        trackHeight / 2, 
        trackHeight / 2, 
        trackFillColor
    )
    
    ; Draw handle
    currentHandleColor := isHovering ? handleHoverColor : handleColor
    d2d.fillCircle(handleX, handleY, handleRadius, currentHandleColor)
    d2d.drawCircle(handleX, handleY, handleRadius, trackFillColor, 1.5)
}

; Main render loop
RenderLoop() {
    global d2d, bgColor, textColor, sliderValue
    global isDragging, isHovering, lastMouseX, lastMouseY
    
    ; Get current mouse position and state
    mouseX := 0
    mouseY := 0
    GetMousePos(&mouseX, &mouseY)
    
    ; Check if mouse position has changed
    if (mouseX != lastMouseX || mouseY != lastMouseY) {
        ; Update hover state
        isHovering := IsMouseOverSlider(mouseX, mouseY)
        
        ; Update slider if dragging
        if (isDragging) {
            UpdateSliderValue(mouseX)
        }
        
        ; Store current mouse position
        lastMouseX := mouseX
        lastMouseY := mouseY
    }
    
    ; Check for mouse button state
    if (GetKeyState("LButton", "P")) {
        ; Left button is pressed
        if (!isDragging && isHovering) {
            ; Start dragging
            isDragging := true
            UpdateSliderValue(mouseX)
        }
    } else {
        ; Left button is released
        isDragging := false
    }
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background
    d2d.fillRectangle(0, 0, 800, 600, bgColor)
    
    ; Draw title
    d2d.drawText("Modern Slider GUI", 20, 20, 24, textColor, "Segoe UI", "w760")
    
    ; Draw slider label
    d2d.drawText("Drag the slider to change value:", 20, 235, 18, textColor, "Segoe UI", "w760")
    
    ; Draw slider
    DrawSlider()
    
    ; Draw current value text
    valueText := "Current Value: " sliderValue
    d2d.drawText(valueText, 20, 335, 18, textColor, "Segoe UI", "w760")
    
    ; Draw instructions
    d2d.drawText("Press ESC to exit", 20, 560, 14, 0xFFAAAAAA, "Segoe UI", "w760")
    
    ; End drawing
    d2d.endDraw()
}

; ==================== Window Resize Handler ====================
; Handle window resize
mainGui.OnEvent("Size", OnResize)

OnResize(thisGui, MinMax, wSize, hSize) {
    global sliderX, sliderY
    
    if (MinMax = -1) ; Window is minimized
        return
        
    ; Update slider position to center it
    sliderX := wSize / 2 - 150
    sliderY := hSize / 2 - 15
}

; ==================== Cleanup Function ====================
cleanupResources() {
    global d2d, timerFn
    
    ; Stop the timer
    SetTimer timerFn, 0
    
    ; Clean up Direct2D resources
    d2d.cleanup()
}

; ==================== Hotkeys ====================
Hotkey "Escape", (*) => ExitApp()  ; Escape to exit

; Ensure cleanup on exit
OnExit((*) => cleanupResources())

; ==================== Start Rendering ====================
; Set up drawing timer (60 FPS target)
timerFn := RenderLoop
SetTimer timerFn, 16