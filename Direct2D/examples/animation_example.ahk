;==================================================================================================================
; D2D1 Animation Example
;==================================================================================================================
; Description:    Demonstrates animated graphics using Direct2D in AutoHotkey v2
;                 Creates an orbiting circle with trailing effect and connecting line
;
; Features:       - Smooth circular animation with fading trail
;                 - Responsive to window resizing
;                 - Configurable animation speed and colors
;                 - Efficient 60 FPS rendering
;
; Usage:          Run the script to see the animation demonstration
;
; Hotkeys:        F9 - Reload script
;                 Escape - Exit application
;                 Up/Down - Increase/decrease animation speed
;                 +/- - Increase/decrease orbit radius
;
; Dependencies:   - AutoHotkey v2.0
;                 - D2D1.ahk library
;
; Author:         AHK User
; Version:        1.2
; Last Updated:   09/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk  

; ==================== Class Definition ====================
class AnimationApp {
    ; Properties to replace global variables
    width := 800
    height := 600
    angle := 0
    radius := 150
    speed := 2
    d2d := ""  ; Will be initialized in the constructor
    myGui := ""  ; Reference to the GUI
    
    ; Constructor
    __New() {
        ; Create GUI window
        this.myGui := Gui("+AlwaysOnTop +Resize", "D2D1 Animation Example")
        this.myGui.OnEvent("Size", ObjBindMethod(this, "OnResize"))
        this.myGui.OnEvent("Close", ObjBindMethod(this, "OnExit"))
        this.myGui.Show("w" this.width " h" this.height)
        
        ; Initialize D2D1 instance
        this.d2d := D2D1(this.myGui.hwnd, 0, 0, this.width, this.height)
        
        ; Set up hotkeys
        this.ConfigureHotkeys()
        
        ; Set up drawing timer (60 FPS) using bound method
        SetTimer(ObjBindMethod(this, "AnimationFrame"), 16)
    }
    
    ; ==================== Event Setup ====================
    ; Configure hotkeys using bound methods
    ConfigureHotkeys() {
        Hotkey "F9", ObjBindMethod(this, "ReloadScript")
        Hotkey "Escape", ObjBindMethod(this, "ExitScript")
        Hotkey "Up", ObjBindMethod(this, "IncreaseSpeed")
        Hotkey "Down", ObjBindMethod(this, "DecreaseSpeed")
        Hotkey "+", ObjBindMethod(this, "IncreaseRadius")
        Hotkey "-", ObjBindMethod(this, "DecreaseRadius")
    }
    
    ; ==================== Core Functions ====================
    ; Hotkey methods
    ReloadScript(*) {
        Reload()
    }
    
    ExitScript(*) {
        ExitApp()
    }
    
    IncreaseSpeed(*) {
        this.speed += 0.5
        this.speed := Min(this.speed, 10)
    }
    
    DecreaseSpeed(*) {
        this.speed -= 0.5
        this.speed := Max(this.speed, 0.5)
    }
    
    IncreaseRadius(*) {
        this.radius += 10
        this.radius := Min(this.radius, 300)
    }
    
    DecreaseRadius(*) {
        this.radius -= 10
        this.radius := Max(this.radius, 50)
    }
    
    ; Window resize handler
    OnResize(thisGui, MinMax, wSize, hSize) {
        if (MinMax = -1) ; Window is minimized
            return
        
        ; Update dimensions
        this.width := wSize
        this.height := hSize
        
        ; Only proceed if d2d is properly initialized
        if (this.d2d = "" || !IsObject(this.d2d) || !this.d2d.HasProp("_renderTarget") || !this.d2d.HasProp("_nrSize"))
            return
        
        ; Create a buffer for the new size
        newSize := Buffer(16, 0)
        NumPut("uint", this.width, newSize, 0)
        NumPut("uint", this.height, newSize, 4)
        
        ; Update D2D1 dimensions using the internal resize method
        DllCall(this.d2d._nrSize, "Ptr", this.d2d._renderTarget, "ptr", newSize)
    }
    
    ; Cleanup on exit
    OnExit(*) {
        ; Stop the animation timer
        SetTimer(ObjBindMethod(this, "AnimationFrame"), 0)
        ExitApp()
    }
    
    ; ==================== Animation Function ====================
    AnimationFrame(*) {
        ; Calculate center point
        centerX := this.width / 2
        centerY := this.height / 2
        
        ; Update animation variables
        this.angle += this.speed
        if (this.angle >= 360)
            this.angle := 0
        
        ; Calculate position for orbiting circle
        x := centerX + this.radius * Cos(this.angle * 0.0174533)
        y := centerY + this.radius * Sin(this.angle * 0.0174533)
        
        ; Begin drawing
        this.d2d.beginDraw()
        
        ; Clear background with white
        this.d2d.fillRectangle(0, 0, this.width, this.height, 0xFFFFFF)
        
        ; Draw a trail of circles with fading opacity
        loop 10 {
            trailAngle := this.angle - (A_Index * 10)
            trailX := centerX + this.radius * Cos(trailAngle * 0.0174533)
            trailY := centerY + this.radius * Sin(trailAngle * 0.0174533)
            trailSize := 50 - (A_Index * 4)
            trailAlpha := 255 - (A_Index * 25)
            trailColor := (trailAlpha << 24) | 0xFF0000  ; Red with fading alpha
            
            this.d2d.fillCircle(trailX, trailY, trailSize, trailColor)
        }
        
        ; Draw the center point
        this.d2d.fillCircle(centerX, centerY, 10, 0x000000)
        
        ; Draw the main orbiting circle
        this.d2d.fillCircle(x, y, 50, 0x0000FF)
        
        ; Draw connecting line
        this.d2d.drawLine(centerX, centerY, x, y, 0x000000, 2)
        
        ; Draw speed and radius information
        this.d2d.drawText("Speed: " . this.speed . "`nRadius: " . this.radius, 10, 10, 18, 0x000000, "Arial", "w200 h60")
        
        ; End drawing
        this.d2d.endDraw()
    }
}

; ==================== Application Initialization ====================
; Create an instance of the animation application
app := AnimationApp()
