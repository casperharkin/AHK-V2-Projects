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
- **Transformation Support**: Rotation, scaling, and translation of shapes
- **Visibility Control**: Show or hide shapes without removing them
- **Method Chaining**: Fluent interface for concise code

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
├── D2D1Text
├── D2D1Triangle
├── D2D1OutlineTriangle
├── D2D1Ellipse
├── D2D1OutlineEllipse
└── D2D1Arc
```

## Base Class: d2d1Shapes

The `d2d1Shapes` class is the base class for all shape classes. It provides common properties and methods that are inherited by all shape classes.

### Properties

- **_x**: X coordinate of the shape
- **_y**: Y coordinate of the shape
- **_color**: Color of the shape in 0xAARRGGBB or 0xRRGGBB format
- **_transform**: Transformation matrix for the shape
- **_visible**: Whether the shape is visible

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

**Returns**:
- The shape object for method chaining

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

**Returns**:
- The shape object for method chaining

**Technical Details**:
- Updates the color property
- This method is inherited by all derived classes

#### setPosition

```autohotkey
setPosition(x, y)
```

Set the shape position.

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate

**Returns**:
- The shape object for method chaining

**Technical Details**:
- Sets the absolute position of the shape
- This method is inherited by all derived classes

#### setVisible

```autohotkey
setVisible(visible)
```

Set the shape visibility.

**Parameters**:
- `visible` (Boolean): Whether the shape is visible

**Returns**:
- The shape object for method chaining

**Technical Details**:
- Controls whether the shape is drawn
- This method is inherited by all derived classes

#### rotate

```autohotkey
rotate(angle, centerX := 0, centerY := 0)
```

Rotate the shape.

**Parameters**:
- `angle` (Number): Rotation angle in degrees
- `centerX` (Number): X center of rotation (default: shape center)
- `centerY` (Number): Y center of rotation (default: shape center)

**Returns**:
- The shape object for method chaining

**Technical Details**:
- Creates a rotation transformation matrix
- If centerX and centerY are 0, uses the shape's position as the center of rotation
- This method is inherited by all derived classes

#### scale

```autohotkey
scale(scaleX, scaleY := 0, centerX := 0, centerY := 0)
```

Scale the shape.

**Parameters**:
- `scaleX` (Number): X scale factor
- `scaleY` (Number): Y scale factor (default: same as scaleX)
- `centerX` (Number): X center of scaling (default: shape center)
- `centerY` (Number): Y center of scaling (default: shape center)

**Returns**:
- The shape object for method chaining

**Technical Details**:
- Creates a scaling transformation matrix
- If scaleY is 0, uses scaleX for uniform scaling
- If centerX and centerY are 0, uses the shape's position as the center of scaling
- This method is inherited by all derived classes

#### translate

```autohotkey
translate(dx, dy)
```

Translate the shape.

**Parameters**:
- `dx` (Number): X translation
- `dy` (Number): Y translation

**Returns**:
- The shape object for method chaining

**Technical Details**:
- Creates a translation transformation matrix
- This method is inherited by all derived classes

#### resetTransform

```autohotkey
resetTransform()
```

Reset the shape transformation.

**Returns**:
- The shape object for method chaining

**Technical Details**:
- Clears any transformation applied to the shape
- This method is inherited by all derived classes

#### clone

```autohotkey
clone()
```

Clone the shape.

**Returns**:
- A new shape with the same properties

**Technical Details**:
- This is a placeholder method that should be implemented by derived classes
- Each derived class will implement this method to create a copy of itself

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.fillRectangle()` to draw a filled rectangle
- Uses the shape's position, dimensions, and color
- Restores the original transformation if needed

##### setSize

```autohotkey
setSize(width, height)
```

Set the rectangle size.

**Parameters**:
- `width` (Number): Width
- `height` (Number): Height

**Returns**:
- The rectangle object for method chaining

**Technical Details**:
- Updates the width and height properties

##### clone

```autohotkey
clone()
```

Clone the rectangle.

**Returns**:
- A new rectangle with the same properties

**Technical Details**:
- Creates a new rectangle with the same properties
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.drawRectangle()` to draw a rectangle outline
- Uses the shape's position, dimensions, color, thickness, and rounded properties
- Restores the original transformation if needed

##### setSize

```autohotkey
setSize(width, height)
```

Set the rectangle size.

**Parameters**:
- `width` (Number): Width
- `height` (Number): Height

**Returns**:
- The rectangle outline object for method chaining

**Technical Details**:
- Updates the width and height properties

##### setThickness

```autohotkey
setThickness(thickness)
```

Set the line thickness.

**Parameters**:
- `thickness` (Number): Line thickness

**Returns**:
- The rectangle outline object for method chaining

**Technical Details**:
- Updates the thickness property

##### setRounded

```autohotkey
setRounded(rounded)
```

Set whether to use rounded caps.

**Parameters**:
- `rounded` (Boolean): Whether to use rounded caps

**Returns**:
- The rectangle outline object for method chaining

**Technical Details**:
- Updates the rounded property

##### clone

```autohotkey
clone()
```

Clone the rectangle outline.

**Returns**:
- A new rectangle outline with the same properties

**Technical Details**:
- Creates a new rectangle outline with the same properties
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.fillRoundedRectangle()` to draw a filled rounded rectangle
- Uses the shape's position, dimensions, corner radii, and color
- Restores the original transformation if needed

##### setSize

```autohotkey
setSize(width, height)
```

Set the rectangle size.

**Parameters**:
- `width` (Number): Width
- `height` (Number): Height

**Returns**:
- The rounded rectangle object for method chaining

**Technical Details**:
- Updates the width and height properties

##### setRadius

```autohotkey
setRadius(radiusX, radiusY)
```

Set the corner radius.

**Parameters**:
- `radiusX` (Number): X radius of the rounded corners
- `radiusY` (Number): Y radius of the rounded corners

**Returns**:
- The rounded rectangle object for method chaining

**Technical Details**:
- Updates the radiusX and radiusY properties

##### clone

```autohotkey
clone()
```

Clone the rounded rectangle.

**Returns**:
- A new rounded rectangle with the same properties

**Technical Details**:
- Creates a new rounded rectangle with the same properties
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.drawRoundedRectangle()` to draw a rounded rectangle outline
- Uses the shape's position, dimensions, corner radii, color, thickness, and rounded properties
- Restores the original transformation if needed

##### setSize

```autohotkey
setSize(width, height)
```

Set the rectangle size.

**Parameters**:
- `width` (Number): Width
- `height` (Number): Height

**Returns**:
- The rounded rectangle outline object for method chaining

**Technical Details**:
- Updates the width and height properties

##### setRadius

```autohotkey
setRadius(radiusX, radiusY)
```

Set the corner radius.

**Parameters**:
- `radiusX` (Number): X radius of the rounded corners
- `radiusY` (Number): Y radius of the rounded corners

**Returns**:
- The rounded rectangle outline object for method chaining

**Technical Details**:
- Updates the radiusX and radiusY properties

##### setThickness

```autohotkey
setThickness(thickness)
```

Set the line thickness.

**Parameters**:
- `thickness` (Number): Line thickness

**Returns**:
- The rounded rectangle outline object for method chaining

**Technical Details**:
- Updates the thickness property

##### setRounded

```autohotkey
setRounded(rounded)
```

Set whether to use rounded caps.

**Parameters**:
- `rounded` (Boolean): Whether to use rounded caps

**Returns**:
- The rounded rectangle outline object for method chaining

**Technical Details**:
- Updates the rounded property

##### clone

```autohotkey
clone()
```

Clone the rounded rectangle outline.

**Returns**:
- A new rounded rectangle outline with the same properties

**Technical Details**:
- Creates a new rounded rectangle outline with the same properties
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.fillCircle()` to draw a filled circle
- Uses the shape's position, radius, and color
- Restores the original transformation if needed

##### setRadius

```autohotkey
setRadius(radius)
```

Set the radius.

**Parameters**:
- `radius` (Number): Radius

**Returns**:
- The circle object for method chaining

**Technical Details**:
- Updates the radius property

##### clone

```autohotkey
clone()
```

Clone the circle.

**Returns**:
- A new circle with the same properties

**Technical Details**:
- Creates a new circle with the same properties
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.drawCircle()` to draw a circle outline
- Uses the shape's position, radius, color, thickness, and rounded properties
- Restores the original transformation if needed

##### setRadius

```autohotkey
setRadius(radius)
```

Set the radius.

**Parameters**:
- `radius` (Number): Radius

**Returns**:
- The circle outline object for method chaining

**Technical Details**:
- Updates the radius property

##### setThickness

```autohotkey
setThickness(thickness)
```

Set the line thickness.

**Parameters**:
- `thickness` (Number): Line thickness

**Returns**:
- The circle outline object for method chaining

**Technical Details**:
- Updates the thickness property

##### setRounded

```autohotkey
setRounded(rounded)
```

Set whether to use rounded caps.

**Parameters**:
- `rounded` (Boolean): Whether to use rounded caps

**Returns**:
- The circle outline object for method chaining

**Technical Details**:
- Updates the rounded property

##### clone

```autohotkey
clone()
```

Clone the circle outline.

**Returns**:
- A new circle outline with the same properties

**Technical Details**:
- Creates a new circle outline with the same properties
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.drawLine()` to draw a line
- Uses the shape's start and end coordinates, color, thickness, and rounded properties
- Restores the original transformation if needed

##### setEndPoint

```autohotkey
setEndPoint(x2, y2)
```

Set the end point.

**Parameters**:
- `x2` (Number): End X coordinate
- `y2` (Number): End Y coordinate

**Returns**:
- The line object for method chaining

**Technical Details**:
- Updates the end point coordinates

##### setThickness

```autohotkey
setThickness(thickness)
```

Set the line thickness.

**Parameters**:
- `thickness` (Number): Line thickness

**Returns**:
- The line object for method chaining

**Technical Details**:
- Updates the thickness property

##### setRounded

```autohotkey
setRounded(rounded)
```

Set whether to use rounded caps.

**Parameters**:
- `rounded` (Boolean): Whether to use rounded caps

**Returns**:
- The line object for method chaining

**Technical Details**:
- Updates the rounded property

##### clone

```autohotkey
clone()
```

Clone the line.

**Returns**:
- A new line with the same properties

**Technical Details**:
- Creates a new line with the same properties
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.fillPolygon()` to draw a filled polygon
- Uses the shape's points, color, and offsets
- Restores the original transformation if needed

##### setPoints

```autohotkey
setPoints(points)
```

Set the points.

**Parameters**:
- `points` (Array): Array of 2D points, e.g. [[0,0],[5,0],[0,5]]

**Returns**:
- The polygon object for method chaining

**Technical Details**:
- Updates the points array

##### setOffset

```autohotkey
setOffset(xOffset, yOffset)
```

Set the offset.

**Parameters**:
- `xOffset` (Number): X offset
- `yOffset` (Number): Y offset

**Returns**:
- The polygon object for method chaining

**Technical Details**:
- Updates the offset properties

##### addPoint

```autohotkey
addPoint(x, y)
```

Add a point to the polygon.

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate

**Returns**:
- The polygon object for method chaining

**Technical Details**:
- Adds a new point to the points array

##### clone

```autohotkey
clone()
```

Clone the polygon.

**Returns**:
- A new polygon with the same properties

**Technical Details**:
- Creates a new polygon with a copy of the points array
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.drawPolygon()` to draw a polygon outline
- Uses the shape's points, color, thickness, rounded property, and offsets
- Restores the original transformation if needed

##### setPoints

```autohotkey
setPoints(points)
```

Set the points.

**Parameters**:
- `points` (Array): Array of 2D points, e.g. [[0,0],[5,0],[0,5]]

**Returns**:
- The polygon outline object for method chaining

**Technical Details**:
- Updates the points array

##### setThickness

```autohotkey
setThickness(thickness)
```

Set the line thickness.

**Parameters**:
- `thickness` (Number): Line thickness

**Returns**:
- The polygon outline object for method chaining

**Technical Details**:
- Updates the thickness property

##### setRounded

```autohotkey
setRounded(rounded)
```

Set whether to use rounded corners.

**Parameters**:
- `rounded` (Boolean): Whether to use rounded corners

**Returns**:
- The polygon outline object for method chaining

**Technical Details**:
- Updates the rounded property

##### setOffset

```autohotkey
setOffset(xOffset, yOffset)
```

Set the offset.

**Parameters**:
- `xOffset` (Number): X offset
- `yOffset` (Number): Y offset

**Returns**:
- The polygon outline object for method chaining

**Technical Details**:
- Updates the offset properties

##### addPoint

```autohotkey
addPoint(x, y)
```

Add a point to the polygon.

**Parameters**:
- `x` (Number): X coordinate
- `y` (Number): Y coordinate

**Returns**:
- The polygon outline object for method chaining

**Technical Details**:
- Adds a new point to the points array

##### clone

```autohotkey
clone()
```

Clone the polygon outline.

**Returns**:
- A new polygon outline with the same properties

**Technical Details**:
- Creates a new polygon outline with a copy of the points array
- Copies transformation and visibility settings

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
- Checks if the shape is visible
- Applies any transformation if set
- Calls `d2d.drawText()` to draw text
- Uses the shape's text content, position, font size, color, font name, and extra options
- Restores the original transformation if needed

##### setText

```autohotkey
setText(text)
```

Set the text content.

**Parameters**:
- `text` (String): New text content

**Returns**:
- The text object for method chaining

**Technical Details**:
- Updates the text property

##### setFontSize

```autohotkey
setFontSize(size)
```

Set the font size.

**Parameters**:
- `size` (Number): Font size

**Returns**:
- The text object for method chaining

**Technical Details**:
- Updates the font size property

##### setFontName

```autohotkey
setFontName(fontName)
```

Set the font name.

**Parameters**:
- `fontName` (String): Font name

**Returns**:
- The text object for method chaining

**Technical Details**:
- Updates the font name property

##### setAlignment

```autohotkey
setAlignment(alignment)
```

Set the text alignment.

**Parameters**:
- `alignment` (String): Text alignment ("left", "center", "right")

**Returns**:
- The text object for method chaining

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

**Returns**:
- The text object for method chaining

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

**Returns**:
- The text object for method chaining

**Technical Details**:
- Removes existing outline options from the extra options string
- Adds the new outline option to the extra options string

##### setSize

```autohotkey
setSize(width, height)
```

Set the text size.

**Parameters**:
- `width` (Number): Width
- `height` (Number): Height

**Returns**:
- The text object for method chaining

**Technical Details**:
- Updates the width and height properties
- Updates the width and height in the extra options string

##### clone

```autohotkey
clone()
```

Clone the text.

**Returns**:
- A new text with the same properties

**Technical Details**:
- Creates a new text with the same properties
- Copies transformation and visibility settings

## Triangle Classes

### D2D1Triangle

The `D2D1Triangle` class represents a filled triangle.

#### Properties

- **_x2**: Second point X coordinate
- **_y2**: Second point Y coordinate
- **_x3**: Third point X coordinate
- **_y3**: Third point Y coordinate

#### Constructor

```autohotkey
__New(x1, y1, x2, y2, x3, y3, color := 0xFFFFFFFF)
```

**Parameters**:
- `x1` (Number): First point X coordinate
- `y1` (Number): First point Y coordinate
- `x2` (Number): Second point X coordinate
- `y2` (Number): Second point Y coordinate
- `x3` (Number): Third point X coordinate
- `y3` (Number): Third point Y coordinate
- `color` (Integer): Color in 0xAARRGGBB or 0xRRGGBB format

**Technical Details**:
- Calls the base class constructor to initialize common properties (x1, y1)
- Initializes triangle-specific properties (x2, y2, x3, y3)

#### Methods

##### draw

```autohotkey
draw(d2d)
```

Draw the triangle.

**Parameters**:
