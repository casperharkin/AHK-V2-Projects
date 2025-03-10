#Requires AutoHotkey v2.0

/**
 * Base class for all shapes
 */
class d2d1Shapes {
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
class D2D1Rectangle extends d2d1Shapes {
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
 * Outline Rectangle shape
 */
class D2D1OutlineRectangle extends d2d1Shapes {
    _width := 0
    _height := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x, y, width, height, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the rectangle outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.drawRectangle(this._x, this._y, this._width, this._height, this._color, this._thickness, this._rounded)
    }
}

/**
 * Rounded Rectangle shape
 */
class D2D1RoundedRectangle extends d2d1Shapes {
    _width := 0
    _height := 0
    _radiusX := 0
    _radiusY := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     */
    __New(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
        this._radiusX := radiusX
        this._radiusY := radiusY
    }
    
    /**
     * Draw the rounded rectangle
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.fillRoundedRectangle(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY, this._color)
    }
}

/**
 * Outline Rounded Rectangle shape
 */
class D2D1OutlineRoundedRectangle extends d2d1Shapes {
    _width := 0
    _height := 0
    _radiusX := 0
    _radiusY := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x - X coordinate
     * @param {Number} y - Y coordinate
     * @param {Number} width - Width
     * @param {Number} height - Height
     * @param {Number} radiusX - X radius of the rounded corners
     * @param {Number} radiusY - Y radius of the rounded corners
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x, y, color)
        this._width := width
        this._height := height
        this._radiusX := radiusX
        this._radiusY := radiusY
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the rounded rectangle outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.drawRoundedRectangle(this._x, this._y, this._width, this._height, this._radiusX, this._radiusY, this._color, this._thickness, this._rounded)
    }
}

/**
 * Circle shape
 */
class D2D1Circle extends d2d1Shapes {
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
 * Outline Circle shape
 */
class D2D1OutlineCircle extends d2d1Shapes {
    _radius := 0
    _thickness := 1
    _rounded := 0
    
    /**
     * Constructor
     * @param {Number} x - Center X coordinate
     * @param {Number} y - Center Y coordinate
     * @param {Number} radius - Radius
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded caps
     */
    __New(x, y, radius, color := 0xFFFFFFFF, thickness := 1, rounded := 0) {
        super.__New(x, y, color)
        this._radius := radius
        this._thickness := thickness
        this._rounded := rounded
    }
    
    /**
     * Draw the circle outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.drawCircle(this._x, this._y, this._radius, this._color, this._thickness, this._rounded)
    }
}

/**
 * Line shape
 */
class D2D1Line extends d2d1Shapes {
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
class D2D1Polygon extends d2d1Shapes {
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
 * Outline Polygon shape
 */
class D2D1OutlinePolygon extends d2d1Shapes {
    _points := []
    _thickness := 1
    _rounded := 0
    _xOffset := 0
    _yOffset := 0
    
    /**
     * Constructor
     * @param {Array} points - Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
     * @param {Integer} color - Color in 0xAARRGGBB or 0xRRGGBB format
     * @param {Number} thickness - Line thickness
     * @param {Boolean} rounded - Whether to use rounded corners
     * @param {Number} xOffset - X offset
     * @param {Number} yOffset - Y offset
     */
    __New(points, color := 0xFFFFFFFF, thickness := 1, rounded := 0, xOffset := 0, yOffset := 0) {
        super.__New(0, 0, color)
        this._points := points
        this._thickness := thickness
        this._rounded := rounded
        this._xOffset := xOffset
        this._yOffset := yOffset
    }
    
    /**
     * Draw the polygon outline
     * @param {D2D1} d2d - D2D1 instance
     */
    draw(d2d) {
        d2d.drawPolygon(this._points, this._color, this._thickness, this._rounded, this._xOffset, this._yOffset)
    }
}

/**
 * Text shape
 */
class D2D1Text extends d2d1Shapes {
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
