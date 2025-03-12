#Requires AutoHotkey v2.0
#SingleInstance Force

/**
 * Direct2D Text Example
 *
 * This example demonstrates various text rendering capabilities of the D2D1 library:
 * - Basic text rendering with different fonts and sizes
 * - Text alignment (left, center, right)
 * - Text effects (drop shadows, outlines)
 * - Text animation (moving, fading, scaling)
 *
 * Controls:
 * - F9: Reload the script
 * - Escape: Exit the application
 */

; Include the D2D1 library
#Include "..\d2d1.ahk"  ; This is the correct relative path when run from the examples directory

; Create GUI window
myGui := Gui("+AlwaysOnTop +Resize", "D2D1 Text Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Animation variables
textPos := 0
textAlpha := 0
textScale := 1.0
fadeDirection := 1
scaleDirection := 1

; Set up drawing timer (25 FPS)
SetTimer(DrawFrame.Bind(d2d), 40)

/**
 * Main drawing function
 * @param {D2D1} d2d - D2D1 instance
 */
DrawFrame(d2d) {
    global textPos, textAlpha, textScale
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background with a light gray color
    d2d.fillRectangle(0, 0, 800, 600, 0xF0F0F0)
    
    ; Draw section dividers
    d2d.fillRectangle(0, 150, 800, 2, 0xAAAAAA)
    d2d.fillRectangle(0, 300, 800, 2, 0xAAAAAA)
    d2d.fillRectangle(0, 450, 800, 2, 0xAAAAAA)
    
    ; Draw section titles
    d2d.drawText("Basic Text Rendering", 20, 10, 18, 0x000000, "Arial", "w760 aLeft")
    d2d.drawText("Text Alignment", 20, 160, 18, 0x000000, "Arial", "w760 aLeft")
    d2d.drawText("Text Effects", 20, 310, 18, 0x000000, "Arial", "w760 aLeft")
    d2d.drawText("Animated Text", 20, 460, 18, 0x000000, "Arial", "w760 aLeft")
    
    ; ===== Section 1: Basic Text Rendering =====
    ; Different fonts
    d2d.drawText("Arial Font", 50, 40, 16, 0x000000, "Arial")
    d2d.drawText("Times New Roman Font", 50, 70, 16, 0x000000, "Times New Roman")
    d2d.drawText("Courier New Font", 50, 100, 16, 0x000000, "Courier New")
    
    ; Different sizes
    d2d.drawText("Size 12", 350, 40, 12, 0x000000, "Arial")
    d2d.drawText("Size 18", 350, 70, 18, 0x000000, "Arial")
    d2d.drawText("Size 24", 350, 100, 24, 0x000000, "Arial")
    
    ; Different colors
    d2d.drawText("Red Text", 600, 40, 16, 0xFF0000, "Arial")
    d2d.drawText("Green Text", 600, 70, 16, 0x00FF00, "Arial")
    d2d.drawText("Blue Text", 600, 100, 16, 0x0000FF, "Arial")
    
    ; ===== Section 2: Text Alignment =====
    ; Left-aligned text
    d2d.drawText("This text is left-aligned", 400, 190, 16, 0x000000, "Arial", "w400 aLeft")
    
    ; Center-aligned text
    d2d.drawText("This text is center-aligned", 400, 220, 16, 0x000000, "Arial", "w400 aCenter")
    
    ; Right-aligned text
    d2d.drawText("This text is right-aligned", 400, 250, 16, 0x000000, "Arial", "w400 aRight")
    
    ; ===== Section 3: Text Effects =====
    ; Using D2D1Text class for effects
    
    ; Text with drop shadow
    d2d.drawText("Text with drop shadow", 50, 340, 18, 0x000000, "Arial", "ds808080 dsx3 dsy3")
    
    ; Text with outline
    d2d.drawText("Text with outline", 50, 380, 18, 0xFF0000, "Arial", "ol000000")
    
    ; Text with both effects
    d2d.drawText("Text with both effects", 50, 420, 18, 0x0000FF, "Arial", "ol000000 ds808080 dsx2 dsy2")
    
    ; Using D2D1Text class
    textObj := D2D1Text("Using D2D1Text Class", 400, 380, 350, 50, 0x008000, "Arial", "center")
    textObj.setFontSize(18)  ; Set font size explicitly
    textObj.addDropShadow(0x80000000, 2, 2)
    textObj.draw(d2d)
    
    ; ===== Section 4: Animated Text =====
    ; Update animation variables
    UpdateAnimationVariables()
    
    ; Moving text
    d2d.drawText("Moving Text →", 50 + textPos, 500, 18, 0x000000, "Arial")
    
    ; Fading text
    fadeColor := (Round(textAlpha) << 24) | 0x000000  ; Apply alpha to black color
    d2d.drawText("Fading Text", 300, 500, 18, fadeColor, "Arial")
    
    ; Scaling text
    d2d.drawText("Scaling Text", 500, 500, 18 * textScale, 0x000000, "Arial")
    
    ; End drawing
    d2d.endDraw()
}

/**
 * Update animation variables
 */
UpdateAnimationVariables() {
    global textPos, textAlpha, textScale, fadeDirection, scaleDirection
    
    ; Moving text animation
    textPos := Mod(textPos + 2, 200)  ; Move 2 pixels per frame, loop at 200
    
    ; Fading text animation
    textAlpha += 5 * fadeDirection
    if (textAlpha >= 255) {
        textAlpha := 255
        fadeDirection := -1
    } else if (textAlpha <= 0) {
        textAlpha := 0
        fadeDirection := 1
    }
    
    ; Scaling text animation
    textScale += 0.02 * scaleDirection
    if (textScale >= 1.5) {
        textScale := 1.5
        scaleDirection := -1
    } else if (textScale <= 0.8) {
        textScale := 0.8
        scaleDirection := 1
    }
}
