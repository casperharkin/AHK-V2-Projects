#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk

/**
 * Shapes example using the D2D1 class
 * This example demonstrates the shape classes and scene graph functionality
 */

; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Shapes Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a scene
scene := D2D1Scene()

; Add shapes to the scene
scene.addShape(D2D1Rectangle(50, 50, 100, 100, 0xFF0000))
scene.addShape(D2D1Circle(300, 150, 75, 0x00FF00))
scene.addShape(D2D1Line(50, 300, 350, 400, 0x0000FF, 3, 1))
scene.addShape(D2D1Polygon([[500, 100], [600, 200], [550, 300], [450, 250]], 0xFFFF00))

; Create a drawing function with bound scene and d2d instance
drawFunc := RenderScene.Bind(scene, d2d)

; Set up drawing timer
SetTimer(drawFunc, 40)

; Animation variables
moveX := 1
moveY := 1
rotation := 0

; Hotkeys
Hotkey "F9", (*) => Reload()
Hotkey "Escape", (*) => ExitApp()

; Drawing function
RenderScene(scene, d2d) {
    global moveX, moveY, rotation
    
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
    
    ; Draw all shapes in the scene
    for shape in scene._shapes {
        shape.draw(d2d)
    }
    
    ; End drawing
    d2d.endDraw()
}