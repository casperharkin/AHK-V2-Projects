#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk

/**
 * Text example using the D2D1 class
 * This example demonstrates the text rendering capabilities
 */

; Create GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Text Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a scene
scene := D2D1Scene()

; Add text elements to the scene
scene.addShape(D2D1Rectangle(0, 0, 800, 600, 0xFFFFFF))  ; White background

; Title with center alignment
titleText := D2D1Text("Direct2D Text Rendering", 50, 50, 700, 50, 0x0000FF, "Arial", "center")
titleText.setFontSize(24)
scene.addShape(titleText)

; Body text with default left alignment
bodyText1 := D2D1Text("This example demonstrates text rendering capabilities in the D2D1 library.", 
                     50, 120, 700, 50, 0x000000, "Segoe UI")
bodyText1.setFontSize(16)
scene.addShape(bodyText1)

bodyText2 := D2D1Text("Different fonts, sizes, and styles can be used:", 
                     50, 180, 700, 30, 0x000000, "Segoe UI")
bodyText2.setFontSize(16)
scene.addShape(bodyText2)

; Add examples of different text alignments
scene.addShape(D2D1Rectangle(50, 220, 700, 100, 0xF0F0F0))

leftText := D2D1Text("Left aligned text", 50, 220, 700, 30, 0x000000, "Segoe UI", "left")
leftText.setFontSize(16)
scene.addShape(leftText)

centerText := D2D1Text("Center aligned text", 50, 250, 700, 30, 0x000000, "Segoe UI", "center")
centerText.setFontSize(16)
scene.addShape(centerText)

rightText := D2D1Text("Right aligned text", 50, 280, 700, 30, 0x000000, "Segoe UI", "right")
rightText.setFontSize(16)
scene.addShape(rightText)

; Add code example
scene.addShape(D2D1Rectangle(50, 340, 700, 120, 0xF0F0F0))

codeText1 := D2D1Text("// Example code for text rendering", 60, 350, 680, 20, 0x800000, "Consolas")
codeText1.setFontSize(12)
scene.addShape(codeText1)

codeText2 := D2D1Text('d2d.drawText("Hello, World!", 50, 50, 18, 0x000000, "Arial")', 
                     60, 370, 680, 20, 0x800000, "Consolas")
codeText2.setFontSize(12)
scene.addShape(codeText2)

codeText3 := D2D1Text('text.addDropShadow(0x80000000, 2, 2)  // Add drop shadow', 
                     60, 390, 680, 20, 0x800000, "Consolas")
codeText3.setFontSize(12)
scene.addShape(codeText3)

codeText4 := D2D1Text('text.addOutline(0xFF000000)  // Add outline', 
                     60, 410, 680, 20, 0x800000, "Consolas")
codeText4.setFontSize(12)
scene.addShape(codeText4)

; Add text with special effects
scene.addShape(D2D1Rectangle(50, 460, 700, 120, 0xF0F0F0))

; Text with drop shadow
shadowText := D2D1Text("Text with drop shadow", 60, 470, 680, 30, 0x0000FF, "Arial", "left")
shadowText.setFontSize(18)
shadowText.addDropShadow(0x80000000, 2, 2)
scene.addShape(shadowText)

; Text with outline
outlineText := D2D1Text("Text with outline", 60, 510, 680, 30, 0xFF0000, "Arial", "left")
outlineText.setFontSize(18)
outlineText.addOutline(0xFF000000)
scene.addShape(outlineText)

; Animated text with color change
animatedText := D2D1Text("Text can be animated and updated dynamically!", 
                        50, 550, 700, 30, 0xFF0000, "Segoe UI", "center")
animatedText.setFontSize(16)
scene.addShape(animatedText)

; Create a drawing function with bound scene and d2d instance
drawFunc := RenderTextScene.Bind(scene, d2d)

; Set up drawing timer
SetTimer(drawFunc, 40)

; Animation variables
animationPhase := 0

; Hotkeys
Hotkey "F9", (*) => Reload()
Hotkey "Escape", (*) => ExitApp()


; Drawing function
RenderTextScene(scene, d2d) {
    global animationPhase
    
    ; Update animation
    animationPhase += 0.05
    if (animationPhase >= 2 * 3.14159)
        animationPhase := 0
    
    ; Calculate color based on animation phase
    r := Round(127.5 + 127.5 * Cos(animationPhase))
    g := Round(127.5 + 127.5 * Cos(animationPhase + 2))
    b := Round(127.5 + 127.5 * Cos(animationPhase + 4))
    color := (r << 16) | (g << 8) | b
    
    ; Update the animated text color (last shape in the scene)
    scene._shapes[scene._shapes.Length].setColor(color)
    
    ; Draw all shapes in the scene
    scene.draw(d2d)
}