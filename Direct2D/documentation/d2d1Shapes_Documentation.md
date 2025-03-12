# Direct2D Shape Classes (d2d1Shapes.ahk)

## Introduction

The `d2d1Shapes.ahk` file provides object-oriented shape classes for Direct2D rendering in AutoHotkey v2. These classes offer a higher-level abstraction over the basic drawing methods in the `D2D1` class, making it easier to create, manipulate, and render shapes. This document offers comprehensive documentation for these shape classes, including both tutorial-based examples and detailed technical information.

## Overview

The shape classes in `d2d1Shapes.ahk` follow an object-oriented design with inheritance. All shape classes inherit from the base `d2d1Shapes` class, which provides common properties and methods for all shapes. This design allows for consistent behavior across different shape types and makes it easy to add new shape types in the future.

### Key Features

- **Object-Oriented Design**: Clean, modular architecture with inheritance
- **Common Interface**: All shapes share the same basic methods and properties
- **Easy Positioning**: Simple methods for moving shapes
- **Color Management**: Easy color setting for all shapes
- **Specialized Classes**: Dedicated classes for different shape types
- **Text Support**: Advanced text rendering with formatting options

## Class Hierarchy

The shape classes are organized in a hierarchy:

```
d2d1Shapes (Base class)
├── D2D1Rectangle
├── D2D1OutlineRectangle
├── D2D1RoundedRectangle
├── D2D1OutlineRoundedRectangle
├── D2D1Circle
├── D2D1OutlineCircle
├── D2D1Line
├── D2D1Polygon
├── D2D1OutlinePolygon
└── D2D1Text
```

## Base Class: d2d1Shapes

The `d2d1Shapes` class is the base class for all shape classes. It provides common properties and methods that are inherited by all shape classes.

### Properties

- **_x**: X coordinate of the shape
- **_y**: Y coordinate of the shape
- **_color**: Color of the shape in 0xAARRGGBB or 0xRRGGBB format

### Constructor

```autohotkey
__New(x, y, color := 0xFFFFFFFF)
```

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Initializes the basic properties of the shape
- Default color is white (0xFFFFFFFF)

### Methods

#### draw

```autohotkey
draw(d2d)
```

Draw the shape.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- This is a placeholder method that should be implemented by derived classes
- Each derived class will implement this method to draw its specific shape

#### move

```autohotkey
move(dx, dy)
```

Move the shape.

**Parameters**:
- `dx` (Number): X offset
- `dy` (Number): Y offset

**Technical Details**:
- Adds the specified offsets to the current position
- This method is inherited by all derived classes

#### setColor

```autohotkey
setColor(color)
```

Set the shape color.

**Parameters**:
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Updates the color property
- This method is inherited by all derived classes

## Rectangle Classes

### D2D1Rectangle

The `D2D1Rectangle` class represents a filled rectangle.

#### Properties

- **_width**: Width of the rectangle
- **_height**: Height of the rectangle

#### Constructor

```autohotkey
__New(x, y, width, height, color := 0xFFFFFFFF)
```

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate
- `width` (Number): Width
- `height` (Number): Height
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes rectangle-specific properties

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the rectangle.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.fillRectangle()` to draw a filled rectangle
- Uses the shape's position, dimensions, and color

### D2D1OutlineRectangle

The `D2D1OutlineRectangle` class represents a rectangle outline.

#### Properties

- **_width**: Width of the rectangle
- **_height**: Height of the rectangle
- **_thickness**: Line thickness
- **_rounded**: Whether to use rounded caps

#### Constructor

```autohotkey
__New(x, y, width, height, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate
- `width` (Number): Width
- `height` (Number): Height
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes rectangle-specific properties
- Initializes outline-specific properties

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the rectangle outline.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.drawRectangle()` to draw a rectangle outline
- Uses the shape's position, dimensions, color, thickness, and rounded properties

### D2D1RoundedRectangle

The `D2D1RoundedRectangle` class represents a filled rounded rectangle.

#### Properties

- **_width**: Width of the rectangle
- **_height**: Height of the rectangle
- **_radiusX**: X radius of the rounded corners
- **_radiusY**: Y radius of the rounded corners

#### Constructor

```autohotkey
__New(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF)
```

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate
- `width` (Number): Width
- `height` (Number): Height
- `radiusX` (Number): X radius of the rounded corners
- `radiusY` (Number): Y radius of the rounded corners
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes rounded rectangle-specific properties

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the rounded rectangle.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.fillRoundedRectangle()` to draw a filled rounded rectangle
- Uses the shape's position, dimensions, corner radii, and color

### D2D1OutlineRoundedRectangle

The `D2D1OutlineRoundedRectangle` class represents a rounded rectangle outline.

#### Properties

- **_width**: Width of the rectangle
- **_height**: Height of the rectangle
- **_radiusX**: X radius of the rounded corners
- **_radiusY**: Y radius of the rounded corners
- **_thickness**: Line thickness
- **_rounded**: Whether to use rounded caps

#### Constructor

```autohotkey
__New(x, y, width, height, radiusX, radiusY, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate
- `width` (Number): Width
- `height` (Number): Height
- `radiusX` (Number): X radius of the rounded corners
- `radiusY` (Number): Y radius of the rounded corners
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes rounded rectangle-specific properties
- Initializes outline-specific properties

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the rounded rectangle outline.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.drawRoundedRectangle()` to draw a rounded rectangle outline
- Uses the shape's position, dimensions, corner radii, color, thickness, and rounded properties

## Circle Classes

### D2D1Circle

The `D2D1Circle` class represents a filled circle.

#### Properties

- **_radius**: Radius of the circle

#### Constructor

```autohotkey
__New(x, y, radius, color := 0xFFFFFFFF)
```

**Parameters**:
- `x` (Number): Center X coordinate
- `y` (Number): Center Y coordinate
- `radius` (Number): Radius
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes circle-specific properties

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the circle.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.fillCircle()` to draw a filled circle
- Uses the shape's position, radius, and color

### D2D1OutlineCircle

The `D2D1OutlineCircle` class represents a circle outline.

#### Properties

- **_radius**: Radius of the circle
- **_thickness**: Line thickness
- **_rounded**: Whether to use rounded caps

#### Constructor

```autohotkey
__New(x, y, radius, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

**Parameters**:
- `x` (Number): Center X coordinate
- `y` (Number): Center Y coordinate
- `radius` (Number): Radius
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes circle-specific properties
- Initializes outline-specific properties

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the circle outline.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.drawCircle()` to draw a circle outline
- Uses the shape's position, radius, color, thickness, and rounded properties

## Line Class

### D2D1Line

The `D2D1Line` class represents a line.

#### Properties

- **_x2**: End X coordinate
- **_y2**: End Y coordinate
- **_thickness**: Line thickness
- **_rounded**: Whether to use rounded caps

#### Constructor

```autohotkey
__New(x1, y1, x2, y2, color := 0xFFFFFFFF, thickness := 1, rounded := 0)
```

**Parameters**:
- `x1` (Number): Start X coordinate
- `y1` (Number): Start Y coordinate
- `x2` (Number): End X coordinate
- `y2` (Number): End Y coordinate
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded caps

**Technical Details**:
- Calls the base class constructor to initialize common properties (x1, y1)
- Initializes line-specific properties (x2, y2)
- Initializes line style properties

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the line.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.drawLine()` to draw a line
- Uses the shape's start and end coordinates, color, thickness, and rounded properties

## Polygon Classes

### D2D1Polygon

The `D2D1Polygon` class represents a filled polygon.

#### Properties

- **_points**: Array of 2D points
- **_xOffset**: X offset
- **_yOffset**: Y offset

#### Constructor

```autohotkey
__New(points, color := 0xFFFFFFFF, xOffset := 0, yOffset := 0)
```

**Parameters**:
- `points` (Array): Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `xOffset` (Number): X offset
- `yOffset` (Number): Y offset

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes polygon-specific properties
- The base position (x, y) is set to 0, 0 since the polygon uses its own point coordinates

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the polygon.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.fillPolygon()` to draw a filled polygon
- Uses the shape's points, color, and offsets

### D2D1OutlinePolygon

The `D2D1OutlinePolygon` class represents a polygon outline.

#### Properties

- **_points**: Array of 2D points
- **_thickness**: Line thickness
- **_rounded**: Whether to use rounded corners
- **_xOffset**: X offset
- **_yOffset**: Y offset

#### Constructor

```autohotkey
__New(points, color := 0xFFFFFFFF, thickness := 1, rounded := 0, xOffset := 0, yOffset := 0)
```

**Parameters**:
- `points` (Array): Array of 2D points, e.g. [[0,0],[5,0],[0,5]]
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `thickness` (Number): Line thickness
- `rounded` (Boolean): Whether to use rounded corners
- `xOffset` (Number): X offset
- `yOffset` (Number): Y offset

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes polygon-specific properties
- Initializes outline-specific properties
- The base position (x, y) is set to 0, 0 since the polygon uses its own point coordinates

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the polygon outline.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.drawPolygon()` to draw a polygon outline
- Uses the shape's points, color, thickness, rounded property, and offsets

## Text Class

### D2D1Text

The `D2D1Text` class represents text with formatting options.

#### Properties

- **_text**: Text content
- **_width**: Width of text block
- **_height**: Height of text block
- **_fontSize**: Font size
- **_fontName**: Font name
- **_extraOptions**: Additional options for text rendering

#### Constructor

```autohotkey
__New(text, x, y, width, height, color := 0xFF000000, fontName := "Arial", alignment := "left", extraOptions := "")
```

**Parameters**:
- `text` (String): Text content
- `x` (Number): X position
- `y` (Number): Y position
- `width` (Number): Width of text block
- `height` (Number): Height of text block
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format
- `fontName` (String): Font name
- `alignment` (String): Text alignment ("left", "center", "right")
- `extraOptions` (String): Additional options for text rendering

**Technical Details**:
- Calls the base class constructor to initialize common properties
- Initializes text-specific properties
- Builds the extra options string based on the provided parameters

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the text.

**Parameters**:
- `d2d` (D2D1): D2D1 instance

**Technical Details**:
- Calls `d2d.drawText()` to draw text
- Uses the shape's text content, position, font size, color, font name, and extra options

##### setText

```autohotkey
setText(text)
```

Set the text content.

**Parameters**:
- `text` (String): New text content

**Technical Details**:
- Updates the text property

##### setFontSize

```autohotkey
setFontSize(size)
```

Set the font size.

**Parameters**:
- `size` (Number): Font size

**Technical Details**:
- Updates the font size property

##### setFontName

```autohotkey
setFontName(fontName)
```

Set the font name.

**Parameters**:
- `fontName` (String): Font name

**Technical Details**:
- Updates the font name property

##### setAlignment

```autohotkey
setAlignment(alignment)
```

Set the text alignment.

**Parameters**:
- `alignment` (String): Text alignment ("left", "center", "right")

**Technical Details**:
- Removes existing alignment options from the extra options string
- Adds the new alignment option to the extra options string

##### addDropShadow

```autohotkey
addDropShadow(color, xOffset := 1, yOffset := 1)
```

Add drop shadow effect.

**Parameters**:
- `color` (Integer): Shadow color in 0xAARRGGBB or 0xRRGGBB format
- `xOffset` (Number): X offset
- `yOffset` (Number): Y offset

**Technical Details**:
- Removes existing shadow options from the extra options string
- Adds the new shadow options to the extra options string

##### addOutline

```autohotkey
addOutline(color)
```

Add outline effect.

**Parameters**:
- `color` (Integer): Outline color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Removes existing outline options from the extra options string
- Adds the new outline option to the extra options string

## Usage Examples

### Basic Shapes

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Basic Shapes")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create shapes
rect := D2D1Rectangle(50, 50, 100, 100, 0xFF0000)
outlineRect := D2D1OutlineRectangle(200, 50, 100, 100, 0x0000FF, 3)
roundedRect := D2D1RoundedRectangle(350, 50, 100, 100, 10, 10, 0x00FF00)
circle := D2D1Circle(100, 200, 50, 0xFF00FF)
outlineCircle := D2D1OutlineCircle(250, 200, 50, 0x00FFFF, 3)
line := D2D1Line(350, 150, 450, 250, 0x000000, 3)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw shapes
rect.draw(d2d)
outlineRect.draw(d2d)
roundedRect.draw(d2d)
circle.draw(d2d)
outlineCircle.draw(d2d)
line.draw(d2d)

; End drawing
d2d.endDraw()
```

### Polygons

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Polygons")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create polygons
triangle := D2D1Polygon([[100, 100], [200, 100], [150, 200]], 0xFF0000)
outlineTriangle := D2D1OutlinePolygon([[300, 100], [400, 100], [350, 200]], 0x0000FF, 3)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw polygons
triangle.draw(d2d)
outlineTriangle.draw(d2d)

; End drawing
d2d.endDraw()
```

### Text with Effects

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Text with Effects")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create text objects
title := D2D1Text("Direct2D Text", 50, 50, 700, 50, 0x000000, "Arial", "center")
title.setFontSize(24)

subtitle := D2D1Text("With Effects", 50, 100, 700, 50, 0x0000FF, "Arial", "center")
subtitle.setFontSize(18)
subtitle.addDropShadow(0x80000000, 2, 2)

outlineText := D2D1Text("Outlined Text", 50, 150, 700, 50, 0xFF0000, "Arial", "center")
outlineText.setFontSize(18)
outlineText.addOutline(0x000000)

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw text
title.draw(d2d)
subtitle.draw(d2d)
outlineText.draw(d2d)

; End drawing
d2d.endDraw()
```

### Using Scene Graph

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Scene Graph")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create a scene
scene := D2D1Scene()

; Add shapes to the scene
scene.addShape(D2D1Rectangle(50, 50, 100, 100, 0xFF0000))
scene.addShape(D2D1OutlineRectangle(200, 50, 100, 100, 0x0000FF, 3))
scene.addShape(D2D1RoundedRectangle(350, 50, 100, 100, 10, 10, 0x00FF00))
scene.addShape(D2D1Circle(100, 200, 50, 0xFF00FF))
scene.addShape(D2D1OutlineCircle(250, 200, 50, 0x00FFFF, 3))
scene.addShape(D2D1Line(350, 150, 450, 250, 0x000000, 3))
scene.addShape(D2D1Polygon([[500, 150], [600, 150], [550, 250]], 0xFFFF00))
scene.addShape(D2D1Text("Scene Graph", 300, 300, 200, 50, 0x000000, "Arial", "center"))

; Begin drawing
d2d.beginDraw()

; Clear background
d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)

; Draw the scene
scene.draw(d2d)

; End drawing
d2d.endDraw()
```

### Animation with Shapes

```autohotkey
#Include "d2d1.ahk"

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "Animation with Shapes")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 0, 0, 800, 600)

; Create shapes
circle := D2D1Circle(400, 300, 50, 0x0000FF)
line := D2D1Line(400, 300, 400, 300, 0x000000, 2)

; Animation variables
angle := 0
radius := 150

; Create a drawing function
drawFunc := AnimationFrame.Bind(d2d, circle, line)

; Set up animation timer (60 FPS)
SetTimer(drawFunc, 16)

; Animation function
AnimationFrame(d2d, circle, line) {
    static angle := 0
    
    ; Update animation variables
    angle += 2
    if (angle >= 360)
        angle := 0
    
    ; Calculate position
    x := 400 + 150 * Cos(angle * 0.0174533)
    y := 300 + 150 * Sin(angle * 0.0174533)
    
    ; Update shape positions
    circle._x := x
    circle._y := y
    line._x2 := x
    line._y2 := y
    
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw center point
    d2d.fillCircle(400, 300, 5, 0x000000)
    
    ; Draw shapes
    line.draw(d2d)
    circle.draw(d2d)
    
    ; End drawing
    d2d.endDraw()
}
```

## Technical Reference

### Implementation Details

The shape classes are implemented using AutoHotkey v2's class system, which supports inheritance and method overriding. Each shape class inherits from the base `d2d1Shapes` class and overrides the `draw` method to implement its specific drawing behavior.

### Memory Management

Shape objects are managed by AutoHotkey's garbage collector. When a shape is no longer referenced, it will be automatically cleaned up. However, it's still good practice to:

1. **Set variables to empty** (`""`) when you're done with them to help the garbage collector
2. **Reuse shapes** when possible, especially in animation loops
3. **Minimize shape creation** in tight loops

### Performance Considerations

1. **Use the appropriate shape class** for your needs
2. **Reuse shapes** instead of creating new ones for each frame
3. **Use the scene graph** for managing multiple shapes
4. **Batch drawing operations** by using a scene graph or drawing multiple shapes in a single beginDraw/endDraw pair

## Conclusion

The shape classes in `d2d1Shapes.ahk` provide a higher-level abstraction over the basic drawing methods in the `D2D1` class, making it easier to create, manipulate, and render shapes. By using these classes, you can create more complex and interactive graphics applications with less code.

For more detailed information about other components of the Direct2D wrapper, please refer to the following documentation files:

- [d2d1_documentation.md](d2d1_documentation.md): Documentation for the main D2D1 class
- [d2d1Structs_Documentation.md](d2d1Structs_Documentation.md): Documentation for structure definitions
- [D2D1Enums_Documentation.md](D2D1Enums_Documentation.md): Documentation for enumeration values