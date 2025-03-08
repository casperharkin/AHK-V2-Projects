#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk

/**
 * Basic example of using the D2D1 class
 * This example creates a window with various shapes drawn on it
 */

; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Basic Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a drawing function with bound d2d instance
drawFunc := RenderFrame.Bind(d2d)

; Set up drawing timer
SetTimer(drawFunc, 40)

; Hotkeys
Hotkey "F9", (*) => Reload()
Hotkey "Escape", (*) => ExitApp()

; Drawing function defined separately to avoid conflicts
RenderFrame(d2d) {
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background with white
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw a yellow rectangle
    d2d.fillRectangle(30, 30, 100, 100, 0xFFFF1D)
    
    ; Draw a red circle
    d2d.fillCircle(600, 300, 150, 0xCD1C1C)
    
    ; Draw a black line
    d2d.drawLine(150, 150, 600, 600, 0x000000, 5)
    
    ; Draw a blue triangle (polygon)
    d2d.fillPolygon([[250, 150], [150, 350], [350, 350]], 0x2516FF)
    
    ; End drawing
    d2d.endDraw()
}