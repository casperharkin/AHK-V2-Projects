#Requires AutoHotkey v2.0
#SingleInstance Force

/**
 * Direct2D Wrapper for AutoHotkey v2
 * Based on Spawnova's Direct2D overlay class: https://github.com/Spawnova/ShinsOverlayClass
 * 
 * This class provides an object-oriented interface to the Windows Direct2D API,
 * simplifying the creation of hardware-accelerated 2D graphics in AutoHotkey v2 applications.
 */

/**
 * Example usage of the D2D1 class
 */
if (A_ScriptName = "d2d1.ahk") {
    ; Create GUI window
    myGui := Gui(" +Alwaysontop +Resize", "D2D1 Example")
    
    ; Initialize D2D1 instance
    d2d := D2D1(myGui.hwnd, x := 100, y := 100, width := 800, height := 600)
    
    ; Set up drawing timer
    SetTimer(DrawExample.Bind(d2d), 40)
    
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
    
    ; Hotkeys
    Hotkey "F9", (*) => Reload()
    Hotkey "Escape", (*) => ExitApp()
    
    return
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
    _drawImage := 0
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
     * @returns {D2D1} - D2D1 instance
     */
    __New(hwnd, x := 100, y := 100, width := 800, height := 600) {
        ; Initialize resource manager
        this._resourceManager := D2D1ResourceManager()
        
        ; Initialize basic properties
        this._is64Bit := (A_PtrSize == 8)
        this.width := width
        this.height := height
        this.hwnd := hwnd
        
        ; Load required DLLs
        this._loadRequiredLibraries()
        
        ; Initialize GDI+
        this._initializeGdiPlus()
        
        ; Create Direct2D factory
        this._createFactory()
        
        ; Show the GUI window
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
        
        D2D1_HWND_RENDER_TARGET_PROPERTIES := D2D1Structs.D2D1_HWND_RENDER_TARGET_PROPERTIES(
            this.hwnd, this.width, this.height
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
        
        ; Enable anti-aliasing
        DllCall(this._vTable(this._renderTarget, 32), "Ptr", this._renderTarget, "Uint", 0)
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
        this._drawImage := this._vTable(this._renderTarget, 26)
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
            newSize := Buffer(16, 0)
            NumPut("uint", this.width := w, newSize, 0)
            NumPut("uint", this.height := h, newSize, 4)
            DllCall(this._nrSize, "Ptr", this._renderTarget, "ptr", newSize)
        }
        
        DllCall("MoveWindow", "Uptr", this.hwnd, "int", x, "int", y, 
                "int", this.width, "int", this.height, "char", 1)
    }
    
    /**
     * Begin drawing operations
     * @returns {Integer} 1 if successful, 0 otherwise
     */
    beginDraw() {
        local pOut := 0, GetWindowRectResult := this.hwnd
        
        if (!DllCall("GetWindowRect", "Uptr", GetWindowRectResult, "ptr", this._D2D1_STROKE_STYLE_PROPERTIES)) {
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
        
        if (DllCall(this._vTable(this._factory, 10), "Ptr", this._factory, "Ptr*", &pGeom) = 0) {
            if (DllCall(this._vTable(pGeom, 17), "Ptr", pGeom, "Ptr*", &sink) = 0) {
                this._setBrushColor(color)
                
                if (this._is64Bit) {
                    bf := Buffer(64)
                    NumPut("float", points[1][1] + xOffset, bf, 0)
                    NumPut("float", points[1][2] + yOffset, bf, 4)
                    DllCall(this._vTable(sink, 5), "ptr", sink, "double", NumGet(bf, 0, "double"), "uint", 0)
                    
                    loop points.Length - 1 {
                        NumPut("float", points[A_Index + 1][1] + xOffset, bf, 0)
                        NumPut("float", points[A_Index + 1][2] + yOffset, bf, 4)
                        DllCall(this._vTable(sink, 10), "ptr", sink, "double", NumGet(bf, 0, "double"))
                    }
                    
                    DllCall(this._vTable(sink, 8), "ptr", sink, "uint", 1)
                    DllCall(this._vTable(sink, 9), "ptr", sink)
                } else {
                    DllCall(this._vTable(sink, 5), "ptr", sink,
                            "float", points[1][1] + xOffset,
                            "float", points[1][2] + yOffset, "uint", 0)
                    
                    loop points.Length - 1
                        DllCall(this._vTable(sink, 10), "ptr", sink,
                                "float", points[A_Index + 1][1] + xOffset,
                                "float", points[A_Index + 1][2] + yOffset)
                    
                    DllCall(this._vTable(sink, 8), "ptr", sink, "uint", 1)
                    DllCall(this._vTable(sink, 9), "ptr", sink)
                }
                
                if (DllCall(this._vTable(this._renderTarget, 23), "Ptr", this._renderTarget,
                            "Ptr", pGeom, "ptr", this._brush, "ptr", 0) = 0) {
                    DllCall(this._vTable(sink, 2), "ptr", sink)
                    DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)
                    return 1
                }
                
                DllCall(this._vTable(sink, 2), "ptr", sink)
                DllCall(this._vTable(pGeom, 2), "Ptr", pGeom)
            }
        }
        
        return 0
    }
    ; Font cache
    _fonts := Map()
    
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
    
    ; GDI+ objects for text rendering
    _gdipBrush := 0
    _gdipFont := Map()
    _gdipStringFormat := 0
    
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
        bf := Buffer(16)
        NumPut("float", x, bf, 0)
        NumPut("float", y, bf, 4)
        NumPut("float", x + w, bf, 8)
        NumPut("float", y + h, bf, 12)
        
        ; Handle special effects
        if (RegExMatch(extraOptions, "ds([a-fA-F\d]+)", &ds)) {
            ; Draw drop shadow
            dsx := (RegExMatch(extraOptions, "dsx([\d\.]+)", &dsx) ? dsx[1] : 1)
            dsy := (RegExMatch(extraOptions, "dsy([\d\.]+)", &dsy) ? dsy[1] : 1)
            
            ; Draw shadow text
            this._setBrushColor("0x" ds[1])
            shadowBf := Buffer(16)
            NumPut("float", x + dsx, shadowBf, 0)
            NumPut("float", y + dsy, shadowBf, 4)
            NumPut("float", x + w + dsx, shadowBf, 8)
            NumPut("float", y + h + dsy, shadowBf, 12)
            
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
                outlineBf := Buffer(16)
                NumPut("float", x + offset[1], outlineBf, 0)
                NumPut("float", y + offset[2], outlineBf, 4)
                NumPut("float", x + w + offset[1], outlineBf, 8)
                NumPut("float", y + h + offset[2], outlineBf, 12)
                
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
            NumPut("Float", ((color & 0xFF0000) >> 16) / 255, this._colPtr, 0)
            NumPut("Float", ((color & 0xFF00) >> 8) / 255, this._colPtr, 4)
            NumPut("Float", ((color & 0xFF)) / 255, this._colPtr, 8)
            NumPut("Float", (color > 0xFFFFFF ? ((color & 0xFF000000) >> 24) / 255 : 1), this._colPtr, 12)
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
     * Destructor - Clean up resources
     */
    __Delete() {
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
 * Structure definitions for Direct2D
 */
class D2D1Structs {
    /**
     * Create a MARGINS structure
     * @param {Integer} cxLeftWidth - Left width
     * @param {Integer} cxRightWidth - Right width
     * @param {Integer} cyTopHeight - Top height
     * @param {Integer} cyBottomHeight - Bottom height
     * @returns {Buffer} MARGINS structure
     */
    static _MARGINS(cxLeftWidth := -1, cxRightWidth := -1, cyTopHeight := -1, cyBottomHeight := -1) {
        local marg := Buffer(16, 0)
        NumPut("int", cxLeftWidth, marg, 0)
        NumPut("int", cxRightWidth, marg, 4)
        NumPut("int", cyTopHeight, marg, 8)
        NumPut("int", cyBottomHeight, marg, 12)
        return marg
    }
    
    /**
     * Create a D2D_POINT_2F structure
     * @param {Number} x1 - First X coordinate
     * @param {Number} y1 - First Y coordinate
     * @param {Number} x2 - Second X coordinate
     * @param {Number} y2 - Second Y coordinate
     * @returns {Buffer} D2D_POINT_2F structure
     */
    static D2D_POINT_2F(x1, y1, x2, y2) {
        bf := Buffer(64)
        NumPut("float", x1, bf, 0)
        NumPut("float", y1, bf, 4)
        NumPut("float", x2, bf, 8)
        NumPut("float", y2, bf, 12)
        return bf
    }
    
    /**
     * Create a GdiplusStartupInput structure
     * @param {Integer} GdiplusVersion - GDI+ version
     * @returns {Buffer} GdiplusStartupInput structure
     */
    static gdiplusStartupInput(GdiplusVersion := 1) {
        local inPtr := Buffer(8 + 2 * A_PtrSize, 0)
        NumPut("UInt", GdiplusVersion, inPtr, 0)
        return inPtr
    }
    
    /**
     * Create a D2D1_RENDER_TARGET_PROPERTIES structure
     * @param {Integer} D2D1_RENDER_TARGET_TYPE - Render target type
     * @param {Integer} DXGI_FORMAT - DXGI format
     * @param {Integer} D2D1_ALPHA_MODE - Alpha mode
     * @param {Number} dpiX - Horizontal DPI
     * @param {Number} dpiY - Vertical DPI
     * @param {Integer} D2D1_RENDER_TARGET_USAGE - Render target usage
     * @param {Integer} D2D1_FEATURE_LEVEL - Feature level
     * @returns {Buffer} D2D1_RENDER_TARGET_PROPERTIES structure
     */
    static D2D1_RENDER_TARGET_PROPERTIES(D2D1_RENDER_TARGET_TYPE := 0, DXGI_FORMAT := 0, 
                                         D2D1_ALPHA_MODE := 1, dpiX := 96, dpiY := 96, 
                                         D2D1_RENDER_TARGET_USAGE := 0, D2D1_FEATURE_LEVEL := 0) {
        local rtPtr := Buffer(28, 0)
        NumPut("uint", D2D1_RENDER_TARGET_TYPE, rtPtr, 0)
        NumPut("uint", DXGI_FORMAT, rtPtr, 4)
        NumPut("uint", D2D1_ALPHA_MODE, rtPtr, 8)
        NumPut("float", dpiX, rtPtr, 12)
        NumPut("float", dpiY, rtPtr, 16)
        NumPut("uint", D2D1_RENDER_TARGET_USAGE, rtPtr, 20)
        NumPut("uint", D2D1_FEATURE_LEVEL, rtPtr, 24)
        return rtPtr
    }
    
    /**
     * Create a D2D1_HWND_RENDER_TARGET_PROPERTIES structure
     * @param {Integer} hwnd - Window handle
     * @param {Integer} width - Width
     * @param {Integer} height - Height
     * @param {Integer} D2D1_PRESENT_OPTIONS - Present options
     * @returns {Buffer} D2D1_HWND_RENDER_TARGET_PROPERTIES structure
     */
    static D2D1_HWND_RENDER_TARGET_PROPERTIES(hwnd := 0, width := 0, height := 0, D2D1_PRESENT_OPTIONS := 0) {
        local size := A_PtrSize + 12
        local hrtPtr := Buffer(size, 0)
        NumPut("UPtr", hwnd, hrtPtr, 0)
        NumPut("uint", width, hrtPtr, A_PtrSize)
        NumPut("uint", height, hrtPtr, A_PtrSize + 4)
        NumPut("uint", D2D1_PRESENT_OPTIONS, hrtPtr, A_PtrSize + 8)
        return hrtPtr
    }
    
    /**
     * Create a D2D1_MATRIX_3X2_F structure
     * @param {Number} M11 - Scaling X
     * @param {Number} M12 - Shear Y
     * @param {Number} M21 - Shear X
     * @param {Number} M22 - Scaling Y
     * @param {Number} Dx - Translation X
     * @param {Number} Dy - Translation Y
     * @returns {Buffer} D2D1_MATRIX_3X2_F structure
     */
    static D2D1_MATRIX_3X2_F(M11 := 1, M12 := 0, M21 := 0, M22 := 1, Dx := 0, Dy := 0) {
        local mat := Buffer(24, 0)
        NumPut("float", M11, mat, 0)
        NumPut("float", M12, mat, 4)
        NumPut("float", M21, mat, 8)
        NumPut("float", M22, mat, 12)
        NumPut("float", Dx, mat, 16)
        NumPut("float", Dy, mat, 20)
        return mat
    }
    
    /**
     * Create a D2D1_STROKE_STYLE_PROPERTIES structure
     * @param {Integer} StartCap - Start cap style
     * @param {Integer} EndCap - End cap style
     * @param {Integer} DashCap - Dash cap style
     * @param {Integer} LineJoin - Line join style
     * @param {Number} MiterLimit - Miter limit
     * @param {Integer} DashStyle - Dash style
     * @param {Number} DashOffset - Dash offset
     * @returns {Buffer} D2D1_STROKE_STYLE_PROPERTIES structure
     */
    static D2D1_STROKE_STYLE_PROPERTIES(StartCap := 2, EndCap := 2, DashCap := 0, 
                                        LineJoin := 2, MiterLimit := 255, 
                                        DashStyle := 0, DashOffset := 0) {
        local size := 28
        local ptr := Buffer(size, 0)
        NumPut("uint", StartCap, ptr, 0)
        NumPut("uint", EndCap, ptr, 4)
        NumPut("uint", DashCap, ptr, 8)
        NumPut("uint", LineJoin, ptr, 12)
        NumPut("float", MiterLimit, ptr, 16)
        NumPut("uint", DashStyle, ptr, 20)
        NumPut("float", DashOffset, ptr, 24)
        return ptr
    }
    
    /**
     * Create a D2D_RECT_F structure
     * @param {Number} left - Left coordinate
     * @param {Number} top - Top coordinate
     * @param {Number} right - Right coordinate
     * @param {Number} bottom - Bottom coordinate
     * @returns {Buffer} D2D_RECT_F structure
     */
    static D2D_RECT_F(left := 0, top := 0, right := 0, bottom := 0) {
        local rect := Buffer(16, 0)
        NumPut("float", left, rect, 0)
        NumPut("float", top, rect, 4)
        NumPut("float", right, rect, 8)
        NumPut("float", bottom, rect, 12)
        return rect
    }
}

/**
 * Base class for all shapes
 */
class D2D1Shape {
    _x := 0
    _y := 0
    _color := 0xFFFFFFFF
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, color := 0xFFFFFFFF) {
        this._x := x
        this._y := y
        this._color := color
    }
    
    /**
     * Draw the shape
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        ; To be implemented by derived classes
    }
    
    /**
     * Move the shape
     * @param {Number} dx - X offset
     * @param {Number} dy - Y offset
     */
    move(dx, dy) {
        this._x += dx
        this._y += dy
    }
    
    /**
     * Set the shape color
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    setColor(color) {
        this._color := color
    }
}

/**
 * Rectangle shape
 */
class D2D1Rectangle extends D2D1Shape {
    _width := 0
    _height := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, width, height, color := 0xFFFFFFFF) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
    }
    
    /**
     * Draw the rectangle
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.fillRectangle(this._x, this._y, this._width, this._height, this._color)
    }
}

/**
 * Circle shape
 */
class D2D1Circle extends D2D1Shape {
    _radius := 0
    
    /**
     * Constructor
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radius - Radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, radius, color := 0xFFFFFFFF) {
        super.__New(x, y, color)
        this._radius := radius
    }
    
    /**
     * Draw the circle
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.fillCircle(this._x, this._y, this._radius, this._color)
    }
}

/**
 * Line shape
 */
class D2D1Line extends D2D1Shape {
    _x2 := 0
    _y2 := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x1 - Start X coordinate
     * @param {Number} y1 - Start Y coordinate
     * @param {Number} x2 - End X coordinate
     * @param {Number} y2 - End Y coordinate
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x1, y1, x2, y2, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x1, y1, color)
        this._x2 := x2
        this._y2 := y2
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the line
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.drawLine(this._x, this._y, this._x2, this._y2, this._color, this._thickness, this._rounded)
    }
}

/**
 * Polygon shape
 */
class D2D1Polygon extends D2D1Shape {
    _points := []
    _xOffset := 0
    _yOffset := 0
    
    /**
     * Constructor
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     */
    __New(points, color := 0xFFFFFFFF, xOffset := 0, yOffset := 0) {
        super.__New(0, 0, color)
        this._points := points
        this._xOffset := xOffset
        this._yOffset := yOffset
    }
    
    /**
     * Draw the polygon
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.fillPolygon(this._points, this._color, this._xOffset, this._yOffset)
    }
}

/**
 * Text shape
 */
class D2D1Text extends D2D1Shape {
    _text := ""
    _width := 0
    _height := 0
    _fontSize := 18
    _fontName := "Arial"
    _extraOptions := ""
    
    /**
     * Constructor
     * @param {String} text - Text content
     * @param {Number} x - X position
     * @param {Number} y - Y position
     * @param {Number} width - Width of text block
     * @param {Number} height - Height of text block
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {String} fontName - Font name
     * @param {String} alignment - Text alignment ("left", "center", "right")
     * @param {String} extraOptions - Additional options for text rendering
     */
    __New(text, x, y, width, height, color := 0xFF000000, fontName := "Arial",
          alignment := "left", extraOptions := "") {
        super.__New(x, y, color)
        this._text := text
        this._width := width
        this._height := height
        this._fontName := fontName
        
        ; Build extra options string
        this._extraOptions := "w" width " h" height
        
        ; Add alignment
        if (alignment = "center")
            this._extraOptions .= " aCenter"
        else if (alignment = "right")
            this._extraOptions .= " aRight"
            
        ; Add any additional options
        if (extraOptions)
            this._extraOptions .= " " extraOptions
    }
    
    /**
     * Draw the text
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.drawText(this._text, this._x, this._y, this._fontSize, this._color,
                    this._fontName, this._extraOptions)
    }
    
    /**
     * Set the text content
     * @param {String} text - New text content
     */
    setText(text) {
        this._text := text
    }
    
    /**
     * Set the font size
     * @param {Number} size - Font size
     */
    setFontSize(size) {
        this._fontSize := size
    }
    
    /**
     * Set the font name
     * @param {String} fontName - Font name
     */
    setFontName(fontName) {
        this._fontName := fontName
    }
    
    /**
     * Set the text alignment
     * @param {String} alignment - Text alignment ("left", "center", "right")
     */
    setAlignment(alignment) {
        ; Remove existing alignment options
        this._extraOptions := RegExReplace(this._extraOptions, "a(Left|Right|Center)", "")
        
        ; Add new alignment
        if (alignment = "center")
            this._extraOptions .= " aCenter"
        else if (alignment = "right")
            this._extraOptions .= " aRight"
    }
    
    /**
     * Add drop shadow effect
     * @param {Integer} color - Shadow color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     */
    addDropShadow(color, xOffset := 1, yOffset := 1) {
        ; Remove existing shadow options
        this._extraOptions := RegExReplace(this._extraOptions, "ds[a-fA-F\d]+ dsx[\d\.]+ dsy[\d\.]+", "")
        
        ; Add new shadow options
        colorHex := Format("{:X}", color)
        this._extraOptions .= " ds" colorHex " dsx" xOffset " dsy" yOffset
    }
    
    /**
     * Add outline effect
     * @param {Integer} color - Outline color in 0xAARRGGBB or 0xRRGGBB format
     */
    addOutline(color) {
        ; Remove existing outline options
        this._extraOptions := RegExReplace(this._extraOptions, "ol[a-fA-F\d]+", "")
        
        ; Add new outline options
        colorHex := Format("{:X}", color)
        this._extraOptions .= " ol" colorHex
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

; Hotkeys for the example
if (A_ScriptName = "d2d1.ahk") {
    F9::Reload()
    Escape::ExitApp()
}