;==================================================================================================================
; Direct2D Wrapper for AutoHotkey v2
;==================================================================================================================
; Description:    Object-oriented interface to the Windows Direct2D API for AHK v2
;                 Provides hardware-accelerated 2D graphics capabilities with simple methods
;
; Features:       - Hardware-accelerated rendering with Direct2D
;                 - Object-oriented design with resource management
;                 - Support for shapes, text, and custom geometries
;                 - VSync control for smooth animations
;                 - Automatic resource cleanup
;
;
; Dependencies:   - AutoHotkey v2.0+
;                 - D2D1Structs.ahk
;                 - D2D1Shapes.ahk
;                 - Windows with Direct2D support
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   10/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include "D2D1Structs.ahk"
#Include "D2D1Shapes.ahk"

; Based on Spawnova's Direct2D overlay class: https://github.com/Spawnova/ShinsOverlayClass

/**
 * Example usage of the D2D1 class
 */
if (A_ScriptName = "d2d1.ahk") {
    ; Create GUI window
    myGui := Gui(" +Alwaysontop +Resize", "D2D1 Example")


    ; Initialise D2D1 instance
    d2d := D2D1(myGui.hwnd, x := 700, y := 500, width := 800, height := 600)

    ; Set up drawing timer
    TimerFn := DrawExample.Bind(d2d)
    SetTimer(TimerFn, 40)

    ; Set up close event
    myGui.OnEvent("Close",  (*) => guiClose(d2d, TimerFn))


    ; Drawing function
    DrawExample(d2d) {
        ; Begin drawing
        d2d.beginDraw()
        
        ; Clear background
        d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
        
        ; Draw shapes
        d2d.fillRectangle(30, 30, 100, 100, 0xFFFF1D)
        d2d.fillCircle(600, 300, 150, 0xCD1C1C)
        d2d.drawLine(150, 150, 600, 600, 0x000000, 5)
        d2d.fillPolygon([[250, 150], [150, 350], [350, 350]], 0x2516FF, 200, -150)

        ; End drawing
        d2d.endDraw()
    }

    guiClose(d2d, TimerFn){
        SetTimer(TimerFn, 0)
        d2d.cleanup()
        d2d := TimerFn := ""
    }
}

/**
 * Main D2D1 class for Direct2D operations
 */
class D2D1 {
    ; Private properties
    _is64Bit := false
    _factory := 0
    _renderTarget := 0
    _brush := 0
    _stroke := 0
    _strokeRounded := 0
    _wFactory := 0
    _gdiplusToken := 0
    _drawing := 0
    _resourceManager := 0
    _textFormats := Map()
    
    ; Public properties
    width := 800
    height := 600
    hwnd := 0
    x := 0
    y := 0
    vsync := true  ; VSync enabled by default
    
    ; Buffer properties
    _rect1Ptr := 0
    _rect2Ptr := 0
    _colPtr := 0
    _clrPtr := 0
    _matrixPtr := 0
    
    ; Function pointers
    _drawText := 0
    _beginDraw := 0
    _clear := 0
    _endDraw := 0
    _rMatrix := 0
    _drawEllipse := 0
    _fillEllipse := 0
    _drawRectangle := 0
    _fillRectangle := 0
    _drawRoundedRectangle := 0
    _fillRoundedRectangle := 0
    _drawLine := 0
    _nrSize := 0
    _setBrush := 0
    _createStroke := 0
    _createTextFormat := 0
    _createTextLayout := 0
    
    ; Constants
    static DEFAULT_DPI := 96
    static DEFAULT_ALPHA_MODE := 1
    
    /**
     * Constructor - Initialize Direct2D resources
     * @param {Integer} hwnd - Window handle
     * @param {Integer} x - X position
     * @param {Integer} y - Y position
     * @param {Integer} width - Width
     * @param {Integer} height - Height
     * @param {Boolean} vsync - Whether to enable VSync (default: true)
     * @returns {D2D1} - D2D1 instance
     */
    __New(hwnd, x := 0, y := 0, width := 800, height := 600, vsync := true) {
        ; Initialize resource manager
        this._resourceManager := D2D1ResourceManager()
        
        ; Initialize basic properties
        this._is64Bit := (A_PtrSize == 8)
        this.width := width
        this.height := height
        this.hwnd := hwnd
        this.vsync := vsync
        
        ; Load required DLLs
        this._loadRequiredLibraries()
        
        ; Initialize GDI+
        this._initializeGdiPlus()
        
        ; Create Direct2D factory
        this._createFactory()
        
        ; Show the GUI window
        ;DllCall("SetWindowPos", "Uptr", this.hwnd, "Uptr", 0, "Int", this.x, "Int", this.y, "Int", 0, "Int", 0, "UInt", 0x1)  ; 0x40 = SWP_SHOWWINDOW, 0x1 = SWP_NOSIZE
        DllCall("ShowWindow", "Uptr", this.hwnd, "uint", 1)
        
        ; Set up message handling
        this._onEraseFunc := ObjBindMethod(this, "onErase")
        OnMessage(0x14, this._onEraseFunc)
        
        ; Allocate buffers
        this._allocateBuffers()
        
        ; Set layered window attributes
        DllCall("SetLayeredWindowAttributes", "Uptr", hwnd, "Uint", 0, "char", 255, "uint", 2)
        
        ; Create stroke objects
        this._createStrokeObjects()
        
        ; Create render target
        this._createRenderTarget()
        
        ; Create brush and enable anti-aliasing
        this._createBrush()
        
        ; Create DirectWrite factory
        this._createWriteFactory()
        
        ; Initialize function pointers
        this._initFunctionPointers()
        
        ; Set position and clear
        this.setPosition(x, y)
        this.clear()
        
        return this
    }
    
    /**
     * Load required DLLs
     * @private
     */
    _loadRequiredLibraries() {
        for dll in ["d2d1", "dwrite", "dwmapi", "gdiplus"] {
            if !DllCall("GetModuleHandle", "str", dll, "Ptr")
                DllCall("LoadLibrary", "Str", dll)
        }
    }
    
    /**
     * Initialize GDI+
     * @private
     */
    _initializeGdiPlus() {
        token := 0
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &token, "Ptr", D2D1Structs.gdiplusStartupInput(), "Ptr*", 0)
        this._gdiplusToken := token
    }
    
    /**
     * Create Direct2D factory
     * @private
     * @throws {Error} If factory creation fails
     */
    _createFactory() {
        ; Create GUIDs for Direct2D and DirectWrite factories
        this._createGuid("{06152247-6f50-465a-9245-118bfd3b6007}", &clsidFactory)
        this._createGuid("{b859ee5a-d838-4b5b-a2e8-1adc7d93db48}", &clsidwFactory)
        
        ; Create Direct2D factory
        pOut := 0
        if (DllCall("d2d1\D2D1CreateFactory", "uint", 1, "Ptr", clsidFactory, "uint*", 0, "Ptr*", &pOut) != 0) {
            throw Error("Failed to create Direct2D factory. Error: " DllCall("GetLastError", "uint"), -1)
        }
        this._factory := pOut
        this._resourceManager.addResource("Factory", pOut, this._vTable(pOut, 2))
    }
    
    /**
     * Allocate buffers for various operations
     * @private
     */
    _allocateBuffers() {
        this._rect1Ptr := Buffer(64, 0)
        this._rect2Ptr := Buffer(64, 0)
        this._colPtr := Buffer(64, 0)
        this._clrPtr := Buffer(64, 0)
    }
    
    /**
     * Create stroke objects
     * @private
     * @throws {Error} If stroke creation fails
     */
    _createStrokeObjects() {
        this._D2D1_STROKE_STYLE_PROPERTIES := D2D1Structs.D2D1_STROKE_STYLE_PROPERTIES(
            StartCap := 2, EndCap := 2, DashCap := 0, LineJoin := 2, 
            MiterLimit := 255, DashStyle := 0, DashOffset := 0
        )
        this._createStroke := this._vTable(this._factory, 11)
        
        ; Create stroke object
        pOut := 0
        if (DllCall(this._createStroke, "ptr", this._factory, "ptr", this._D2D1_STROKE_STYLE_PROPERTIES, 
                    "ptr", 0, "uint", 0, "ptr*", &pOut) != 0) {
            throw Error("Failed to create stroke object. Error: " DllCall("GetLastError", "uint"), -1)
        }
        this._stroke := pOut
        this._resourceManager.addResource("Stroke", pOut, this._vTable(pOut, 2))
        
        ; Create rounded stroke object
        if (DllCall(this._createStroke, "ptr", this._factory, "ptr", this._D2D1_STROKE_STYLE_PROPERTIES, 
                    "ptr", 0, "uint", 0, "ptr*", &pOut) != 0) {
            throw Error("Failed to create rounded stroke object. Error: " DllCall("GetLastError", "uint"), -1)
        }
        this._strokeRounded := pOut
        this._resourceManager.addResource("StrokeRounded", pOut, this._vTable(pOut, 2))
    }
    
    /**
     * Create render target
     * @private
     * @throws {Error} If render target creation fails
     */
    _createRenderTarget() {
        D2D1_RENDER_TARGET_PROPERTIES := D2D1Structs.D2D1_RENDER_TARGET_PROPERTIES(
            D2D1_RENDER_TARGET_TYPE := 0, DXGI_FORMAT := 0,
            D2D1_ALPHA_MODE := D2D1.DEFAULT_ALPHA_MODE,
            dpiX := D2D1.DEFAULT_DPI, dpiY := D2D1.DEFAULT_DPI,
            D2D1_RENDER_TARGET_USAGE := 0, D2D1_FEATURE_LEVEL := 0
        )
        
        ; Set present options based on VSync setting
        ; D2D1_PRESENT_OPTIONS_NONE = 0 (VSync enabled)
        ; D2D1_PRESENT_OPTIONS_IMMEDIATELY = 2 (VSync disabled)
        presentOptions := this.vsync ? 0 : 2
        
        D2D1_HWND_RENDER_TARGET_PROPERTIES := D2D1Structs.D2D1_HWND_RENDER_TARGET_PROPERTIES(
            this.hwnd, this.width, this.height, presentOptions
        )
        
        pOut := 0
        if (DllCall(this._vTable(this._factory, 14), "Ptr", this._factory, 
                    "Ptr", D2D1_RENDER_TARGET_PROPERTIES, 
                    "ptr", D2D1_HWND_RENDER_TARGET_PROPERTIES, 
                    "Ptr*", &pOut) != 0) {
            throw Error("Failed to create render target. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        this._renderTarget := pOut
        this._resourceManager.addResource("RenderTarget", pOut, this._vTable(pOut, 2))
    }
    
    /**
     * Create brush and enable anti-aliasing
     * @private
     * @throws {Error} If brush creation fails
     */
    _createBrush() {
        this._matrixPtr := D2D1Structs.D2D1_MATRIX_3X2_F()
        
        pOut := 0
        if (DllCall(this._vTable(this._renderTarget, 8), "Ptr", this._renderTarget,
                    "Ptr", this._colPtr, "Ptr", this._matrixPtr, "Ptr*", &pOut) != 0) {
            throw Error("Failed to create brush. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        this._brush := pOut
        this._resourceManager.addResource("Brush", pOut, this._vTable(pOut, 2))
        
        ; Enable anti-aliasing by default
        this.setAntialias(true)
    }
    
    /**
     * Create DirectWrite factory
     * @private
     * @throws {Error} If DirectWrite factory creation fails
     */
    _createWriteFactory() {
        pOut := 0
        this._createGuid("{b859ee5a-d838-4b5b-a2e8-1adc7d93db48}", &clsidwFactory)
        
        ; Create DirectWrite factory (0 = DWRITE_FACTORY_TYPE_SHARED)
        if (DllCall("dwrite\DWriteCreateFactory", "uint", 0, "Ptr", clsidwFactory, "Ptr*", &pOut) != 0) {
            throw Error("Failed to create DirectWrite factory. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        this._wFactory := pOut
        this._resourceManager.addResource("WriteFactory", pOut, this._vTable(pOut, 2))
    }
    
    /**
     * Initialize function pointers
     * @private
     */
    _initFunctionPointers() {
        this._drawText := this._vTable(this._renderTarget, 27)
        this._beginDraw := this._vTable(this._renderTarget, 48)
        this._clear := this._vTable(this._renderTarget, 47)
        this._endDraw := this._vTable(this._renderTarget, 49)
        this._rMatrix := this._vTable(this._renderTarget, 30)
        this._drawEllipse := this._vTable(this._renderTarget, 20)
        this._fillEllipse := this._vTable(this._renderTarget, 21)
        this._drawRectangle := this._vTable(this._renderTarget, 16)
        this._fillRectangle := this._vTable(this._renderTarget, 17)
        this._drawRoundedRectangle := this._vTable(this._renderTarget, 18)
        this._fillRoundedRectangle := this._vTable(this._renderTarget, 19)
        this._drawLine := this._vTable(this._renderTarget, 15)
        this._nrSize := this._vTable(this._renderTarget, 58)
        this._setBrush := this._vTable(this._brush, 8)
        this._createTextFormat := this._vTable(this._wFactory, 15)
    }
    
    /**
     * Set position of the window
     * @param {Integer} x - X position
     * @param {Integer} y - Y position
     * @param {Integer} w - Width (optional)
     * @param {Integer} h - Height (optional)
     */
    setPosition(x, y, w := 0, h := 0) {
        this.x := x
        this.y := y
        
        if (!this.hwnd && w != 0 && h != 0) {
            this.width := w
            this.height := h
            DllCall(this._nrSize, "Ptr", this._renderTarget, "ptr", D2D1Structs.D2D1_SIZE_U(w, h))
        }
        
        DllCall("MoveWindow", "Uptr", this.hwnd, "int", x, "int", y,
                "int", this.width, "int", this.height, "char", 1)
    }
    
    /**
     * Set antialiasing mode
     * @param {Boolean} enable - Whether to enable antialiasing
     */
    setAntialias(enable := true) {
        ; D2D1_ANTIALIAS_MODE_PER_PRIMITIVE = 0
        ; D2D1_ANTIALIAS_MODE_ALIASED = 1
        DllCall(this._vTable(this._renderTarget, 32), "Ptr", this._renderTarget, "Uint", enable ? 0 : 1)
    }
    
    /**
     * Enable or disable VSync
     * @param {Boolean} enable - Whether to enable VSync
     * @returns {Boolean} True if successful, false otherwise
     */
    setVSync(enable := true) {
        ; If the setting hasn't changed, do nothing
        if (this.vsync = enable)
            return true
            
        ; Update the VSync setting
        this.vsync := enable
        
        ; Check if we can modify the existing render target's properties
        ; Unfortunately, Direct2D doesn't allow changing present options after creation
        ; We need to recreate the render target with the new VSync setting
        
        ; Store current state to restore after recreation
        local currentAntialias := DllCall(this._vTable(this._renderTarget, 33), "Ptr", this._renderTarget, "Uint*", &antialiasMode := 0) == 0 ? antialiasMode : 0
        
        ; First, release the existing render target
        if (this._renderTarget) {
            ; End any ongoing drawing
            if (this._drawing) {
                this.endDraw()
                this._drawing := 0
            }
            
            ; Release the render target
            this._resourceManager.releaseResource("RenderTarget")
            this._renderTarget := 0
            
            ; Also release the brush since it's tied to the render target
            this._resourceManager.releaseResource("Brush")
            this._brush := 0
        }
        
        ; Recreate the render target
        this._createRenderTarget()
        
        ; Recreate the brush
        this._createBrush()
        
        ; Reinitialize function pointers
        this._initFunctionPointers()
        
        ; Restore previous antialiasing setting
        this.setAntialias(currentAntialias == 0)
        
        return true
    }
    
    /**
     * Begin drawing operations
     * @returns {Integer} 1 if successful, 0 otherwise
     */
    beginDraw() {
        local pOut := 0, GetWindowRectResult := this.hwnd
        local rectBuffer := Buffer(16, 0)  ; Proper RECT structure (left, top, right, bottom)
        
        if (!DllCall("GetWindowRect", "Uptr", GetWindowRectResult, "ptr", rectBuffer)) {
            if (this._drawing) {
                this.clear()
                this._drawing := 0
            }
            return 0
        }
        
        DllCall(this._beginDraw, "Ptr", this._renderTarget)
        DllCall(this._clear, "Ptr", this._renderTarget, "Ptr", this._clrPtr)
        
        return this._drawing := 1
    }
    
    /**
     * Draw a circle outline with the specified color and thickness
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radius - Circle radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    drawCircle(x, y, radius, color, thickness := 1, rounded := 0) {
        if (radius <= 0) {
            throw Error("Invalid circle dimensions. Radius must be positive.", -1)
        }
        
        this._setBrushColor(color)
        DllCall(this._drawEllipse, "Ptr", this._renderTarget,
                "Ptr", D2D1Structs.D2D_RECT_F(x, y, radius, radius),
                "ptr", this._brush,
                "float", thickness,
                "ptr", (rounded ? this._strokeRounded : this._stroke))
    }
    
    /**
     * Draw an ellipse outline with the specified color and thickness
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radiusX - X radius
     * @param {Number} radiusY - Y radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    drawEllipse(x, y, radiusX, radiusY, color, thickness := 1, rounded := 0) {
        if (radiusX <= 0 || radiusY <= 0) {
            throw Error("Invalid ellipse dimensions. Radii must be positive.", -1)
        }
        
        this._setBrushColor(color)
        DllCall(this._drawEllipse, "Ptr", this._renderTarget,
                "Ptr", D2D1Structs.D2D_RECT_F(x, y, radiusX, radiusY),
                "ptr", this._brush,
                "float", thickness,
                "ptr", (rounded ? this._strokeRounded : this._stroke))
    }
    
    /**
     * Fill a circle with the specified color
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radius - Circle radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    fillCircle(x, y, radius, color) {
        if (radius <= 0) {
            throw Error("Invalid circle dimensions. Radius must be positive.", -1)
        }
        
        this._setBrushColor(color)
        DllCall(this._fillEllipse, "Ptr", this._renderTarget,
                "Ptr", D2D1Structs.D2D_RECT_F(x, y, radius, radius),
                "ptr", this._brush)
    }
    
    /**
     * Draw a rectangle outline with the specified color and thickness
     * @param {Number} x - Top-left X coordinate
     * @param {Number} y - Top-left Y coordinate
     * @param {Number} w - Width
     * @param {Number} h - Height
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded corners
     */
    drawRectangle(x, y, w, h, color, thickness := 1, rounded := 0) {
        if (w <= 0 || h <= 0) {
            throw Error("Invalid rectangle dimensions. Width and height must be positive.", -1)
        }
        
        this._setBrushColor(color)
        DllCall(this._drawRectangle, "Ptr", this._renderTarget,
                "Ptr", D2D1Structs.D2D_RECT_F(x, y, x+w, y+h),
                "ptr", this._brush,
                "float", thickness,
                "ptr", (rounded ? this._strokeRounded : this._stroke))
    }
    
    /**
     * Fill a rectangle with the specified color
     * @param {Number} x - Top-left X coordinate
     * @param {Number} y - Top-left Y coordinate
     * @param {Number} w - Width
     * @param {Number} h - Height
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    fillRectangle(x, y, w, h, color) {
        if (w <= 0 || h <= 0) {
            throw Error("Invalid rectangle dimensions. Width and height must be positive.", -1)
        }
        
        this._setBrushColor(color)
        DllCall(this._fillRectangle, "Ptr", this._renderTarget,
                "Ptr", D2D1Structs.D2D_RECT_F(x, y, x+w, y+h),
                "ptr", this._brush)
    }
    
    /**
     * Draw a rounded rectangle outline with the specified color and thickness
     * @param {Number} x - Top-left X coordinate
     * @param {Number} y - Top-left Y coordinate
     * @param {Number} w - Width
     * @param {Number} h - Height
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    drawRoundedRectangle(x, y, w, h, radiusX, radiusY, color, thickness := 1, rounded := 0) {
        if (w <= 0 || h <= 0) {
            throw Error("Invalid rectangle dimensions. Width and height must be positive.", -1)
        }
        
        if (radiusX <= 0 || radiusY <= 0) {
            throw Error("Invalid corner radius. Radius must be positive.", -1)
        }
        
        this._setBrushColor(color)
        
        ; Create rounded rectangle structure
        bf := D2D1Structs.D2D1_ROUNDED_RECT(x, y, x+w, y+h, radiusX, radiusY)
        
        DllCall(this._drawRoundedRectangle, "Ptr", this._renderTarget,
                "Ptr", bf,
                "ptr", this._brush,
                "float", thickness,
                "ptr", (rounded ? this._strokeRounded : this._stroke))
    }
    
    /**
     * Fill a rounded rectangle with the specified color
     * @param {Number} x - Top-left X coordinate
     * @param {Number} y - Top-left Y coordinate
     * @param {Number} w - Width
     * @param {Number} h - Height
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    fillRoundedRectangle(x, y, w, h, radiusX, radiusY, color) {
        if (w <= 0 || h <= 0) {
            throw Error("Invalid rectangle dimensions. Width and height must be positive.", -1)
        }
        
        if (radiusX <= 0 || radiusY <= 0) {
            throw Error("Invalid corner radius. Radius must be positive.", -1)
        }
        
        this._setBrushColor(color)
        
        ; Create rounded rectangle structure
        bf := D2D1Structs.D2D1_ROUNDED_RECT(x, y, x+w, y+h, radiusX, radiusY)
        
        DllCall(this._fillRoundedRectangle, "Ptr", this._renderTarget,
                "Ptr", bf,
                "ptr", this._brush)
    }
    
    /**
     * Draw a line with the specified color and thickness
     * @param {Number} x1 - Start X coordinate
     * @param {Number} y1 - Start Y coordinate
     * @param {Number} x2 - End X coordinate
     * @param {Number} y2 - End Y coordinate
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    drawLine(x1, y1, x2, y2, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        if (thickness <= 0) {
            throw Error("Invalid line thickness. Thickness must be positive.", -1)
        }
        
        this._setBrushColor(color)
        bf := D2D1Structs.D2D_POINT_2F(x1, y1, x2, y2)
        
        if (this._is64Bit) {
            DllCall(this._drawLine, "Ptr", this._renderTarget, 
                    "Double", NumGet(bf, 0, "double"), 
                    "Double", NumGet(bf, 8, "double"), 
                    "ptr", this._brush, 
                    "float", thickness, 
                    "ptr", (rounded ? this._strokeRounded : this._stroke))
        } else {
            DllCall(this._drawLine, "Ptr", this._renderTarget, 
                    "float", x1, "float", y1, 
                    "float", x2, "float", y2, 
                    "ptr", this._brush, 
                    "float", thickness, 
                    "ptr", (rounded ? this._strokeRounded : this._stroke))
        }
    }
    
    /**
     * Draw a polygon outline with the specified color
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded corners
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     * @returns {Integer} 1 if successful, 0 otherwise
     */
    drawPolygon(points, color, thickness := 1, rounded := 0, xOffset := 0, yOffset := 0) {
        if (points.Length < 3) {
            throw Error("Invalid polygon. At least 3 points are required.", -1)
        }
        
        pGeom := sink := 0
        
        ; Create path geometry
        if (DllCall(this._vTable(this._factory, 10), "Ptr", this._factory, "Ptr*", &pGeom) != 0) {
            throw Error("Failed to create path geometry. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        ; Open geometry sink
        if (DllCall(this._vTable(pGeom, 17), "Ptr", pGeom, "Ptr*", &sink) != 0) {
            DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)  ; Release geometry
            throw Error("Failed to open geometry sink. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        ; Set brush color
        this._setBrushColor(color)
        
        try {
            ; Begin figure
            if (this._is64Bit) {
                bf := D2D1Structs.D2D1_POINT_2F_SINGLE(points[1][1] + xOffset, points[1][2] + yOffset)
                if (DllCall(this._vTable(sink, 5), "ptr", sink, "double", NumGet(bf, 0, "double"), "uint", 1) != 0) {
                    throw Error("Failed to begin figure. Error: " DllCall("GetLastError", "uint"), -1)
                }
                
                ; Add lines
                loop points.Length - 1 {
                    bf := D2D1Structs.D2D1_POINT_2F_SINGLE(points[A_Index + 1][1] + xOffset, points[A_Index + 1][2] + yOffset)
                    if (DllCall(this._vTable(sink, 10), "ptr", sink, "double", NumGet(bf, 0, "double")) != 0) {
                        throw Error("Failed to add line. Error: " DllCall("GetLastError", "uint"), -1)
                    }
                }
            } else {
                ; Begin figure
                if (DllCall(this._vTable(sink, 5), "ptr", sink,
                        "float", points[1][1] + xOffset,
                        "float", points[1][2] + yOffset, "uint", 1) != 0) {
                    throw Error("Failed to begin figure. Error: " DllCall("GetLastError", "uint"), -1)
                }
                
                ; Add lines
                loop points.Length - 1 {
                    if (DllCall(this._vTable(sink, 10), "ptr", sink,
                            "float", points[A_Index + 1][1] + xOffset,
                            "float", points[A_Index + 1][2] + yOffset) != 0) {
                        throw Error("Failed to add line. Error: " DllCall("GetLastError", "uint"), -1)
                    }
                }
            }
            
            ; End figure
            if (DllCall(this._vTable(sink, 8), "ptr", sink, "uint", 1) != 0) {
                throw Error("Failed to end figure. Error: " DllCall("GetLastError", "uint"), -1)
            }
            
            ; Close sink
            if (DllCall(this._vTable(sink, 9), "ptr", sink) != 0) {
                throw Error("Failed to close sink. Error: " DllCall("GetLastError", "uint"), -1)
            }
            
            ; Draw geometry
            if (DllCall(this._vTable(this._renderTarget, 22), "Ptr", this._renderTarget,
                        "Ptr", pGeom, "ptr", this._brush, "float", thickness,
                        "ptr", (rounded ? this._strokeRounded : this._stroke)) != 0) {
                throw Error("Failed to draw geometry. Error: " DllCall("GetLastError", "uint"), -1)
            }
            
            return 1
        } catch as e {
            ; Clean up resources in case of error
            if (sink)
                DllCall(this._vTable(sink, 2), "ptr", sink)
            if (pGeom)
                DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)
            throw e
        }
        
        ; Clean up resources
        if (sink)
            DllCall(this._vTable(sink, 2), "ptr", sink)
        if (pGeom)
            DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)
        
        return 1
    }
    
    /**
     * Fill a polygon with the specified color
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     * @returns {Integer} 1 if successful, 0 otherwise
     */
    fillPolygon(points, color, xOffset := 0, yOffset := 0) {
        if (points.Length < 3) {
            throw Error("Invalid polygon. At least 3 points are required.", -1)
        }
        
        pGeom := sink := 0
        
        ; Create path geometry
        if (DllCall(this._vTable(this._factory, 10), "Ptr", this._factory, "Ptr*", &pGeom) != 0) {
            throw Error("Failed to create path geometry. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        ; Open geometry sink
        if (DllCall(this._vTable(pGeom, 17), "Ptr", pGeom, "Ptr*", &sink) != 0) {
            DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)  ; Release geometry
            throw Error("Failed to open geometry sink. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        ; Set brush color
        this._setBrushColor(color)
        
        try {
            ; Begin figure
            if (this._is64Bit) {
                bf := D2D1Structs.D2D1_POINT_2F_SINGLE(points[1][1] + xOffset, points[1][2] + yOffset)
                if (DllCall(this._vTable(sink, 5), "ptr", sink, "double", NumGet(bf, 0, "double"), "uint", 0) != 0) {
                    throw Error("Failed to begin figure. Error: " DllCall("GetLastError", "uint"), -1)
                }
                
                ; Add lines
                loop points.Length - 1 {
                    bf := D2D1Structs.D2D1_POINT_2F_SINGLE(points[A_Index + 1][1] + xOffset, points[A_Index + 1][2] + yOffset)
                    if (DllCall(this._vTable(sink, 10), "ptr", sink, "double", NumGet(bf, 0, "double")) != 0) {
                        throw Error("Failed to add line. Error: " DllCall("GetLastError", "uint"), -1)
                    }
                }
            } else {
                ; Begin figure
                if (DllCall(this._vTable(sink, 5), "ptr", sink,
                        "float", points[1][1] + xOffset,
                        "float", points[1][2] + yOffset, "uint", 0) != 0) {
                    throw Error("Failed to begin figure. Error: " DllCall("GetLastError", "uint"), -1)
                }
                
                ; Add lines
                loop points.Length - 1 {
                    if (DllCall(this._vTable(sink, 10), "ptr", sink,
                            "float", points[A_Index + 1][1] + xOffset,
                            "float", points[A_Index + 1][2] + yOffset) != 0) {
                        throw Error("Failed to add line. Error: " DllCall("GetLastError", "uint"), -1)
                    }
                }
            }
            
            ; End figure
            if (DllCall(this._vTable(sink, 8), "ptr", sink, "uint", 1) != 0) {
                throw Error("Failed to end figure. Error: " DllCall("GetLastError", "uint"), -1)
            }
            
            ; Close sink
            if (DllCall(this._vTable(sink, 9), "ptr", sink) != 0) {
                throw Error("Failed to close sink. Error: " DllCall("GetLastError", "uint"), -1)
            }
            
            ; Fill geometry
            if (DllCall(this._vTable(this._renderTarget, 23), "Ptr", this._renderTarget,
                        "Ptr", pGeom, "ptr", this._brush, "ptr", 0) != 0) {
                throw Error("Failed to fill geometry. Error: " DllCall("GetLastError", "uint"), -1)
            }
            
            return 1
        } catch as e {
            ; Clean up resources in case of error
            if (sink)
                DllCall(this._vTable(sink, 2), "ptr", sink)
            if (pGeom)
                DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)
            throw e
        }
        
        ; Clean up resources
        if (sink)
            DllCall(this._vTable(sink, 2), "ptr", sink)
        if (pGeom)
            DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)
        
        return 1
    }
    
 
    ; Font cache
    _fonts := Map()
    _maxFontCacheSize := 50  ; Maximum number of fonts to cache
    
    /**
     * Cache a font for reuse
     * @param {String} fontName - Font family name
     * @param {Number} fontSize - Font size
     * @returns {Pointer} Text format pointer
     * @private
     */
    _cacheFont(fontName, fontSize) {
        ; Create text format
        pTextFormat := 0
        
        ; Create text format using the factory's CreateTextFormat method
        if (DllCall(this._vTable(this._wFactory, 15), "Ptr", this._wFactory,
                    "WStr", fontName, "Ptr", 0, "uint", 400, "uint", 0,
                    "uint", 5, "float", fontSize, "WStr", "en-us", "Ptr*", &pTextFormat) != 0) {
            throw Error("Failed to create text format. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        ; Check if we need to remove old fonts from the cache
        if (this._fonts.Count >= this._maxFontCacheSize) {
            ; Remove the oldest font (first one in the map)
            oldestKey := ""
            for key in this._fonts {
                oldestKey := key
                break
            }
            
            if (oldestKey != "") {
                ; Release the resource
                this._resourceManager.releaseResource("Font_" oldestKey)
                ; Remove from cache
                this._fonts.Delete(oldestKey)
            }
        }
        
        ; Store the font in the cache
        this._fonts[fontName fontSize] := pTextFormat
        this._resourceManager.addResource("Font_" fontName fontSize, pTextFormat, this._vTable(pTextFormat, 2))
        
        return pTextFormat
    }
    
    /**
     * Create a text format (font)
     * @param {String} fontFamily - Font family name (e.g., "Arial")
     * @param {Number} fontSize - Font size in points
     * @param {String} fontWeight - Font weight ("normal", "bold", "light", "black", etc.)
     * @param {String} fontStyle - Font style ("normal", "italic", "oblique")
     * @param {String} formatName - Name to reference this format later (optional)
     * @returns {Pointer} Text format pointer
     */
    createTextFormat(fontFamily, fontSize, fontWeight := "normal", fontStyle := "normal", formatName := "") {
        ; Convert font weight string to numeric value
        weightMap := Map(
            "thin", 100,
            "extralight", 200,
            "light", 300,
            "normal", 400,
            "regular", 400,
            "medium", 500,
            "semibold", 600,
            "bold", 700,
            "extrabold", 800,
            "black", 900
        )
        
        weight := weightMap.Has(fontWeight) ? weightMap[fontWeight] : 400
        
        ; Convert font style string to numeric value
        styleMap := Map(
            "normal", 0,  ; DWRITE_FONT_STYLE_NORMAL
            "italic", 2,  ; DWRITE_FONT_STYLE_ITALIC
            "oblique", 1  ; DWRITE_FONT_STYLE_OBLIQUE
        )
        
        style := styleMap.Has(fontStyle) ? styleMap[fontStyle] : 0
        
        ; Create text format
        pTextFormat := 0
        
        ; Create text format using the factory's CreateTextFormat method
        if (DllCall(this._vTable(this._wFactory, 15), "Ptr", this._wFactory,
                    "WStr", fontFamily, "Ptr", 0, "uint", weight, "uint", style,
                    "uint", 5, "float", fontSize, "WStr", "en-us", "Ptr*", &pTextFormat) != 0) {
            throw Error("Failed to create text format. Error: " DllCall("GetLastError", "uint"), -1)
        }
        
        ; Store the text format if a name is provided
        if (formatName != "") {
            this._textFormats[formatName] := pTextFormat
            this._resourceManager.addResource("TextFormat_" formatName, pTextFormat, this._vTable(pTextFormat, 2))
        }
        
        return pTextFormat
    }
    
    ; These methods are no longer needed as the functionality is integrated into drawText
    
    /**
     * Draw text on the canvas with advanced options
     * @param {String} text - Text to draw
     * @param {Number} x - X position
     * @param {Number} y - Y position
     * @param {Number} size - Font size
     * @param {Integer} color - Text color in 0xAARRGGBB or 0xRRGGBB format
     * @param {String} fontName - Font family name
     * @param {String} extraOptions - Additional options for text rendering
     *                              w[number] - Width
     *                              h[number] - Height
     *                              a[Left/Right/Center] - Alignment
     *                              ds[hex color] - Drop shadow color
     *                              dsx[number] - Drop shadow X offset
     *                              dsy[number] - Drop shadow Y offset
     *                              ol[hex color] - Outline color
     */
    drawText(text, x, y, size := 18, color := 0xFFFFFFFF, fontName := "Arial", extraOptions := "") {
        local w, h, ds, dsx, dsy, ol
        
        ; Parse width and height from options or use defaults
        w := (RegExMatch(extraOptions, "w([\d\.]+)", &w) ? w[1] : this.width)
        h := (RegExMatch(extraOptions, "h([\d\.]+)", &h) ? h[1] : this.height)
        
        ; Set brush color for text
        this._setBrushColor(color)
        
        ; Get or create text format for the specified font and size
        textFormat := this._fonts.Has(fontName size) ? this._fonts[fontName size] : this._cacheFont(fontName, size)
        
        ; Set text alignment based on options
        if (InStr(extraOptions, "aRight"))
            DllCall(this._vTable(textFormat, 3), "ptr", textFormat, "uint", 1)  ; DWRITE_TEXT_ALIGNMENT_TRAILING
        else if (InStr(extraOptions, "aCenter"))
            DllCall(this._vTable(textFormat, 3), "ptr", textFormat, "uint", 2)  ; DWRITE_TEXT_ALIGNMENT_CENTER
        else
            DllCall(this._vTable(textFormat, 3), "ptr", textFormat, "uint", 0)  ; DWRITE_TEXT_ALIGNMENT_LEADING
        
        ; Create layout rectangle
        bf := D2D1Structs.D2D_RECT_F(x, y, x + w, y + h)
        
        ; Handle special effects
        if (RegExMatch(extraOptions, "ds([a-fA-F\d]+)", &ds)) {
            ; Draw drop shadow
            dsx := (RegExMatch(extraOptions, "dsx([\d\.]+)", &dsx) ? dsx[1] : 1)
            dsy := (RegExMatch(extraOptions, "dsy([\d\.]+)", &dsy) ? dsy[1] : 1)
            
            ; Draw shadow text
            this._setBrushColor("0x" ds[1])
            shadowBf := D2D1Structs.D2D_RECT_F(x + dsx, y + dsy, x + w + dsx, y + h + dsy)
            
            DllCall(this._drawText, "Ptr", this._renderTarget,
                    "WStr", text, "uint", StrLen(text),
                    "Ptr", textFormat, "Ptr", shadowBf,
                    "Ptr", this._brush, "uint", 0, "uint", 0)
            
            ; Reset color for main text
            this._setBrushColor(color)
        } else if (RegExMatch(extraOptions, "ol([a-fA-F\d]+)", &ol)) {
            ; Draw outline
            this._setBrushColor("0x" ol[1])
            
            ; Draw text at multiple offsets to create outline effect
            offsets := [[0, -1], [1, 0], [0, 1], [-1, 0]]
            
            for offset in offsets {
                outlineBf := D2D1Structs.D2D_RECT_F(x + offset[1], y + offset[2], x + w + offset[1], y + h + offset[2])
                
                DllCall(this._drawText, "Ptr", this._renderTarget,
                        "WStr", text, "uint", StrLen(text),
                        "Ptr", textFormat, "Ptr", outlineBf,
                        "Ptr", this._brush, "uint", 0, "uint", 0)
            }
            
            ; Reset color for main text
            this._setBrushColor(color)
        }
        
        ; Draw main text
        DllCall(this._drawText, "Ptr", this._renderTarget,
                "WStr", text, "uint", StrLen(text),
                "Ptr", textFormat, "Ptr", bf,
                "Ptr", this._brush, "uint", 0, "uint", 0)
    }
    
    /**
     * End drawing operations
     */
    endDraw() {
        local pOut := 0
        
        if (this._drawing)
            DllCall(this._endDraw, "Ptr", this._renderTarget, "Ptr*", &pOut, "Ptr*", &pOut)
    }
    
    /**
     * Clear the canvas
     */
    clear() {
        local pOut := 0
        
        DllCall(this._beginDraw, "Ptr", this._renderTarget)
        DllCall(this._clear, "Ptr", this._renderTarget, "Ptr", this._clrPtr)
        DllCall(this._endDraw, "Ptr", this._renderTarget, "Ptr*", &pOut, "Ptr*", &pOut)
    }
    
    /**
     * Get a method pointer from a COM object's virtual table
     * @param {Pointer} object - COM object
     * @param {Integer} methodIndex - Method index in the virtual table
     * @returns {Pointer} Method pointer
     * @private
     */
    _vTable(object, methodIndex) {
        return NumGet(NumGet(object + 0, 0, "ptr"), methodIndex * A_PtrSize, "Ptr")
    }
    
    /**
     * Create a GUID from a string
     * @param {String} guidStr - GUID string
     * @param {Pointer} clsidFactory - Output buffer for the GUID
     * @private
     */
    _createGuid(guidStr, &clsidFactory) {
        clsidFactory := Buffer(16, 0)
        DllCall("ole32\CLSIDFromString", "WStr", guidStr, "Ptr", clsidFactory)
    }
    
    /**
     * Set the brush color
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @returns {Integer} 1 if color was changed, 0 otherwise
     * @private
     */
    _setBrushColor(color) {
        static lastCol := 0
        
        if (color <= 0xFFFFFF)
            color += 0xFF000000
        
        if (color != lastCol) {
            this._colPtr := D2D1Structs.D2D1_COLOR_F(color)
            DllCall(this._setBrush, "Ptr", this._brush, "Ptr", this._colPtr)
            lastCol := color
            return 1
        }
        
        return 0
    }
    
    /**
     * Handle WM_ERASEBKGND message
     * @param {Integer} wParam - wParam
     * @param {Integer} lParam - lParam
     * @param {Integer} msg - Message
     * @param {Integer} hwnd - Window handle
     * @returns {Integer} 0 to prevent default handling
     * @private
     */
    onErase(wParam, lParam, msg, hwnd) {

        if (hwnd = this.hwnd)
            return 0
    }
    

    /**
     * Explicit cleanup method - Call this before exiting your application
     * for reliable resource cleanup
     */
    cleanup() {

        
        ; First check if we're still drawing
        if (this._drawing) {
            this.endDraw()
            this._drawing := 0

        }
        
        ; Shutdown GDI+
        DllCall("gdiplus\GdiplusShutdown", "Ptr*", this._gdiplusToken)
        
        ; Release all resources
        this._resourceManager.releaseAll()
        
        ; Remove message handler
        OnMessage(0x14, this._onEraseFunc, 0)
    }
}

/**
 * Resource manager for Direct2D resources
 */
class D2D1ResourceManager {
    _resources := Map()
    
    /**
     * Add a resource to the manager
     * @param {String} name - Resource name
     * @param {Pointer} resource - Resource pointer
     * @param {Pointer} releaseMethod - Release method pointer
     */
    addResource(name, resource, releaseMethod) {
        this._resources[name] := {resource: resource, releaseMethod: releaseMethod}
    }
    
    /**
     * Get a resource by name
     * @param {String} name - Resource name
     * @returns {Pointer} Resource pointer or 0 if not found
     */
    getResource(name) {
        return this._resources.Has(name) ? this._resources[name].resource : 0
    }
    
    /**
     * Release a resource by name
     * @param {String} name - Resource name
     */
    releaseResource(name) {

        if (this._resources.Has(name)) {
            DllCall(this._resources[name].releaseMethod, "Ptr", this._resources[name].resource)
            this._resources.Delete(name)
        }
    }
    
    /**
     * Release all resources
     */
    releaseAll() {

        for name, resourceInfo in this._resources {
            DllCall(resourceInfo.releaseMethod, "Ptr", resourceInfo.resource)
        }
        this._resources.Clear()
    }
}


/**
 * Scene graph for managing multiple shapes
 */
class D2D1Scene {
    _shapes := []
    
    /**
     * Add a shape to the scene
     * @param {D2D1Shape} shape - Shape to add
     */
    addShape(shape) {
        this._shapes.Push(shape)
    }
    
    /**
     * Remove a shape from the scene
     * @param {Integer} index - Shape index
     */
    removeShape(index) {
        this._shapes.RemoveAt(index)
    }
    
    /**
     * Draw all shapes in the scene
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.beginDraw()
        
        for shape in this._shapes {
            shape.draw(d2d)
        }
        
        d2d.endDraw()
    }
}
