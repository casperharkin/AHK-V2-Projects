#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk

/**
 * Shapes example using the D2D1 class
 * This example demonstrates the shape classes and scene graph functionality
 * including the new outline shapes (rectangle, circle, polygon) and rounded rectangles
 * as well as antialiasing control
 */

; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Shapes Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a scene
scene := D2D1Scene()

; Add filled shapes to the scene
scene.addShape(D2D1Rectangle(50, 50, 100, 100, 0xFF0000))
scene.addShape(D2D1Circle(300, 150, 75, 0x00FF00))
scene.addShape(D2D1Line(50, 300, 350, 400, 0x0000FF, 3, 1))
scene.addShape(D2D1Polygon([[500, 100], [600, 200], [550, 300], [450, 250]], 0xFFFF00))

; Add outlined shapes (new features)
scene.addShape(D2D1OutlineRectangle(400, 50, 120, 80, 0xFF8000, 2, 1))
scene.addShape(D2D1OutlinePolygon([[150, 400], [250, 450], [200, 550], [100, 500]], 0xFF00FF, 2, 1))
scene.addShape(D2D1OutlineCircle(600, 450, 50, 0x00FFFF, 3, 1))

; Add rounded rectangle shapes (new features)
scene.addShape(D2D1RoundedRectangle(600, 50, 150, 80, 15, 15, 0x00FF80))
scene.addShape(D2D1OutlineRoundedRectangle(50, 450, 120, 80, 10, 10, 0x8080FF, 2, 1))

; Create a drawing function with bound scene and d2d instance
drawFunc := RenderScene.Bind(scene, d2d)

; Set up drawing timer
SetTimer(drawFunc, 40)

; Animation variables
moveX := 1
moveY := 1
rotation := 0
pulseSize := 0
pulseDirection := 1
roundedRadius := 5
roundedRadiusDirection := 0.2
antialiasEnabled := true

; Hotkeys
Hotkey "F9", (*) => Reload()
Hotkey "Escape", (*) => ExitApp()
; Toggle antialiasing with F5
Hotkey "F5", ToggleAntialias

; Toggle antialiasing function
ToggleAntialias(*) {
    global antialiasEnabled, d2d
    antialiasEnabled := !antialiasEnabled
    d2d.setAntialias(antialiasEnabled)
    ToolTip("Antialiasing: " (antialiasEnabled ? "Enabled" : "Disabled"), 10, 10)
    SetTimer () => ToolTip(), -2000
}

; Drawing function
RenderScene(scene, d2d) {
    global moveX, moveY, rotation, pulseSize, pulseDirection, roundedRadius, roundedRadiusDirection
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background with white
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Animate the first shape (rectangle)
    if (scene._shapes[1]._x < 50 || scene._shapes[1]._x > 650)
        moveX *= -1
    if (scene._shapes[1]._y < 50 || scene._shapes[1]._y > 450)
        moveY *= -1
    
    scene._shapes[1].move(moveX, moveY)
    
    ; Animate the second shape (circle) - change color
    rotation += 1
    if (rotation >= 360)
        rotation := 0
    
    ; Calculate color based on rotation (hue rotation)
    r := Round(127.5 + 127.5 * Cos(rotation * 0.0174533))
    g := Round(127.5 + 127.5 * Cos((rotation + 120) * 0.0174533))
    b := Round(127.5 + 127.5 * Cos((rotation + 240) * 0.0174533))
    
    scene._shapes[2].setColor((r << 16) | (g << 8) | b)
    
    ; Animate the outlined polygon (rotate the points)
    if (Mod(rotation, 5) = 0) {
        outlinePolygon := scene._shapes[6]
        
        ; Calculate center point of the polygon
        centerX := 0, centerY := 0
        for point in outlinePolygon._points {
            centerX += point[1]
            centerY += point[2]
        }
        centerX /= outlinePolygon._points.Length
        centerY /= outlinePolygon._points.Length
        
        ; Rotate points around center
        angle := 0.01  ; Small rotation angle
        cos_val := Cos(angle)
        sin_val := Sin(angle)
        
        for i, point in outlinePolygon._points {
            ; Translate point to origin
            x := point[1] - centerX
            y := point[2] - centerY
            
            ; Rotate point
            newX := x * cos_val - y * sin_val
            newY := x * sin_val + y * cos_val
            
            ; Translate point back
            outlinePolygon._points[i][1] := newX + centerX
            outlinePolygon._points[i][2] := newY + centerY
        }
    }
    
    ; Animate the outlined circle (pulse size)
    outlineCircle := scene._shapes[7]
    
    ; Update pulse size
    pulseSize += 0.2 * pulseDirection
    if (pulseSize > 10 || pulseSize < 0)
        pulseDirection *= -1
        
    outlineCircle._thickness := 1 + pulseSize
    
    ; Animate the rounded rectangle (change corner radius)
    roundedRect := scene._shapes[9]
    
    ; Update corner radius
    roundedRadius += roundedRadiusDirection
    if (roundedRadius > 20 || roundedRadius < 5)
        roundedRadiusDirection *= -1
        
    roundedRect._radiusX := roundedRadius
    roundedRect._radiusY := roundedRadius
    
    ; Draw all shapes in the scene
    for shape in scene._shapes {
        shape.draw(d2d)
    }
    
    ; Display antialiasing status
    d2d.drawText("Press F5 to toggle antialiasing (currently "
                 (antialiasEnabled ? "enabled" : "disabled") ")",
                 10, 10, 14, 0x000000, "Arial", "w300 h30")
    
    ; End drawing
    d2d.endDraw()
}