#Requires AutoHotkey v2.0
#SingleInstance Force
; Script:    WindowHole.ahk
; Author:    Casper Harkin
; Date:      08/03/2025
; Version:   2.0

/*
  Inspired by Helgef's v1 WinHole script, this AHK v2 implementation creates 
  a movable and resizable "window hole" overlay, allowing visibility through 
  a specified area of the screen. Users can customize the shape, size, and 
  behavior of the overlay to enhance multitasking or focus.
  Helgef's v1 Post - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=30622

  Features:
  - Adjustable hole radius and position
  - Hotkeys for toggling, freezing, resizing
  - Interaction with underlying windows (e.g., sending to the back)

  Hotkeys:
  - F1: Toggle overlay on/off
  - F2: Freeze/unfreeze overlay position
  - F3: Cycle through available shapes
  - ^WheelUp/^WheelDown: Increase/decrease overlay radius
  - ^LButton: Send window under overlay/mouse to the back of the Z-order
  - ^RButton: Open GUI for adjusting settings.  

  Usage:
  Run the script and use the hotkeys to control the overlay's behavior.
*/

WindowHole()

class WindowHole {
    ; Class properties
    Toggle := 0                  ; Overlay toggle state (on/off)
    ShapeType := "Circle"        ; Default shape
    RegionIndex := 1             ; Default shape index (1: Circle, 2: Rectangle, 3: RoundedRectangle)
    Shapes := ["Circle", "Rectangle", "RoundedRectangle"] ; Available Shapes
    Radius := 200                ; Default overlay radius
    StepSize := 25               ; Step size for resizing radius
    TimerFn := ""                ; Timer function reference
    WindowHandle := ""           ; Handle to the overlayed window
    AlwaysOnTop := ""            ; Overlay "Always on Top" state
    Rate := 40                   ; Timer refresh rate (ms)
    IsRunning := false           ; Tracks timer activity state
    IsPaused := false            ; Tracks timer pause state
    Adjustment := {x: 0, y: 0}   ; Tracks mouse adjustment for overlay

    ; Hotkey definitions
    static Keys := {
        Activate: 'F1',                 ; Toggle overlay on/off
        Freeze: 'F2',                   ; Freeze/unfreeze overlay position
        ToggleShape: 'F3',              ; Toggle shape
        AdjustRadiusUp: '^WheelUp',     ; Increase overlay radius
        AdjustRadiusDown: '^WheelDown', ; Decrease overlay radius
        SendWindowToBottom: '^LButton', ; Send the window under overlay to back
        SettingsGUI: '^RButton'         ; Open GUI for adjusting settings
    }

    ; Constructor initializes properties and sets up hotkeys
    __New() {
        ; Set up environment
        SetWinDelay(-1)                  ; Optimizes window handling
        CoordMode("Mouse", "Screen")     ; Set mouse coordinates to screen
        
        ; Set up hotkeys
        Hotkey(WindowHole.Keys.Activate, this.ToggleTimer.Bind(this))
        Hotkey(WindowHole.Keys.Freeze, this.PauseTimer.Bind(this))
        Hotkey(WindowHole.Keys.AdjustRadiusUp, this.AdjustRadiusUp.Bind(this))
        Hotkey(WindowHole.Keys.AdjustRadiusDown, this.AdjustRadiusDown.Bind(this))
        Hotkey(WindowHole.Keys.SendWindowToBottom, this.SendWindowToBottom.Bind(this))
        Hotkey(WindowHole.Keys.ToggleShape, this.ToggleShape.Bind(this))
        Hotkey(WindowHole.Keys.SettingsGUI, this.OpenSettingsGUI.Bind(this))
    }

    ; Reset all settings to default values
    ResetSettings() {
        this.Toggle := 0                  
        this.ShapeType := "Circle"        
        this.RegionIndex := 1             
        this.Radius := 200               
        this.StepSize := 25            
        this.Rate := 40                
        this.Adjustment := {x: 0, y: 0}   
        this.TimerFunction(this.WindowHandle, reset := 1)
        this.RestartTimer()
    }

    ; Toggle timer on/off
    ToggleTimer(*) {
        return this.IsRunning ? this.StopTimer() : this.StartTimer()
    }

    ; Increase radius
    AdjustRadiusUp(*) {
        this.AdjustRadius(1)
    }

    ; Decrease radius
    AdjustRadiusDown(*) {
        this.AdjustRadius(-1)
    }

    ; Open settings GUI
    OpenSettingsGUI(*) {
        SettingsGUI(this)
    }

    ; Adjust the radius of the overlay
    AdjustRadius(direction) {
        if (this.IsRunning || this.IsPaused) {
            this.Radius := Max(1, this.Radius + direction * this.StepSize)
            this.TimerFunction(this.WindowHandle, reset := -1) ; Restart to apply new radius
            return
        } 
        Send(direction = 1 ? "{WheelUp}" : "{WheelDown}") 
    }

    ; Send the window under the mouse to the bottom of the Z-order
    SendWindowToBottom(*) {
        if (!this.IsRunning)
            return
            
        MouseGetPos(&x, &y)
        hWnd := DllCall("User32.dll\WindowFromPoint", "Int64", (x & 0xFFFFFFFF) | (y << 32), "Ptr")
        hRoot := DllCall("User32.dll\GetAncestor", "Ptr", hWnd, "UInt", 2, "Ptr")

        if !hRoot
            return

        rect := Buffer(16)
        if !DllCall("GetWindowRect", "Ptr", hRoot, "Ptr", rect)
            return
    
        ; Preserve the window's position and size for SetWindowPos
        xPos := NumGet(rect, 0, "Int")
        yPos := NumGet(rect, 4, "Int")
        width := NumGet(rect, 8, "Int") - xPos
        height := NumGet(rect, 12, "Int") - yPos
        
        ; HWND_BOTTOM := 1, SWP_NOSIZE := 0x0001
        DllCall("User32.dll\SetWindowPos", "Ptr", hRoot, "UInt", 1, "Int", xPos, "Int", yPos,
                "Int", width, "Int", height, "UInt", 0x0001)
    }

    ; Toggle between available shapes
    ToggleShape(*) {
        for each, shape in this.Shapes {
            if (shape = this.ShapeType) {
                this.RegionIndex := (this.RegionIndex >= this.Shapes.Length) ? 1 : this.RegionIndex + 1
                this.ShapeType := this.Shapes[this.RegionIndex]
                this.TimerFunction(this.WindowHandle, reset := -1, this.Adjustment)
                break
            }
        }
    }

    ; Create a shape region based on type and parameters
    MakeShape(type, params := {}, xOffset := 0, yOffset := 0) {
        switch type {
            case "Circle":
                left := xOffset - params.radius
                top := yOffset - params.radius
                right := xOffset + params.radius
                bottom := yOffset + params.radius
                return DllCall("CreateEllipticRgn", "int", left, "int", top, "int", right, "int", bottom, "ptr")

            case "Rectangle":
                left := xOffset - params.width / 2
                top := yOffset - params.height / 2
                right := xOffset + params.width / 2
                bottom := yOffset + params.height / 2
                return DllCall("CreateRectRgn", "int", left, "int", top, "int", right, "int", bottom, "ptr")

            case "RoundedRectangle":
                left := xOffset - params.width / 2
                top := yOffset - params.height / 2
                right := xOffset + params.width / 2
                bottom := yOffset + params.height / 2
                return DllCall("CreateRoundRectRgn", "int", left, "int", top, "int", right, "int", bottom,
                    "int", params.roundWidth, "int", params.roundHeight, "ptr")
            
            default:
                left := xOffset - params.radius
                top := yOffset - params.radius
                right := xOffset + params.radius
                bottom := yOffset + params.radius
                return DllCall("CreateEllipticRgn", "int", left, "int", top, "int", right, "int", bottom, "ptr")
        }
    }

    ; Create an inverted shape (window with a hole)
    MakeInvertedShape(windowHandle, type, params := {}, xOffset := 0, yOffset := 0) {
        rect := Buffer(16, 0) ; RECT structure: left, top, right, bottom
        DllCall("GetClientRect", "ptr", windowHandle, "ptr", rect)
        winWidth := NumGet(rect, 8, "int")  ; right - left
        winHeight := NumGet(rect, 12, "int") ; bottom - top
        
        ; Create a rectangular region covering the entire window
        hRectRegion := DllCall("CreateRectRgn", "int", 0, "int", 0, "int", winWidth, "int", winHeight, "ptr")
        
        ; Create the specific shape region
        hShapeRegion := this.MakeShape(type, params, xOffset, yOffset)
        
        ; Subtract the shape region from the rectangular region (RGN_DIFF := 4)
        DllCall("CombineRgn", "ptr", hRectRegion, "ptr", hRectRegion, "ptr", hShapeRegion, "int", 4)
        
        ; Clean up the shape region
        DllCall("DeleteObject", "ptr", hShapeRegion)
        
        return hRectRegion 
    }

    ; Timer function that updates the window region
    TimerFunction(windowHandle, reset := 0, adjust := {x: 0, y: 0}) {
        static px := "", py := ""

        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " this.WindowHandle)
        MouseGetPos(&x, &y)

        ; Check if the mouse is outside the window
        if (x < wx || x > wx + ww || y < wy || y > wy + wh) {
           this.RestartTimer()
           return
        }

        if (reset = -1) {
            params := this.GetShapeParams()
            this.Adjustment.x := adjust.x
            this.Adjustment.y := adjust.y
            hRegion := this.MakeInvertedShape(windowHandle, this.ShapeType, params, 
                       adjust.x + px - wx, adjust.y + py - wy)
            DllCall("SetWindowRgn", "ptr", windowHandle, "ptr", hRegion, "int", True)
            return
        }

        if (x != px || y != py || reset) {
            px := x
            py := y
            adjustment := {x: 0, y: 0}
            params := this.GetShapeParams()
            hRegion := this.MakeInvertedShape(windowHandle, this.ShapeType, params, (x - wx), (y - wy))
            DllCall("SetWindowRgn", "ptr", windowHandle, "ptr", hRegion, "int", True)
        }
    }

    ; Get parameters for the current shape
    GetShapeParams() {
        switch this.ShapeType {
            case "Circle":
                return {radius: this.Radius}
            case "Rectangle":
                return {width: this.Radius * 2, height: this.Radius * 2}
            case "RoundedRectangle":
                return {width: this.Radius * 4, height: this.Radius * 2, roundWidth: 30, roundHeight: 30}
        }
    }

    ; Starts the timer and initializes overlay
    StartTimer() { 
        if (this.IsPaused)
            return this.StopTimer()

        if (!this.WindowHandle)
            this.InitializeWindow()

        this.TimerFn := this.TimerFunction.Bind(this, this.WindowHandle)
        this.TimerFn.Call() ; Trigger initial region setup
        SetTimer(this.TimerFn, this.Rate)
        this.IsRunning := true
    }

    ; Stops the timer and resets the overlay
    StopTimer() {
        if (this.TimerFn) {
            SetTimer(this.TimerFn, 0)
        }
        this.ResetWindow()
        this.TimerFn := ""
        this.WindowHandle := ""
        this.AlwaysOnTop := ""
        this.IsRunning := false
        this.IsPaused := false
    }

    ; Pauses the timer without resetting
    PauseTimer(*) {
        if (this.TimerFn) {
            SetTimer(this.TimerFn, 0)
            this.IsRunning := false
            this.IsPaused := true
        }
    }

    ; Restarts the timer to reapply settings
    RestartTimer() {
        this.StopTimer()
        this.StartTimer()
    }

    ; Prepares the window for overlay
    InitializeWindow() {
        MouseGetPos(, , &windowHandle)
        this.WindowHandle := windowHandle
        this.AlwaysOnTop := WinGetExStyle("ahk_id " this.WindowHandle) & 0x8
        if (!this.AlwaysOnTop) {
            WinSetAlwaysOnTop(1, "ahk_id " this.WindowHandle)
        }
    }

    ; Resets the window state when overlay is disabled
    ResetWindow() {
        if (this.WindowHandle) {
            WinSetRegion(, "ahk_id " this.WindowHandle) ; Remove custom region
            if (!this.AlwaysOnTop) {
                WinSetAlwaysOnTop(0, "ahk_id " this.WindowHandle) ; Restore "Always on Top" state
            }
        }
    }
}

class SettingsGUI {
    GUI := ""

    __New(wh) {
        if (wh.IsRunning || wh.IsPaused) {
            wh.PauseTimer()
            this.CreateGUI(wh)
            this.Show()
        }
    }

    CreateGUI(wh) {
        this.GUI := Gui()
        this.GUI.Opt("+AlwaysOnTop")
        this.GUI.OnEvent("Close", (*) => this.Close())
        this.GUI.OnEvent("Escape", (*) => this.Close())
        
        this.GUI.Add("Text", "c", "Settings")
        this.GUI.Add("Button", "w100", "Reset Settings").OnEvent("Click", (*) => this.ResetSettings(wh))
        
        this.GUI.Add("Text", "c", "Radius")
        this.GUI.Add("Slider", "w100 AltSubmit vRadius Range1-1000", wh.Radius)
            .OnEvent("Change", (*) => this.ApplySettings(wh))
        
        this.GUI.Add("Text", "c", "Move along the X-axis")
        this.GUI.Add("Slider", "w100 AltSubmit vx Range-5000-5000", 0)
            .OnEvent("Change", (*) => this.ApplySettings(wh))
        
        this.GUI.Add("Text", "c", "Move along Y-axis")
        this.GUI.Add("Slider", "w100 AltSubmit vy Range-5000-5000", 0)
            .OnEvent("Change", (*) => this.ApplySettings(wh))
        
        this.GUI.Add("Button", "w100", "Change Shape")
            .OnEvent("Click", (*) => wh.ToggleShape())
    }

    ApplySettings(wh, *) {
        if (!wh.IsRunning && !wh.IsPaused) {
            this.Close()
            return
        }

        saved := this.GUI.Submit(0)
        wh.Radius := saved.Radius
        wh.TimerFunction(wh.WindowHandle, reset := -1, {x: saved.x, y: saved.y}) 
    }

    ResetSettings(wh, *) {
        this.Close()
        wh.TimerFunction(wh.WindowHandle, reset := 1)
        wh.ResetSettings()
    }
    
    Show() {
        MouseGetPos(&x, &y)
        this.GUI.Show("x" x " y" y)
    }
    
    Close() {
        ToolTip()
        this.GUI.Destroy()
    }
}
