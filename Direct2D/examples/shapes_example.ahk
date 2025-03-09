;==================================================================================================================
; D2D1 Shapes Example
;==================================================================================================================
; Description:    Demonstrates shapes using the D2D1 library.
;                 Showcases basic, complex and compound shapes using direct and object-oriented approaches.
;
; Features:       - Draws basic shapes (rectangles, circles, lines)
;                 - Creates complex shapes (polygons, rounded rectangles)
;                 - Builds compound shapes from multiple shapes
;                 - Uses both direct drawing and shape classes
;                 - Implements a scene graph for shape management
;
; Usage:          Run the script to view shape examples
;
; Hotkeys:        F10 - Reload script
;                 F12 - Exit application
;
; Dependencies:   - D2D1.ahk library
;
; Author:         CasperHarkin
; Version:        1.0
; Last Updated:   09/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

#Include ..\d2d1.ahk

; ==================== Initialization ====================
; Create GUI window
mainGui := Gui("+Resize", "D2D1 Shapes")
mainGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(mainGui.hwnd, 0, 0, 800, 600)

; ==================== Scene Setup ====================
; Create scene for shape classes
scene := D2D1Scene()

; Add shapes to scene
scene.addShape(D2D1Rectangle(450, 50, 100, 80, 0xFF5555))
scene.addShape(D2D1OutlineRectangle(580, 50, 100, 80, 0x0000FF, 2, 1))
scene.addShape(D2D1RoundedRectangle(450, 150, 100, 80, 10, 10, 0x55FF55))
scene.addShape(D2D1OutlineRoundedRectangle(580, 150, 100, 80, 10, 10, 0x00AAAA, 2, 1))
scene.addShape(D2D1Circle(500, 280, 40, 0xFFAA00))
scene.addShape(D2D1OutlineCircle(630, 280, 40, 0xAA00FF, 2, 1))
scene.addShape(D2D1Line(450, 350, 550, 400, 0x000000, 3, 1))
scene.addShape(D2D1Polygon([[580, 350], [680, 350], [630, 400]], 0xFF00FF))
scene.addShape(D2D1OutlinePolygon([[450, 450], [550, 450], [500, 520]], 0x00FF00, 2, 1))

; Create face shape
face := D2D1Scene()
face.addShape(D2D1Circle(630, 480, 40, 0xFFFF00))  ; Head
face.addShape(D2D1Circle(615, 470, 8, 0x000000))   ; Left eye
face.addShape(D2D1Circle(645, 470, 8, 0x000000))   ; Right eye
face.addShape(D2D1Circle(630, 495, 15, 0xFF0000))  ; Mouth

; ==================== Timer Setup ====================
; 60fps refresh rate
SetTimer(Draw.Bind(d2d), 16)

; ==================== Drawing Functions ====================
; Main drawing function
; @param {D2D1} d2d - D2D1 instance
Draw(d2d) {
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background
    d2d.fillRectangle(0, 0, 800, 600, 0xF0F0F0)
    
    ; Draw dividers
    d2d.fillRectangle(400, 0, 2, 600, 0xAAAAAA)
    d2d.fillRectangle(0, 300, 400, 2, 0xAAAAAA)
    
    ; Draw titles
    d2d.drawText("Basic Shapes (Direct Drawing)", 20, 10, 16, 0x000000, "Arial", "w360 aLeft")
    d2d.drawText("Shape Classes (OOP)", 420, 10, 16, 0x000000, "Arial", "w360 aLeft")
    d2d.drawText("Compound Shapes", 20, 310, 16, 0x000000, "Arial", "w360 aLeft")
    
    ; ==================== Basic Shapes (Direct Drawing) ====================
    ; Rectangle
    d2d.fillRectangle(50, 50, 100, 80, 0xFF5555)
    d2d.drawText("fillRectangle", 50, 140, 12, 0x000000, "Arial")
    
    ; Outlined Rectangle
    d2d.drawRectangle(180, 50, 100, 80, 0x0000FF, 2, 1)
    d2d.drawText("drawRectangle", 180, 140, 12, 0x000000, "Arial")
    
    ; Rounded Rectangle
    d2d.fillRoundedRectangle(50, 170, 100, 80, 10, 10, 0x55FF55)
    d2d.drawText("fillRoundedRectangle", 50, 260, 12, 0x000000, "Arial")
    
    ; Outlined Rounded Rectangle
    d2d.drawRoundedRectangle(180, 170, 100, 80, 10, 10, 0x00AAAA, 2, 1)
    d2d.drawText("drawRoundedRectangle", 180, 260, 12, 0x000000, "Arial")
    
    ; ==================== Shape Classes (Object-Oriented) ====================
    ; Draw all shapes in scene
    for shape in scene._shapes {
        shape.draw(d2d)
    }
    
    ; ==================== Compound Shapes ====================
    ; House
    d2d.fillRectangle(50, 350, 150, 100, 0xAA5500)  ; Main house
    d2d.fillPolygon([[25, 350], [125, 280], [225, 350]], 0xAA0000)  ; Roof
    d2d.fillRectangle(90, 400, 70, 50, 0x8888FF)  ; Door
    d2d.fillCircle(150, 425, 5, 0xFFFF00)  ; Doorknob
    d2d.fillRectangle(60, 370, 40, 40, 0x8888FF)  ; Window left
    d2d.fillRectangle(150, 370, 40, 40, 0x8888FF)  ; Window right
    d2d.drawLine(60, 390, 100, 390, 0x000000, 2)  ; Window divider horizontal left
    d2d.drawLine(80, 370, 80, 410, 0x000000, 2)  ; Window divider vertical left
    d2d.drawLine(150, 390, 190, 390, 0x000000, 2)  ; Window divider horizontal right
    d2d.drawLine(170, 370, 170, 410, 0x000000, 2)  ; Window divider vertical right
    
    ; Draw face
    for shape in face._shapes {
        shape.draw(d2d)
    }
    
    ; ==================== Color Gradient ====================
    steps := 20
    width := 300
    stepWidth := width / steps
    
    Loop steps {
        i := A_Index - 1  ; To get values 0 to steps-1
        
        ; Calculate color components
        r := Round(255 * (steps - i) / steps)
        g := Round(255 * i / steps)
        b := Round(128)
        
        ; Create color with opacity
        color := (0xFF << 24) | (r << 16) | (g << 8) | b
        
        ; Draw gradient rectangle
        d2d.fillRectangle(50 + (i * stepWidth), 500, stepWidth, 50, color)
    }
    d2d.drawText("Color Gradient", 50, 560, 12, 0x000000, "Arial")
    
    ; End drawing
    d2d.endDraw()
}

; ==================== Hotkeys ====================
Hotkey "F10", (*) => Reload()  ; F10 to reload
Hotkey "F12", (*) => ExitApp()  ; F12 to exit