#Requires AutoHotkey v2.0


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
    /**
     * Create a D2D1_HWND_RENDER_TARGET_PROPERTIES structure
     * @param {Integer} hwnd - Window handle
     * @param {Integer} width - Width
     * @param {Integer} height - Height
     * @param {Integer} D2D1_PRESENT_OPTIONS - Present options:
     *                                        0 = D2D1_PRESENT_OPTIONS_NONE (VSync enabled)
     *                                        2 = D2D1_PRESENT_OPTIONS_IMMEDIATELY (VSync disabled)
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