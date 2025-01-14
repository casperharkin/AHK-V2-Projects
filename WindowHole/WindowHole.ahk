#Requires AutoHotkey v2.0

; Script:    WindowHole.ahk
; Author:    Casper Harkin
; Github:    https://github.com/casperharkin/AHK-V2-Projects/blob/main/WindowHole/WindowHole.ahk
; Date:      14/01/2025
; Version:   1.0

/*
  WindowHole.ahk: Dynamic Window Overlay

  Inspired / Based on Helgef's v1 WinHole script, this AHK v2 implementation creates 
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
  - F3: Cycle through available shapes
  - WheelUp/WheelDown: Increase/decrease overlay radius
  - ^WheelUp/^WheelDown: Send window under overlay to the back of the Z-order

  Usage:
  Run the script and use the hotkeys to control the overlay's behavior.
*/

class WindowHole {

    ; Define hotkeys for controlling the overlay behavior
    static keys := {Activate: 'F1', Freeze: 'F2', ChangeRegion: 'F3',
                    AdjustRadiusUp: 'WheelUp', AdjustRadiusDown: 'WheelDown',
                    SendToBottomUp: '^WheelUp', SendToBottomDown: '^WheelDown'}

    ; Constructor initializes properties
    __Init() {
        this.RegionIndex := 1           ; Default shape: Circle
        this.Toggle := 0                ; Toggle state of the overlay
        this.Radius := 200              ; Default radius
        this.Increment := 25            ; Step size for resizing
        this.Rate := 40                 ; Timer refresh rate (ms)
        this.Region := this.MakeCircle(this.Radius) ; Default shape (circle)
        SetWinDelay(-1)                 ; Optimize window handling
    }

    ; Static initializer binds hotkeys to class methods
    Static __New() {
        wh := WindowHole()
        Hotkey(this.keys.Activate, (*) => wh.ToggleTimer())
        Hotkey(this.keys.Freeze, (*) => wh.Freeze())
        Hotkey(this.keys.ChangeRegion, (*) => wh.ChangeRegion())
        Hotkey(this.keys.AdjustRadiusUp, (*) => wh.AdjustRadius(1))
        Hotkey(this.keys.AdjustRadiusDown, (*) => wh.AdjustRadius(-1))
        Hotkey(this.keys.SendToBottomUp, (*) => wh.SendToBottom())
        Hotkey(this.keys.SendToBottomDown, (*) => wh.SendToBottom())
    }

    ; Change the shape of the overlay
    ChangeRegion() {
        Static Options := [this.MakeCircle(this.Radius), this.MakeHeart(this.Radius), this.MakeTriangle(this.Radius)]
        this.Region := Options[this.RegionIndex]
        this.RegionIndex := (this.RegionIndex >= 3) ? 1 : this.RegionIndex + 1
        this.AdjustRadius(1) ; Refresh the shape
    }

    ; Toggle the overlay (on/off)
    ToggleTimer() {
        this.Toggle := !this.Toggle
        this.ManageTimer(this.Toggle)
    }

    ; Freeze the overlay (stop updates)
    Freeze() {
        this.ManageTimer(-1)
    }

    ; Adjust the overlay radius
    AdjustRadius(direction) {
        if (this.Toggle) {
            this.Radius := Max(1, this.Radius + direction * this.Increment)
            ; Update the region based on the current shape
            Switch this.RegionIndex {
                Case 1: this.Region := this.MakeCircle(this.Radius)
                Case 2: this.Region := this.MakeHeart(this.Radius)
                Case 3: this.Region := this.MakeTriangle(this.Radius)
            }
            this.ManageTimer(1) ; Refresh the overlay
        } else {
            ; Send wheel input if overlay is off
            Send (direction = 1) ? "{WheelUp}" : "{WheelDown}"
        }
    }

    ; Define a window region based on shape and position
    WinSetRegion(hWin, region, dx := 0, dy := 0) {
        WinGetPos(, , &w, &h, "ahk_id " hWin)
        regionDefinition := "0-0 0-" h " " w "-" h " " w "-0 0-0 "
        for k, pt in region {
            regionDefinition .= (dx + pt.x) "-" (dy + pt.y) " "
        }
        WinSetRegion(regionDefinition, "ahk_id " hWin)
    }

    ; Manage the overlay timer function
    TimerFunction(hWin, reset := 0) {
        static px := "", py := ""
        WinGetPos(&wx, &wy, , , "ahk_id " hWin)
        CoordMode("Mouse", "Screen")
        MouseGetPos(&x, &y)
        x -= wx, y -= wy
        if (x != px || y != py || reset) {
            px := x, py := y
            this.WinSetRegion(hWin, this.Region, x, y)
        }
    }

    ; Control timer states (start/stop/reset)
    ManageTimer(state) {
        static TimerFn := "", hWin := "", AlwaysOnTop := ""
        if (state = 0) {
            ; Turn off the timer
            if (TimerFn) 
				SetTimer(TimerFn, 0)
            if (hWin) {
                WinSetRegion(, "ahk_id " hWin)
                WinSetAlwaysOnTop(0, "ahk_id " hWin)
            }
            TimerFn := "", hWin := "", AlwaysOnTop := ""
            return
        }
        if (state = -1 && TimerFn) {
            SetTimer(TimerFn, 0)
            TimerFn := ""
            return
        }
        if (TimerFn) 
			SetTimer(TimerFn, 0)
        if (!hWin) {
            ; Capture the active window under the mouse
            MouseGetPos(, , &hWin)
            AlwaysOnTop := WinGetExStyle("ahk_id " hWin) & 0x8
            if (!AlwaysOnTop) 
				WinSetAlwaysOnTop(1, "ahk_id " hWin)
        }

        TimerFn := this.TimerFunction.Bind(this, hWin)
        TimerFn.Call(1)
        SetTimer(TimerFn, this.Rate)
    }

    ; Send the window under the overlay to the back of the Z-order
    SendToBottom() {
        if (this.Toggle) {
            CoordMode("Mouse", "Screen")
            MouseGetPos(&x, &y)
            hWnd := DllCall("User32.dll\WindowFromPoint", "Int64", (x & 0xFFFFFFFF) | (y << 32), "Ptr")
            hRoothWnd := DllCall("User32.dll\GetAncestor", "Ptr", hWnd, "UInt", 2, "Ptr"), Rect := Buffer(16)
            DllCall("GetWindowRect", "Ptr", hRoothWnd, "Ptr", Rect)
            DllCall("User32.dll\SetWindowPos", "UInt", hRoothWnd, "UInt", 1, "Int", NumGet(Rect, 0, "Int"),
                "Int", NumGet(Rect, 4, "Int"), "Int", NumGet(Rect, 8, "Int"), "Int", NumGet(Rect, 12, "Int"), "UInt", 0x4000)
        }
    }

    /*
       Shape generation functions
    */

    ; Create a heart-shaped region
    MakeHeart(radius := this.Radius) {
        maxPoints := 997 ; Maximum points for WinSet,Region
        n := Min(radius * 4, maxPoints) ; Adjust points to the maximum allowed
        region := []
        offsetY := -radius // 2
        ; Upper heart loop
        Loop n {
            x := -2 + 4 * (A_Index - 1) / (n - 1)
            y := -Sqrt(1 - (Abs(x) - 1) ** 2)
            region.Push({x: x * radius, y: y * radius + offsetY})
        }
        ; Lower heart loop
        Loop n {
            x := 2 - 4 * (A_Index - 1) / (n - 1)
            y := 3 * Sqrt(1 - Sqrt(Abs(x / 2)))
            region.Push({x: x * radius, y: y * radius + offsetY})
        }
        return region
    }

    ; Create a triangular region
    MakeTriangle(side := this.Radius) {
        height := Round(side * Sqrt(3) / 2) ; Triangle height
        region := [
            {x: 0, y: 0},
            {x: side // 2, y: height},
            {x: -side // 2, y: height},
            {x: 0, y: 0}
        ]
        offsetY := -height // 2 ; Center triangle vertically
        for _, pt in region {
            pt.y += offsetY ; Adjust y-coordinate
        }
        return region
    }

    ; Create a circular region
    MakeCircle(radius := this.Radius, numPoints := -1) {
        static pi := ATan(1) * 4 ; Pi approximation
        numPoints := (numPoints = -1) ? Ceil(2 * radius * pi) : numPoints
        numPoints := Min(numPoints, 1994) ; Cap points to maximum allowed
        region := []
        Loop numPoints + 1 {
            theta := 2 * pi * (A_Index - 1) / numPoints
            region.Push({x: Round(radius * Cos(theta)), y: Round(radius * Sin(theta))})
        }
        return region
    }
}
