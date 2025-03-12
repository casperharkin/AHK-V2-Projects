# Direct2D Wrapper for AutoHotkey v2

A comprehensive wrapper for the Windows Direct2D API, designed to simplify the creation of hardware-accelerated 2D graphics in AutoHotkey v2 applications.

## Overview

This library provides an object-oriented interface to Direct2D's capabilities, abstracting away much of the complexity of working directly with the COM-based API. It enables you to create high-performance graphics with minimal code.

## Features

### Core Features
- Hardware-accelerated 2D rendering
- Object-oriented design with proper resource management
- Comprehensive error handling
- Optimized performance with resource caching

### Drawing Capabilities
- Simple API for common drawing operations
- Shape classes for higher-level abstraction
- Scene graph for managing multiple shapes
- Antialiasing settings for quality control

### Text and Effects
- Text rendering with formatting options
- Special text effects (drop shadows, outlines)
- Font caching for improved performance

### Animation and Performance
- VSync control for smooth animations
- Double-buffering for flicker-free rendering

## Getting Started

### Basic Usage

```autohotkey
#Include d2d1.ahk

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a drawing function
drawFunc := RenderFrame.Bind(d2d)

; Set up drawing timer
SetTimer(drawFunc, 40)

; Drawing function
RenderFrame(d2d) {
    ; Begin drawing
    d2d.beginDraw()
    
    ; Clear background with white
    d2d.fillRectangle(0, 0, 800, 600, 0xFFFFFF)
    
    ; Draw shapes
    d2d.fillRectangle(30, 30, 100, 100, 0xFFFF1D)
    d2d.fillCircle(600, 300, 150, 0xCD1C1C)
    d2d.drawLine(150, 150, 600, 600, 0x000000, 5)
    d2d.fillPolygon([[250, 150], [150, 350], [350, 350]], 0x2516FF)
    
    ; End drawing
    d2d.endDraw()
}
```

### Using Shape Classes and Scene Graph

```autohotkey
#Include d2d1.ahk

; Create a GUI window
myGui := Gui(" +Alwaysontop +Resize", "D2D1 Shapes Example")
myGui.Show("w800 h600")

; Initialize D2D1 instance
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600)

; Create a scene
scene := D2D1Scene()

; Add shapes to the scene
scene.addShape(D2D1Rectangle(50, 50, 100, 100, 0xFF0000))
scene.addShape(D2D1Circle(300, 150, 75, 0x00FF00))
scene.addShape(D2D1Line(50, 300, 350, 400, 0x0000FF, 3, 1))
scene.addShape(D2D1Polygon([[500, 100], [600, 200], [550, 300], [450, 250]], 0xFFFF00))

; Draw the scene
scene.draw(d2d)
```

## Class Structure

- **D2D1**: Main class for Direct2D operations
- **D2D1ResourceManager**: Manages Direct2D resources
- **D2D1Structs**: Structure definitions for Direct2D
- **D2D1Shape**: Base class for all shapes
  - **D2D1Rectangle**: Filled rectangle shape
  - **D2D1OutlineRectangle**: Outlined rectangle shape
  - **D2D1RoundedRectangle**: Filled rounded rectangle shape
  - **D2D1OutlineRoundedRectangle**: Outlined rounded rectangle shape
  - **D2D1Circle**: Filled circle shape
  - **D2D1OutlineCircle**: Outlined circle shape
  - **D2D1Line**: Line shape
  - **D2D1Polygon**: Filled polygon shape
  - **D2D1OutlinePolygon**: Outlined polygon shape
  - **D2D1Text**: Text shape with formatting options
- **D2D1Scene**: Scene graph for managing multiple shapes

## Examples

The `examples` directory contains several examples demonstrating different aspects of the library:

- **animation_example.ahk**: Animation example with orbiting objects and trails
- **shapes_example.ahk**: Demonstration of shape classes, scene graph, and compound shapes
- **text_example.ahk**: Advanced text rendering with formatting, effects, and animation

## Advanced Features

### VSync Control

```autohotkey
; Enable VSync during initialization (default)
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600, true)

; Disable VSync during initialization
d2d := D2D1(myGui.hwnd, 100, 100, 800, 600, false)

; Toggle VSync at runtime
d2d.setVSync(true)   ; Enable VSync
d2d.setVSync(false)  ; Disable VSync
```

### Antialiasing Control

```autohotkey
; Enable antialiasing (default)
d2d.setAntialias(true)

; Disable antialiasing
d2d.setAntialias(false)
```

## Text Rendering

The library provides comprehensive text rendering capabilities:

### Basic Text Rendering
```autohotkey
; Draw text with specified font, size, and color
d2d.drawText("Hello, World!", 50, 50, 24, 0x000000, "Arial")
```

### Text Alignment
```autohotkey
; Left alignment (default)
d2d.drawText("Left aligned text", 50, 100, 18, 0x000000, "Arial", "aLeft")

; Center alignment
d2d.drawText("Center aligned text", 50, 150, 18, 0x000000, "Arial", "aCenter")

; Right alignment
d2d.drawText("Right aligned text", 50, 200, 18, 0x000000, "Arial", "aRight")
```

### Text Effects
```autohotkey
; Text with drop shadow (color, x-offset, y-offset)
d2d.drawText("Text with drop shadow", 50, 250, 24, 0x000000, "Arial", "ds808080 dsx2 dsy2")

; Text with outline
d2d.drawText("Text with outline", 50, 300, 24, 0xFF0000, "Arial", "olFF0000")
```

### Using the D2D1Text Class
```autohotkey
; Create a text object
titleText := D2D1Text("Direct2D Text", 50, 50, 700, 50, 0x0000FF, "Arial", "center")
titleText.setFontSize(24)

; Add effects
titleText.addDropShadow(0x80000000, 2, 2)  ; Add drop shadow
titleText.addOutline(0xFF000000)           ; Add outline

; Add to scene
scene.addShape(titleText)
```

## Color Format

Colors are specified in `0xAARRGGBB` or `0xRRGGBB` format:
- `AA`: Alpha channel (00-FF, where FF is fully opaque)
- `RR`: Red channel (00-FF)
- `GG`: Green channel (00-FF)
- `BB`: Blue channel (00-FF)

If you provide `0xRRGGBB`, alpha will be set to `0xFF` (fully opaque).

## Documentation

Comprehensive documentation for the Direct2D wrapper is available in the `documentation` directory:

1. **[d2d1_documentation.md](documentation/d2d1_documentation.md)**: Main documentation for the D2D1 class, including:
   - Overview of the Direct2D wrapper architecture
   - Detailed reference for all methods and properties
   - Event system and resource management
   - Performance optimization tips
   - Practical examples

2. **[d2d1Structs_Documentation.md](documentation/d2d1Structs_Documentation.md)**: Documentation for the structure definitions in `d2d1Structs.ahk`, including:
   - Detailed technical specifications for each structure
   - Memory layout and size information
   - Usage examples and best practices
   - Performance optimization tips

3. **[D2D1Enums_Documentation.md](documentation/D2D1Enums_Documentation.md)**: Documentation for the enumeration values in `D2D1Enums.ahk`, including:
   - Detailed explanations of each enumeration
   - Technical details and Direct2D equivalents
   - Usage contexts and examples
   - Implementation approach

4. **[d2d1Shapes_Documentation.md](documentation/d2d1Shapes_Documentation.md)**: Documentation for the shape classes in `d2d1Shapes.ahk`, including:
   - Class hierarchy and inheritance
   - Detailed reference for each shape class
   - Usage examples and best practices
   - Animation techniques

These documentation files provide both tutorial-based guidance with practical examples and detailed technical reference information.

## Planned Features

The following features are planned for future releases:

- **Image Drawing**: Support for loading and rendering images from files
- **Bitmap Effects**: Applying filters and transformations to images
- **Additional Shape Types**: More complex shape types and path operations

## Attribution

This library is based on Spawnova's Direct2D overlay class, which can be found at: https://github.com/Spawnova/ShinsOverlayClass

## License

This project is licensed under the MIT License - see the LICENSE file for details.