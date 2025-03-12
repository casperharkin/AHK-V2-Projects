;==================================================================================================================
; Direct2D Event System Example
;==================================================================================================================
; Description:    Demonstrates the use of the Direct2D event system
;                 Shows how to register event handlers and respond to various events
;
; Features:       - Event registration and handling
;                 - Performance monitoring with events
;                 - Responsive animation that adapts to window changes
;                 - Event-driven color changes
;
; Usage:          Run the script to see the event system in action
;
; Hotkeys:        R - Toggle VSync
;                 A - Toggle antialiasing
;                 Space - Pause/resume animation
;                 Escape - Exit
;
; Dependencies:   - AutoHotkey v2.0
;                 - D2D1.ahk library with event system
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   10/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk
#ErrorStdOut


/**
 * EventSystemExample class
 * Demonstrates the use of the Direct2D event system
 */
class EventSystemExample {
    ; Application properties
    width := 800
    height := 600
    title := "Direct2D Event System Example"
    
    ; Animation properties
    paused := false
    frameCount := 0
    lastFrameTime := 0
    fps := 0
    
    ; Drawing properties
    circles := []
    bgColor := 0x202020
    
    ; Performance tracking
    drawTimes := []
    maxDrawTimes := 60  ; Track the last 60 frames
    
    ; D2D1 and GUI references
    d2d := ""
    myGui := ""
    
    /**
     * Constructor
     */
    __New() {
        ; Create GUI window
        this.myGui := Gui("+AlwaysOnTop +Resize", this.title)
        this.myGui.OnEvent("Size", ObjBindMethod(this, "OnResize"))
        this.myGui.OnEvent("Close", ObjBindMethod(this, "OnExit"))
        this.myGui.Show("w" this.width " h" this.height)
        
        ; Initialize D2D1 instance
        this.d2d := D2D1(this.myGui.hwnd, 0, 0, this.width, this.height)
        
        ; Get window size and manually trigger resize to ensure render target matches window size
        WinGetClientPos(&x, &y, &w, &h, "ahk_id " this.myGui.hwnd)
        this.OnResize(this.myGui, 0, w, h)  ; 0 = not minimized
        
        ; Register event handlers
        this._registerEventHandlers()
        
        ; Create initial circles
        this._createCircles(100)
        
        ; Set up hotkeys
        this._configureHotkeys()
        
        ; Set up animation timer (60 FPS target)
        this.lastFrameTime := A_TickCount
        SetTimer(ObjBindMethod(this, "AnimationLoop"), 1)
    }
    
    /**
     * Register event handlers for the D2D1 instance
     */
    _registerEventHandlers() {
        ; Before draw event - prepare for drawing
        this.d2d.events.on("beforeDraw", ObjBindMethod(this, "_onBeforeDraw"))
        
        ; After draw event - track performance
        this.d2d.events.on("afterDraw", ObjBindMethod(this, "_onAfterDraw"))
        
        ; Window position/size change events
        this.d2d.events.on("afterPositionChange", ObjBindMethod(this, "_onPositionChange"))
        
        ; VSync change event
        this.d2d.events.on("afterVSyncChange", ObjBindMethod(this, "_onVSyncChange"))
        
        ; Antialiasing change event
        this.d2d.events.on("afterAntialiasChange", ObjBindMethod(this, "_onAntialiasChange"))
    }
    
    /**
     * Before draw event handler
     */
    _onBeforeDraw(d2d) {
        ; Record start time for performance tracking
        this.drawStartTime := A_TickCount
    }
    
    /**
     * After draw event handler
     */
    _onAfterDraw(d2d) {
        ; Calculate draw time
        drawTime := A_TickCount - this.drawStartTime
        
        ; Add to draw times array
        this.drawTimes.Push(drawTime)
        
        ; Keep only the last N frames
        if (this.drawTimes.Length > this.maxDrawTimes)
            this.drawTimes.RemoveAt(1)
    }
    
    /**
     * Position change event handler
     */
    _onPositionChange(d2d, newPos) {
        ; Adjust circles when window size changes
        if (newPos.width != this.width || newPos.height != this.height) {
            this.width := newPos.width
            this.height := newPos.height
            
            ; Adjust circle positions to fit new window size
            this._adjustCircles()
        }
    }
    
    /**
     * VSync change event handler
     */
    _onVSyncChange(d2d, enabled) {
        ; Change background color based on VSync state
        this.bgColor := enabled ? 0x202020 : 0x302020
        
        ; Debug output to verify the event is triggered
        OutputDebug("VSync changed to: " (enabled ? "ON" : "OFF"))
        OutputDebug("Background color set to: " Format("0x{:06X}", this.bgColor))
    }
    
    /**
     * Antialiasing change event handler
     */
    _onAntialiasChange(d2d, enabled) {
        ; Change circle colors based on antialiasing state
        this._updateCircleColors(enabled)
        
        ; Debug output to verify the event is triggered
        OutputDebug("Antialias changed to: " (enabled ? "ON" : "OFF"))
    }
    
    /**
     * Configure hotkeys
     */
    _configureHotkeys() {
        ; Toggle VSync
        Hotkey("r", ObjBindMethod(this, "ToggleVSync"))
        
        ; Toggle antialiasing
        Hotkey("a", ObjBindMethod(this, "ToggleAntialias"))
        
        ; Pause/resume animation
        Hotkey("Space", ObjBindMethod(this, "TogglePause"))
        
        ; Exit application
        Hotkey("Escape", ObjBindMethod(this, "OnExit"))
    }
    
    /**
     * Create initial circles
     * @param {Integer} count - Number of circles to create
     */
    _createCircles(count) {
        this.circles := []
        
        Loop count {
            ; Create a circle with random properties
            circle := {}
            circle.x := Random(50, this.width - 50)
            circle.y := Random(50, this.height - 50)
            circle.radius := Random(20, 40)
            circle.color := this._randomColor()
            circle.speedX := Random(-3, 3)
            circle.speedY := Random(-3, 3)
            
            ; Ensure non-zero speed
            if (circle.speedX == 0 && circle.speedY == 0) {
                circle.speedX := 1
                circle.speedY := 1
            }
            
            this.circles.Push(circle)
        }
    }
    
    /**
     * Adjust circles to fit new window size
     */
    _adjustCircles() {
        for circle in this.circles {
            ; Keep circles within window bounds
            if (circle.x < circle.radius)
                circle.x := circle.radius
            else if (circle.x > this.width - circle.radius)
                circle.x := this.width - circle.radius
                
            if (circle.y < circle.radius)
                circle.y := circle.radius
            else if (circle.y > this.height - circle.radius)
                circle.y := this.height - circle.radius
        }
    }
    
    /**
     * Update circle colors based on antialiasing state
     * @param {Boolean} antialiasEnabled - Whether antialiasing is enabled
     */
    _updateCircleColors(antialiasEnabled) {
        ; Debug output to verify the method is called
        OutputDebug("Updating circle colors. Antialias enabled: " antialiasEnabled)
        
        ; Use distinct colors for easier visual confirmation
        brightColor := 0xFFFF0000  ; Bright red (with antialiasing)
        darkColor := 0xFF0000FF    ; Dark blue (without antialiasing)
        
        for circle in this.circles {
            ; Adjust color based on antialiasing state
            if (antialiasEnabled) {
                ; Bright red with antialiasing
                circle.color := brightColor
                OutputDebug("Circle color set to bright red")
            } else {
                ; Dark blue without antialiasing
                circle.color := darkColor
                OutputDebug("Circle color set to dark blue")
            }
        }
    }
    
    /**
     * Generate a random color
     * @param {Integer} minComponent - Minimum RGB component value (0-255)
     * @param {Integer} maxComponent - Maximum RGB component value (0-255)
     * @returns {Integer} Random color in 0xAARRGGBB format
     */
    _randomColor(minComponent := 0x60, maxComponent := 0xFF) {
        r := Random(minComponent, maxComponent)
        g := Random(minComponent, maxComponent)
        b := Random(minComponent, maxComponent)
        return 0xFF000000 | (r << 16) | (g << 8) | b
    }
    
    /**
     * Main animation loop
     */
    AnimationLoop(*) {
        ; Calculate FPS
        currentTime := A_TickCount
        frameTime := currentTime - this.lastFrameTime
        this.lastFrameTime := currentTime
        
        ; Update FPS counter every 10 frames
        if (Mod(this.frameCount, 10) == 0) {
            this.fps := Round(1000 / Max(frameTime, 1))
        }
        
        this.frameCount++
        
        ; Skip updates if paused
        if (this.paused)
            return
            
        ; Update circle positions
        this._updateCircles()
        
        ; Draw the scene
        this._drawScene()
    }
    
    /**
     * Update circle positions and handle collisions
     */
    _updateCircles() {
        ; First update positions
        for circle in this.circles {
            ; Update position
            circle.x += circle.speedX
            circle.y += circle.speedY
            
            ; Bounce off walls
            if (circle.x - circle.radius <= 0 || circle.x + circle.radius >= this.width) {
                circle.speedX *= -1
                
                ; Ensure circle stays within bounds
                if (circle.x - circle.radius < 0)
                    circle.x := circle.radius
                else if (circle.x + circle.radius > this.width)
                    circle.x := this.width - circle.radius
            }
            
            if (circle.y - circle.radius <= 0 || circle.y + circle.radius >= this.height) {
                circle.speedY *= -1
                
                ; Ensure circle stays within bounds
                if (circle.y - circle.radius < 0)
                    circle.y := circle.radius
                else if (circle.y + circle.radius > this.height)
                    circle.y := this.height - circle.radius
            }
        }
        
        ; Then check for circle-to-circle collisions
        this._handleCircleCollisions()
    }
    
    /**
     * Handle collisions between circles
     */
    _handleCircleCollisions() {
        ; Check each pair of circles for collision
        circleCount := this.circles.Length
        
        ; Compare each circle with every other circle (only once per pair)
        Loop circleCount - 1 {
            i := A_Index
            circle1 := this.circles[i]
            
            ; Compare with all circles after this one
            Loop circleCount - i {
                j := i + A_Index
                circle2 := this.circles[j]
                
                ; Calculate distance between circle centers
                dx := circle2.x - circle1.x
                dy := circle2.y - circle1.y
                distance := Sqrt(dx*dx + dy*dy)
                
                ; Check if circles are colliding
                minDistance := circle1.radius + circle2.radius
                
                if (distance < minDistance) {
                    ; Circles are colliding, calculate collision response
                    
                    ; Normalize collision vector
                    if (distance == 0) {
                        ; Handle case where circles are exactly on top of each other
                        ; Move them slightly apart in a random direction
                        angle := Random(0, 360) * (3.14159 / 180)  ; Convert to radians
                        dx := Cos(angle)
                        dy := Sin(angle)
                        distance := 0.1  ; Small non-zero value
                    } else {
                        dx /= distance
                        dy /= distance
                    }
                    
                    ; Calculate overlap and move circles apart to prevent sticking
                    overlap := minDistance - distance
                    moveX := dx * overlap * 0.5
                    moveY := dy * overlap * 0.5
                    
                    ; Move circles apart
                    circle1.x -= moveX
                    circle1.y -= moveY
                    circle2.x += moveX
                    circle2.y += moveY
                    
                    ; Calculate dot product of velocity and collision normal
                    dot1 := circle1.speedX * dx + circle1.speedY * dy
                    dot2 := circle2.speedX * dx + circle2.speedY * dy
                    
                    ; Calculate collision impulse
                    ; For simplicity, assume equal mass for all circles
                    impulseX := dx * (dot2 - dot1)
                    impulseY := dy * (dot2 - dot1)
                    
                    ; Apply impulse to velocities
                    circle1.speedX += impulseX
                    circle1.speedY += impulseY
                    circle2.speedX -= impulseX
                    circle2.speedY -= impulseY
                    
                    ; Add a small random factor to prevent circles from getting stuck
                    circle1.speedX += Random(-0.2, 0.2)
                    circle1.speedY += Random(-0.2, 0.2)
                    circle2.speedX += Random(-0.2, 0.2)
                    circle2.speedY += Random(-0.2, 0.2)
                    
                    ; Ensure non-zero speed
                    if (Abs(circle1.speedX) < 0.1 && Abs(circle1.speedY) < 0.1) {
                        circle1.speedX := circle1.speedX == 0 ? 0.5 : (circle1.speedX > 0 ? 0.5 : -0.5)
                        circle1.speedY := circle1.speedY == 0 ? 0.5 : (circle1.speedY > 0 ? 0.5 : -0.5)
                    }
                    
                    if (Abs(circle2.speedX) < 0.1 && Abs(circle2.speedY) < 0.1) {
                        circle2.speedX := circle2.speedX == 0 ? 0.5 : (circle2.speedX > 0 ? 0.5 : -0.5)
                        circle2.speedY := circle2.speedY == 0 ? 0.5 : (circle2.speedY > 0 ? 0.5 : -0.5)
                    }
                }
            }
        }
    }
    
    /**
     * Draw the scene
     */
    _drawScene() {
        ; Begin drawing
        this.d2d.beginDraw()
        
        ; Clear background
        this.d2d.fillRectangle(0, 0, this.width, this.height, this.bgColor)
        
        ; Draw circles
        for circle in this.circles {
            this.d2d.fillCircle(circle.x, circle.y, circle.radius, circle.color)
            this.d2d.drawCircle(circle.x, circle.y, circle.radius, 0xFFFFFFFF, 2)
        }
        
        ; Add a pause indicator if paused
        if (this.paused) {
            ; Draw a semi-transparent overlay
            this.d2d.fillRectangle(0, 0, this.width, this.height, 0x40000000)
            
            ; Draw a large "PAUSED" text in the center
            this.d2d.drawText("PAUSED",
                             this.width / 2 - 100, this.height / 2 - 20,
                             40, 0xFFFFFFFF, "Arial", "w200 h40 aCenter")
        }
        
        ; Draw performance information
        this._drawPerformanceInfo()
        
        ; Draw status information
        this._drawStatusInfo()
        
        ; End drawing
        this.d2d.endDraw()
    }
    
    /**
     * Draw performance information
     */
    _drawPerformanceInfo() {
        ; Calculate average draw time
        avgDrawTime := 0
        if (this.drawTimes.Length > 0) {
            for time in this.drawTimes
                avgDrawTime += time
            avgDrawTime /= this.drawTimes.Length
        }
        
        ; Draw FPS counter
        this.d2d.drawText("FPS: " this.fps, 10, 10, 16, 0xFFFFFFFF, "Arial", "w100 h20")
        
        ; Draw average draw time
        this.d2d.drawText("Avg Draw Time: " Round(avgDrawTime, 2) " ms", 10, 30, 16, 0xFFFFFFFF, "Arial", "w200 h20")
        
        ; Draw frame count
        this.d2d.drawText("Frames: " this.frameCount, 10, 50, 16, 0xFFFFFFFF, "Arial", "w150 h20")
    }
    
    /**
     * Draw status information
     */
    _drawStatusInfo() {

        ; Draw VSync status
        vsyncColor := this.d2d.getVsync() ? 0x80FF80 : 0xFF8080
        this.d2d.drawText("VSync: " (this.d2d.getVsync() ? "ON" : "OFF") " (R to toggle)", 
                         10, this.height - 70, 16, vsyncColor, "Arial", "w300 h20")
        
        ; Get current antialiasing mode
        antialiasEnabled := this.d2d.getAntialias()

        ; Draw antialiasing status
        antialiasColor := antialiasEnabled ? 0x80FF80 : 0xFF8080
        this.d2d.drawText("Antialiasing: " (antialiasEnabled ? "ON" : "OFF") " (A to toggle)", 
                         10, this.height - 50, 16, antialiasColor, "Arial", "w300 h20")
        
        ; Draw pause status
        pauseColor := this.paused ? 0xFF8080 : 0x80FF80
        this.d2d.drawText("Animation: " (this.paused ? "PAUSED" : "RUNNING") " (Space to toggle)", 
                         10, this.height - 30, 16, pauseColor, "Arial", "w350 h20")
    }
    



    /**
     * Toggle VSync
     */
    ToggleVSync(*) {
        ; Get current VSync state
        currentVSync := this.d2d.vsync
        
        ; Debug output before toggle
        OutputDebug("Before toggle - VSync: " (currentVSync ? "ON" : "OFF"))
        
        ; Toggle VSync
        newState := !currentVSync
        this.d2d.setVSync(newState)
        
        ; Debug output after toggle
        OutputDebug("After toggle - Requested new state: " (newState ? "ON" : "OFF"))
        
        ; Manually update background color in case the event isn't firing
        this.bgColor := newState ? 0x202020 : 0x302020
        OutputDebug("Manually set background color to: " Format("0x{:06X}", this.bgColor))
        
        ; Manually trigger a resize to ensure render target matches window size
        WinGetClientPos(&x, &y, &w, &h, "ahk_id " this.myGui.hwnd)
        this.OnResize(this.myGui, 0, w, h)  ; 0 = not minimized
        
        ; Force a redraw to show the color change immediately
        this._drawScene()
    }
    
    /**
     * Toggle antialiasing
     */
    ToggleAntialias(*) {

        antialiasEnabled := this.d2d.getAntialias()
        ; Debug output before toggle
        OutputDebug("Before toggle - Antialiasing mode: " antialiasEnabled ")")
        
        ; Toggle antialiasing
        newState := !antialiasEnabled
        this.d2d.setAntialias(newState)
        
        ; Debug output after toggle
        OutputDebug("After toggle - Requested new state: " newState)
        
        ; Manually update circle colors in case the event isn't firing
        this._updateCircleColors(newState)
        
        ; Manually trigger a resize to ensure render target matches window size
        WinGetClientPos(&x, &y, &w, &h, "ahk_id " this.myGui.hwnd)
        this.OnResize(this.myGui, 0, w, h)  ; 0 = not minimized
        
        ; Force a redraw to show the color change immediately
        this._drawScene()
    }
    
    /**
     * Toggle pause state
     */
    TogglePause(*) {
        ; Get current pause state
        currentPaused := this.paused
        
        ; Debug output before toggle
        OutputDebug("Before toggle - Paused: " (currentPaused ? "YES" : "NO"))
        
        ; Toggle pause state
        this.paused := !currentPaused
        
        ; Debug output after toggle
        OutputDebug("After toggle - Paused: " (this.paused ? "YES" : "NO"))
        
        ; Make the pause status more visually distinct by changing the background color
        if (this.paused) {
            ; Darken the background when paused
            this.pausedBgColor := this.bgColor
            this.bgColor := 0x101010  ; Darker background when paused
            OutputDebug("Changed background to darker color for pause state")
        } else {
            ; Restore original background color when unpaused
            if (this.pausedBgColor) {
                this.bgColor := this.pausedBgColor
                OutputDebug("Restored original background color")
            }
        }
        
        ; Manually trigger a resize to ensure render target matches window size
        WinGetClientPos(&x, &y, &w, &h, "ahk_id " this.myGui.hwnd)
        this.OnResize(this.myGui, 0, w, h)  ; 0 = not minimized
        
        ; Force a redraw to update the status display
        this._drawScene()
    }
    
    /**
     * Handle window resize
     */
    OnResize(thisGui, MinMax, wSize, hSize) {
        if (MinMax = -1) ; Window is minimized
            return
            
        ; Update dimensions
        this.width := wSize
        this.height := hSize
        
        ; Resize the D2D1 render target to match the new window dimensions
        ; Use the _nrSize method directly to resize the render target
        if (this.d2d && this.d2d._renderTarget) {
            DllCall(this.d2d._nrSize, "Ptr", this.d2d._renderTarget, "ptr", D2D1Structs.D2D1_SIZE_U(wSize, hSize))
        }
    }
    
    /**
     * Handle application exit
     */
    OnExit(*) {
        ; Stop the animation timer
        SetTimer(ObjBindMethod(this, "AnimationLoop"), 0)
        
        ; Clean up D2D1 resources
        this.d2d.cleanup()
        
        ExitApp()
    }
}

; Create an instance of the example
example := EventSystemExample()