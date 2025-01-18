#Requires AutoHotkey v2.0
#SingleInstance Force
; Script:    WindowHole.ahk
; Author:    Casper Harkin
; Github:    https://github.com/casperharkin/AHK-V2-Projects/blob/main/WindowHole/WindowHole.ahk
; Date:      14/01/2025
; Version:   1.8

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
  - ^LButton to send window under overlay to the back of the Z-order

  Usage:
  Run the script and use the hotkeys to control the overlay's behavior.
*/

class WindowHole {
    ; Define hotkeys for controlling the overlay behavior
    static keys := {
        Activate: 'F1',                 ; Toggle overlay on/off
        Freeze: 'F2',                   ; Freeze/unfreeze overlay position
        ToggleShape: 'F3',              ; Toggle shape
        AdjustRadiusUp: '^WheelUp',     ; Increase overlay radius
        AdjustRadiusDown: '^WheelDown', ; Decrease overlay radius
        SendToBottom: '^LButton'        ; Send the window under overlay to back
    }

    ; Constructor initializes properties
    __Init() {
        this.Toggle := 0                 ; Overlay toggle state (on/off)
        this.ShapeType := "Circle"       ; Default shape
        this.RegionIndex := 1            ; Default shape index  (1: Circle, 2: Rectangle, 3: RoundedRectangle, etc)
        this.shapes := ["Circle",        ; Available shapes
        "Rectangle", "RoundedRectangle"] ; "Polygon" shape is not implemented. 
        this.Radius := 200               ; Default overlay radius
        this.Increment := 25             ; Step size for resizing radius
        this.TimerFn := ""               ; Timer function reference
        this.hWin := ""                  ; Handle to the overlayed window
        this.AlwaysOnTop := ""           ; Overlay "Always on Top" state
        this.Rate := 1                   ; Timer refresh rate (ms)
        this.IsRunning := false          ; Tracks timer activity state
        this.IsPaused := false           ; Tracks timer pause state
        SetWinDelay(-1)                  ; Optimizes window handling
        CoordMode("Mouse", "Screen")     ; Set mouse coordinates to screen
    }

    ; Static initializer binds hotkeys to class methods
    Static __New() {
        wh := WindowHole()
        Hotkey(this.keys.Activate, (*) => wh.ToggleTimer())
        Hotkey(this.keys.Freeze, (*) => wh.PauseTimer())
        Hotkey(this.keys.AdjustRadiusUp, (*) => wh.AdjustRadius(1))
        Hotkey(this.keys.AdjustRadiusDown, (*) => wh.AdjustRadius(-1))
        Hotkey(this.keys.SendToBottom, (*) => wh.SendToBottom())
        Hotkey(this.keys.ToggleShape, (*) => wh.ToggleShape())
    }

    ; Toggles the timer on/off
    ToggleTimer() => this.IsRunning ? this.StopTimer() : this.StartTimer()

    ; Adjusts the overlay radius up or down
    AdjustRadius(direction) {
        if (this.IsRunning) {
            this.Radius := Max(1, this.Radius + direction * this.Increment)
            this.TimerFunction(this.hWin, reset := 1) ; Restart to apply new radius
        } else {
            Send(direction = 1 ? "{WheelUp}" : "{WheelDown}") ; Default action
        }
    }

    ; Sends the underlying window to the back of the Z-order
    SendToBottom() {
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
        xPos := NumGet(rect, 0, "Int"), yPos := NumGet(rect, 4, "Int")
        width := NumGet(rect, 8, "Int"), height := NumGet(rect, 12, "Int")
    
        ; Pushes the window behind all others
        DllCall("User32.dll\SetWindowPos", "Ptr", hRoot, "UInt", HWND_BOTTOM := 1, 
                "Int", xPos, "Int", yPos, "Int", width, "Int", height, "UInt", SWP_NOSIZE := 0x4000)
    }

    ToggleShape() {
        for each, shape in this.shapes {
            if (shape = this.ShapeType) {
                this.ShapeType := this.shapes[this.RegionIndex := (this.RegionIndex >= this.shapes.length) ? 1 : this.RegionIndex + 1]
                this.TimerFunction(this.hWin, reset := 1) 
                break
            }
        }
    }

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
            
            ; case "Polygon":
            ;     points := params.points
            ;     buffery := buffer(16 * params.numPoints, 0)
            ;     Loop params.numPoints {
            ;         NumPut("int", points[A_Index].x + xOffset, buffery, (A_Index - 1) * 8)
            ;         NumPut("int", points[A_Index].y + yOffset, buffery, (A_Index - 1) * 8 + 4)
            ;     }
            ;     return DllCall("CreatePolygonRgn", "uint", &buffery, "int", params.numPoints, "int", params.polyFillMode, "ptr")
            
            default:
                
        }
    }

    MakeInvertedShape(hWin, type, params := {}, xOffset := 0, yOffset := 0) {
        ; Get the window dimensions
        rect := Buffer(16, 0) ; RECT structure: left, top, right, bottom
        DllCall("GetClientRect", "ptr", hWin, "ptr", rect)
        winWidth := NumGet(rect, 8, "int")  ; right - left
        winHeight := NumGet(rect, 12, "int") ; bottom - top

        ; Create a rectangular region covering the entire window
        hRectRegion := DllCall("CreateRectRgn", "int", 0, "int", 0, "int", winWidth, "int", winHeight, "ptr")
        
        ; Create the specific shape region
        hShapeRegion := this.MakeShape(type, params, xOffset, yOffset)

        ; Subtract the shape region from the rectangular region
        DllCall("CombineRgn", "ptr", hRectRegion, "ptr", hRectRegion, "ptr", hShapeRegion, "int", 4) ; RGN_DIFF
        DllCall("DeleteObject", "ptr", hShapeRegion) ; Clean up the shape region

        return hRectRegion ; Return the resulting inverted region
    }

    TimerFunction(hWin, reset := 0) {
        static px := "", py := ""
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hWin)
        MouseGetPos(&x, &y)

        if (x != px || y != py || reset) {
            px := x, py := y
            params := this.GetShapeParams()
            hRegion := this.MakeInvertedShape(hWin, this.ShapeType, params, x - wx, y - wy)
            DllCall("SetWindowRgn", "ptr", hWin, "ptr", hRegion, "int", True)
        }
    }

    GetShapeParams() {
        switch this.ShapeType {
            case "Circle":
                return {radius: this.Radius}
            case "Rectangle":
                return {width: this.Radius * 2, height: this.Radius * 2}
            case "RoundedRectangle":
                return {width: this.Radius * 4, height: this.Radius * 2, roundWidth: 30, roundHeight: 30}
            ; case "Polygon":
            ;     return { points: [{x: 0, y: 0}, {x: 50, y: 100}, {x: 100, y: 0}], numPoints: 3, polyFillMode: 1 }
        }
    }

    ; Starts the timer and initializes overlay
    StartTimer() {
        if  (this.IsPaused)
            return this.StopTimer()

        if (!this.hWin)
            this.InitializeWindow()

        this.TimerFn := this.TimerFunction.Bind(this, this.hWin)
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
        this.hWin := ""
        this.AlwaysOnTop := ""
        this.IsRunning := false
        this.IsPaused := false
    }

    ; Pauses the timer without resetting
    PauseTimer() {
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
        MouseGetPos(, , &hWin)
        this.hWin := hWin
        this.AlwaysOnTop := WinGetExStyle("ahk_id " this.hWin) & 0x8
        if (!this.AlwaysOnTop) {
            WinSetAlwaysOnTop(1, "ahk_id " this.hWin)
        }
    }

    ; Resets the window state when overlay is disabled
    ResetWindow() {
        if (this.hWin) {
            WinSetRegion(, "ahk_id " this.hWin) ; Remove custom region
            WinSetAlwaysOnTop(0, "ahk_id " this.hWin) ; Restore "Always on Top" state
        }
    }
}
