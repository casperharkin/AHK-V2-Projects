#Requires AutoHotkey v2.0

; Script:    WindowHole.ahk
; Author:    Casper Harkin
; Github:    https://github.com/casperharkin/AHK-V2-Projects/blob/main/WindowHole/WindowHole.ahk
; Date:      14/01/2025
; Version:   1.8

/*
  WindowHole.ahk: Dynamic Window Overlay

  Inspired by Helgef's v1 WinHole script, this AHK v2 implementation creates 
  a movable and resizable "window hole" overlay, allowing visibility through 
  a specified area of the screen. Users can customize the shape, size, and 
  behavior of the overlay to enhance multitasking or focus.
  Helgef's v1 Post - https://www.autohotkey.com/boards/viewtopic.php?f=6&t=30622

  Features:
  - Adjustable hole radius and position
  - Multiple shapes (circle, heart, triangle)
  - Hotkeys for toggling, freezing, resizing, and changing shape
  - Interaction with underlying windows (e.g., sending to the back)

  Hotkeys:
  - F1: Toggle overlay on/off
  - F2: Freeze/unfreeze overlay position
  - F3: Cycle through available shapes (WIP)
  - ^WheelUp/^WheelDown: Increase/decrease overlay radius
  - ^LButton to send window under overlay to the back of the Z-order

  Usage:
  Run the script and use the hotkeys to control the overlay's behavior.
*/

class WindowHole {
    ; Define hotkeys for controlling the overlay behavior
    static keys := {
        Activate: 'F1',
        Freeze: 'F2',
        ChangeRegion: 'F3',
        AdjustRadiusUp: '^WheelUp',
        AdjustRadiusDown: '^WheelDown',
        SendToBottom: '^LButton'
    }

    ; Constructor initializes properties
    __Init() {
        this.RegionIndex := 1            ; Default shape: Circle
        this.Toggle := 0                 ; Toggle state of the overlay
        this.Radius := 200               ; Default radius
        this.Increment := 25             ; Step size for resizing
        this.Region := this.MakeCircle() ; Default shape (circle)
        this.TimerFn := ""
        this.hWin := ""
        this.AlwaysOnTop := ""
        this.Rate := 1                   ; Timer refresh rate (ms)
        this.IsRunning := false          ; Tracks whether the timer is running
        SetWinDelay(-1)                  ; Optimize window handling
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

    ToggleTimer() => this.IsRunning ? this.StopTimer() : this.StartTimer()

    AdjustRadius(direction) {
        if (this.IsRunning) {
            this.Radius := Max(1, this.Radius + direction * this.Increment)
            this.Region := this.MakeCircle(this.Radius)
            this.RestartTimer()
        } else {
            Send(direction = 1 ? "{WheelUp}" : "{WheelDown}") ; Send wheel input if Timer is off
        }
    }

    SendToBottom() {
        if (this.IsRunning) {
            CoordMode("Mouse", "Screen")
            MouseGetPos(&x, &y)
            hWnd := DllCall("User32.dll\WindowFromPoint", "Int64", (x & 0xFFFFFFFF) | (y << 32), "Ptr")
            hRoot := DllCall("User32.dll\GetAncestor", "Ptr", hWnd, "UInt", 2, "Ptr"), rect := Buffer(16)
            DllCall("GetWindowRect", "Ptr", hRoot, "Ptr", rect)
            DllCall("User32.dll\SetWindowPos", "UInt", hRoot, "UInt", 1,
                "Int", NumGet(rect, 0, "Int"), "Int", NumGet(rect, 4, "Int"),
                "Int", NumGet(rect, 8, "Int"), "Int", NumGet(rect, 12, "Int"), "UInt", 0x4000)
        }
    }

    WinSetRegion(hWin, region, dx := 0, dy := 0) {
        WinGetPos(, , &w, &h, "ahk_id " hWin)
        regionDef := "0-0 0-" h " " w "-" h " " w "-0 0-0 "
        for _, pt in region {
            regionDef .= (dx + pt.x) "-" (dy + pt.y) " "
        }
        WinSetRegion(regionDef, "ahk_id " hWin)
    }

    TimerFunction(hWin, reset := 0) {
        static px := "", py := ""

        WinGetPos(&wx, &wy, &ww, &wh, "ahk_id " hWin)
        CoordMode("Mouse", "Screen")
        MouseGetPos(&x, &y)

        if (x < wx || x > wx + ww || y < wy || y > wy + wh) { ; Check if the mouse is outside the window
            this.RestartTimer()
        }

        x -= wx, y -= wy
        if (x != px || y != py || reset) {
            px := x, py := y
            this.WinSetRegion(hWin, this.Region, x, y)
        }
    }

    StartTimer() {
        if (!this.hWin) {
            this.InitializeWindow()
        }
        this.TimerFn := this.TimerFunction.Bind(this, this.hWin)
        this.TimerFn.Call(1)
        SetTimer(this.TimerFn, this.Rate)
        this.IsRunning := true
    }

    StopTimer() {
        if (this.TimerFn) {
            SetTimer(this.TimerFn, 0)
        }
        this.ResetWindow()
        this.TimerFn := "", this.hWin := "", this.AlwaysOnTop := "", this.IsRunning := false
    }

    PauseTimer() {
        if (this.TimerFn) {
            SetTimer(this.TimerFn, 0)
            this.IsRunning := false
        }
    }

    RestartTimer() {
        this.StopTimer()
        this.StartTimer()
    }

    InitializeWindow() {
        MouseGetPos(, , &hWin)
        this.hWin := hWin
        this.AlwaysOnTop := WinGetExStyle("ahk_id " this.hWin) & 0x8
        if (!this.AlwaysOnTop) {
            WinSetAlwaysOnTop(1, "ahk_id " this.hWin)
        }
    }

    ResetWindow() {
        if (this.hWin) {
            WinSetRegion(, "ahk_id " this.hWin)
            WinSetAlwaysOnTop(0, "ahk_id " this.hWin)
        }
    }

    MakeCircle(radius := this.Radius, numPoints := -1) {
        static pi := ATan(1) * 4
        numPoints := (numPoints = -1) ? Ceil(2 * radius * pi) : numPoints
        numPoints := Min(numPoints, 1994)
        region := []
        Loop numPoints + 1 {
            theta := 2 * pi * (A_Index - 1) / numPoints
            region.Push({x: Round(radius * Cos(theta)), y: Round(radius * Sin(theta))})
        }
        return region
    }
}
