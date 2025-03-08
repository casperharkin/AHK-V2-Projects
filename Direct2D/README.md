# Direct2D Wrapper for AutoHotkey v2

A comprehensive wrapper for the Windows Direct2D API, designed to simplify the creation of hardware-accelerated 2D graphics in AutoHotkey v2 applications.

## Overview

This library provides an object-oriented interface to Direct2D's capabilities, abstracting away much of the complexity of working directly with the COM-based API. It enables you to create high-performance graphics with minimal code.

## Features

- Hardware-accelerated 2D rendering
- Simple API for common drawing operations
- Object-oriented design with proper resource management
- Shape classes for higher-level abstraction
- Scene graph for managing multiple shapes
- Comprehensive error handling
- Optimized performance with resource caching

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
  - **D2D1Rectangle**: Rectangle shape
  - **D2D1Circle**: Circle shape
  - **D2D1Line**: Line shape
  - **D2D1Polygon**: Polygon shape
- **D2D1Scene**: Scene graph for managing multiple shapes

## Examples

The `examples` directory contains several examples demonstrating different aspects of the library:

- **basic.ahk**: Basic usage of the D2D1 class
- **animation.ahk**: Animation example
- **shapes.ahk**: Demonstration of shape classes and scene graph

## Color Format

Colors are specified in `0xAARRGGBB` or `0xRRGGBB` format:
- `AA`: Alpha channel (00-FF, where FF is fully opaque)
- `RR`: Red channel (00-FF)
- `GG`: Green channel (00-FF)
- `BB`: Blue channel (00-FF)

If you provide `0xRRGGBB`, alpha will be set to `0xFF` (fully opaque).

## Attribution

This library is based on Spawnova's Direct2D overlay class, which can be found at: https://github.com/Spawnova/ShinsOverlayClass

## License

This project is licensed under the MIT License - see the LICENSE file for details.