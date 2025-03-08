#Requires AutoHotkey v2.0
#SingleInstance Force

/**
 * Direct2D Shapes Example
 * 
 * This example demonstrates drawing various shapes using the D2D1 library:
 * - Basic shapes (rectangles, circles, lines)
 * - Complex shapes (polygons, rounded rectangles)
 * - Compound shapes (creating pictures from multiple shapes)
 * - Using both direct drawing methods and shape classes
 * - Using the scene graph to manage multiple shapes
 * 
 * Controls:
 * - F10: Reload the script
 * - F12: Exit the application
 */

; Include the D2D1 library
#Include "..\d2d1.ahk"

; Create GUI window
myGui := Gui("+Resize", "D2D1 Shapes Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance - use 0,0 for x,y position to match the window
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create a scene for the shape classes section
scene := D2D1Scene()

; Add shapes to the scene
scene.addShape(D2D1Rectangle(450, 50, 100, 80, 0xFF5555))
scene.addShape(D2D1OutlineRectangle(580, 50, 100, 80, 0x0000FF, 2, 1))
scene.addShape(D2D1RoundedRectangle(450, 150, 100, 80, 10, 10, 0x55FF55))
scene.addShape(D2D1OutlineRoundedRectangle(580, 150, 100, 80, 10, 10, 0x00AAAA, 2, 1))
scene.addShape(D2D1Circle(500, 280, 40, 0xFFAA00))
scene.addShape(D2D1OutlineCircle(630, 280, 40, 0xAA00FF, 2, 1))
scene.addShape(D2D1Line(450, 350, 550, 400, 0x000000, 3, 1))
scene.addShape(D2D1Polygon([[580, 350], [680, 350], [630, 400]], 0xFF00FF))
scene.addShape(D2D1OutlinePolygon([[450, 450], [550, 450], [500, 520]], 0x00FF00, 2, 1))

; Create a face compound shape
face := D2D1Scene()
face.addShape(D2D1Circle(630, 480, 40, 0xFFFF00))  ; Head
face.addShape(D2D1Circle(615, 470, 8, 0x000000))   ; Left eye
face.addShape(D2D1Circle(645, 470, 8, 0x000000))   ; Right eye
face.addShape(D2D1Circle(630, 495, 15, 0xFF0000))  ; Mouth

; Set up drawing timer
SetTimer(DrawFrame.Bind(d2d), 16)  ; Increased refresh rate to 60fps (16ms)

/**
 * Main drawing function
 * @param {D2D1} d2d - D2D1 instance
 */
DrawFrame(d2d) {
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background with a light gray color
    d2d.fillRectangle(0, 0, 800, 600, 0xF0F0F0)
    
    ; Draw section dividers
    d2d.fillRectangle(400, 0, 2, 600, 0xAAAAAA)
    d2d.fillRectangle(0, 300, 400, 2, 0xAAAAAA)
    
    ; Draw section titles
    d2d.drawText("Basic Shapes (Direct Drawing)", 20, 10, 16, 0x000000, "Arial", "w360 aLeft")
    d2d.drawText("Shape Classes (Object-Oriented)", 420, 10, 16, 0x000000, "Arial", "w360 aLeft")
    d2d.drawText("Compound Shapes", 20, 310, 16, 0x000000, "Arial", "w360 aLeft")
    
    ; ===== Section 1: Basic Shapes (Direct Drawing) =====
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
    
    ; ===== Section 2: Shape Classes (Object-Oriented) =====
    ; Draw all shapes in the scene - FIXED: Don't call scene.draw() which has its own begin/end draw
    for shape in scene._shapes {
        shape.draw(d2d)
    }
    
    ; ===== Section 3: Compound Shapes =====
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
    
    ; Draw the face compound shape - FIXED: Don't call face.draw() which has its own begin/end draw
    for shape in face._shapes {
        shape.draw(d2d)
    }
    
    ; ===== Section 4: Color Gradient =====
    ; Create a color gradient effect
    steps := 20
    width := 300
    stepWidth := width / steps
    
    Loop steps {
        i := A_Index - 1  ; To get values 0 to steps-1
        ; Calculate color components
        r := Round(255 * (steps - i) / steps)
        g := Round(255 * i / steps)
        b := Round(128)
        
        ; Create color with full opacity
        color := (0xFF << 24) | (r << 16) | (g << 8) | b
        
        ; Draw gradient rectangle
        d2d.fillRectangle(50 + (i * stepWidth), 500, stepWidth, 50, color)
    }
    d2d.drawText("Color Gradient", 50, 560, 12, 0x000000, "Arial")
    
    ; End drawing
    d2d.endDraw()
}

; Hotkeys
Hotkey "F10", (*) => Reload()  ; F10 to reload
Hotkey "F12", (*) => ExitApp()  ; F12 to exit