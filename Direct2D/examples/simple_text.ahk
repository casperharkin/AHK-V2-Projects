#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk

/**
 * Simple text example using the D2D1 class
 * This example demonstrates basic text rendering
 */

; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Simple Text Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Set up drawing timer
SetTimer(DrawSimpleText.Bind(d2d), 40)

; Hotkeys
Hotkey "F9", (*) => Reload()
Hotkey "Escape", (*) => ExitApp()

; Drawing function
DrawSimpleText(d2d) {
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw text
    d2d.drawText("Hello, World!", 50, 50, 24, 0x000000, "Arial")
    d2d.drawText("This is a simple text example", 50, 100, 18, 0x0000FF, "Arial")
    d2d.drawText("Text with center alignment", 50, 150, 18, 0x00FF00, "Arial", "w700 aCenter")
    d2d.drawText("Text with right alignment", 50, 200, 18, 0xFF0000, "Arial", "w700 aRight")
    
    ; Text with drop shadow
    d2d.drawText("Text with drop shadow", 50, 250, 24, 0x000000, "Arial", "ds808080 dsx2 dsy2")
    
    ; Text with outline
    d2d.drawText("Text with outline", 50, 300, 24, 0xFF0000, "Arial", "olFF0000")
    
    ; End drawing
    d2d.endDraw()
}