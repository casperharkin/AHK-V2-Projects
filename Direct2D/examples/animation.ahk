#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk

/**
 * Animation example using the D2D1 class
 * This example creates an animated scene with moving shapes
 */

; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Animation Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Animation variables
angle := 0
radius := 150

; Create a drawing function with bound d2d instance
drawFunc := AnimationFrame.Bind(d2d)

; Set up drawing timer (60 FPS)
SetTimer(drawFunc, 16)

; Hotkeys
Hotkey "F9", (*) => Reload()
Hotkey "Escape", (*) => ExitApp()

; Animation function
AnimationFrame(d2d) {
    ; Update animation variables
    global angle, radius
    angle += 2
    if (angle >= 360)
        angle := 0
    
    ; Calculate position for orbiting circle
    x := 400 + radius * Cos(angle * 0.0174533)
    y := 300 + radius * Sin(angle * 0.0174533)
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background with white
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw a trail of circles with fading opacity
    loop 10 {
        trailAngle := angle - (A_Index * 10)
        trailX := 400 + radius * Cos(trailAngle * 0.0174533)
        trailY := 300 + radius * Sin(trailAngle * 0.0174533)
        trailSize := 50 - (A_Index * 4)
        trailAlpha := 255 - (A_Index * 25)
        trailColor := (trailAlpha << 24) | 0xFF0000  ; Red with fading alpha
        
        d2d.fillCircle(trailX, trailY, trailSize, trailColor)
    }
    
    ; Draw the center point
    d2d.fillCircle(400, 300, 10, 0x000000)
    
    ; Draw the main orbiting circle
    d2d.fillCircle(x, y, 50, 0x0000FF)
    
    ; Draw connecting line
    d2d.drawLine(400, 300, x, y, 0x000000, 2)
    
    ; End drawing
    d2d.endDraw()
}