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
  - ^WheelUp/^WheelDown: Increase/decrease overlay radius
  - ^LButton to send window under overlay to the back of the Z-order

  Usage:
  Run the script and use the hotkeys to control the overlay's behavior.
*/

class WindowHole {
    ; Define hotkeys for controlling the overlay behavior
    static keys := {
        Activate: 'F1',             ; Toggle overlay on/off
        Freeze: 'F2',               ; Freeze/unfreeze overlay position
        AdjustRadiusUp: '^WheelUp', ; Increase overlay radius
        AdjustRadiusDown: '^WheelDown', ; Decrease overlay radius
        SendToBottom: '^LButton'    ; Send the window under overlay to back
    }

    ; Constructor initializes properties
    __Init() {
        this.Toggle := 0                 ; Overlay toggle state (on/off)
        this.Radius := 200               ; Default overlay radius
        this.Increment := 25             ; Step size for resizing radius
        this.Region := this.MakeCircle() ; Default shape (circle region)
        this.TimerFn := ""               ; Timer function reference
        this.hWin := ""                  ; Handle to the overlayed window
        this.AlwaysOnTop := ""           ; Overlay "Always on Top" state
        this.Rate := 1                   ; Timer refresh rate (ms)
        this.IsRunning := false          ; Tracks timer activity state
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
    }

    ; Toggles the timer on/off
    ToggleTimer() => this.IsRunning ? this.StopTimer() : this.StartTimer()

    ; Adjusts the overlay radius up or down
    AdjustRadius(direction) {
        if (this.IsRunning) {
            this.Radius := Max(1, this.Radius + direction * this.Increment)
            this.Region := this.MakeCircle(this.Radius) ; Update shape
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

    ; Sets a window's region for transparency
    WinSetRegion(hWin, region, dx := 0, dy := 0) {
        WinGetPos(, , &w, &h, "ahk_id " hWin)
        regionDef := "0-0 0-" h " " w "-" h " " w "-0 0-0 "
        for _, pt in region {
            regionDef .= (dx + pt.x) "-" (dy + pt.y) " "
        }
        WinSetRegion(regionDef, "ahk_id " hWin)
    }

    ; Creates a circular region for the overlay
    MakeCircle(radius := this.Radius, numPoints := -1) {
        static pi := ATan(1) * 4
        numPoints := (numPoints = -1) ? Ceil(2 * radius * pi) : numPoints
        numPoints := Min(numPoints, 1994) ; Limit number of points for stability
        region := []
        ; Generate points along the circle's perimeter
        Loop numPoints + 1 {
            theta := 2 * pi * (A_Index - 1) / numPoints
            region.Push({x: Round(radius * Cos(theta)), y: Round(radius * Sin(theta))})
        }
        return region
    }

    ; Timer function for overlay positioning
    TimerFunction(hWin, reset := 0) {
        static px := "", py := ""
        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hWin)
        MouseGetPos(&x, &y)

        ; Restart timer if mouse moves outside the overlay
        if (x < wx || x > wx + ww || y < wy || y > wy + wh) {
            this.RestartTimer()
        } else {
            x -= wx, y -= wy ; Relative to overlay window
            if (x != px || y != py || reset) { ; Update only if position changes
                px := x, py := y
                this.WinSetRegion(hWin, this.Region, x, y)
            }
        }
    }

    ; Starts the timer and initializes overlay
    StartTimer() {
        if (!this.hWin) {
            this.InitializeWindow()
        }
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
    }

    ; Pauses the timer without resetting
    PauseTimer() {
        if (this.TimerFn) {
            SetTimer(this.TimerFn, 0)
            this.IsRunning := false
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
