;==================================================================================================================
; Catch the Ball Game
;==================================================================================================================
; Description:    A simple game where the player controls a paddle to catch falling balls
;                 Uses Direct2D for smooth graphics and animations
;
; Features:       - Keyboard-controlled paddle movement
;                 - Randomly falling balls with increasing difficulty
;                 - Score tracking and display
;                 - Game over condition when too many balls are missed
;
; Usage:          Run the script to start the game
;
; Hotkeys:        Left/Right - Move paddle
;                 R - Restart game
;                 Escape - Exit game
;
; Dependencies:   - AutoHotkey v2.0
;                 - D2D1.ahk library
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   10/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include ..\d2d1.ahk

; ==================== Game Class Definition ====================
class CatchTheBallGame {
    ; Game properties
    width := 800
    height := 600
    score := 0
    lives := 5
    gameOver := false
    gameStarted := false
    difficulty := 1
    
    ; D2D1 and GUI references
    d2d := ""
    myGui := ""
    
    ; Game objects
    paddle := {x: 350, y: 550, width: 100, height: 20, speed: 10}
    balls := []
    
    ; Game timing
    lastBallSpawn := 0
    spawnInterval := 1500  ; milliseconds
    
    ; Constructor
    __New() {
        ; Create GUI window
        this.myGui := Gui("+AlwaysOnTop +Resize", "Catch the Ball")
        this.myGui.OnEvent("Size", ObjBindMethod(this, "OnResize"))
        this.myGui.OnEvent("Close", ObjBindMethod(this, "OnExit"))
        this.myGui.Show("w" this.width " h" this.height)
        
        ; Initialize D2D1 instance
        this.d2d := D2D1(this.myGui.hwnd, 0, 0, this.width, this.height)
        
        ; Set up hotkeys
        this.ConfigureHotkeys()
        
        ; Set up game timer (60 FPS)
        SetTimer(ObjBindMethod(this, "GameLoop"), 16)
    }
    
    ; ==================== Event Setup ====================
    ; Configure hotkeys
    ConfigureHotkeys() {
        Hotkey "Left", ObjBindMethod(this, "MoveLeft")
        Hotkey "Right", ObjBindMethod(this, "MoveRight")
        Hotkey "R", ObjBindMethod(this, "RestartGame")
        Hotkey "Escape", ObjBindMethod(this, "ExitGame")
        Hotkey "Space", ObjBindMethod(this, "StartGame")
    }
    
    ; ==================== Game Control Functions ====================
    MoveLeft(*) {
        if (this.gameOver || !this.gameStarted)
            return
            
        this.paddle.x -= this.paddle.speed
        if (this.paddle.x < 0)
            this.paddle.x := 0
    }
    
    MoveRight(*) {
        if (this.gameOver || !this.gameStarted)
            return
            
        this.paddle.x += this.paddle.speed
        if (this.paddle.x + this.paddle.width > this.width)
            this.paddle.x := this.width - this.paddle.width
    }
    
    RestartGame(*) {
        this.score := 0
        this.lives := 5
        this.gameOver := false
        this.gameStarted := false
        this.difficulty := 1
        this.balls := []
        this.paddle.x := this.width / 2 - this.paddle.width / 2
    }
    
    StartGame(*) {
        if (!this.gameStarted && !this.gameOver) {
            this.gameStarted := true
            this.lastBallSpawn := A_TickCount
        } else if (this.gameOver) {
            this.RestartGame()
        }
    }
    
    ExitGame(*) {
        ExitApp()
    }
    
    ; Window resize handler
    OnResize(thisGui, MinMax, wSize, hSize) {
        if (MinMax = -1) ; Window is minimized
            return
        
        ; Update dimensions
        this.width := wSize
        this.height := hSize
        
        ; Update paddle position
        this.paddle.y := this.height - 50
        
        ; Only proceed if d2d is properly initialized
        if (this.d2d = "" || !IsObject(this.d2d) || !this.d2d.HasProp("_renderTarget") || !this.d2d.HasProp("_nrSize"))
            return
        
        ; Create a buffer for the new size
        newSize := Buffer(16, 0)
        NumPut("uint", this.width, newSize, 0)
        NumPut("uint", this.height, newSize, 4)
        
        ; Update D2D1 dimensions
        DllCall(this.d2d._nrSize, "Ptr", this.d2d._renderTarget, "ptr", newSize)
    }
    
    ; Cleanup on exit
    OnExit(*) {
        ; Stop the game timer
        SetTimer(ObjBindMethod(this, "GameLoop"), 0)
        
        ; Clean up D2D1 resources
        this.d2d.cleanup()
        
        ExitApp()
    }
    
    ; ==================== Game Logic ====================
    SpawnBall() {
        ; Create a new ball at a random x position
        ball := {
            x: Random(50, this.width - 50),
            y: 0,
            radius: Random(15, 30),
            speed: Random(2, 4) * this.difficulty,
            color: Random(0x000000, 0xFFFFFF)
        }
        
        ; Add the ball to the array
        this.balls.Push(ball)
        
        ; Update last spawn time
        this.lastBallSpawn := A_TickCount
        
        ; Increase difficulty over time
        this.difficulty += 0.01
    }
    
    UpdateBalls() {
        ; Move balls down
        for i, ball in this.balls {
            ; Update ball position
            ball.y += ball.speed
            
            ; Check for collision with paddle
            if (ball.y + ball.radius >= this.paddle.y && 
                ball.y - ball.radius <= this.paddle.y + this.paddle.height &&
                ball.x >= this.paddle.x && 
                ball.x <= this.paddle.x + this.paddle.width) {
                ; Ball caught - remove it and add score
                this.balls.RemoveAt(i)
                this.score += 10
                continue
            }
            
            ; Check if ball is out of bounds
            if (ball.y - ball.radius > this.height) {
                ; Ball missed - remove it and lose a life
                this.balls.RemoveAt(i)
                this.lives -= 1
                
                ; Check for game over
                if (this.lives <= 0) {
                    this.gameOver := true
                }
            }
        }
    }
    
    ; ==================== Main Game Loop ====================
    GameLoop(*) {
        ; Begin drawing
        this.d2d.beginDraw()
        
        ; Clear background
        this.d2d.fillRectangle(0, 0, this.width, this.height, 0xF0F0F0)
        
        ; Draw game elements
        if (!this.gameStarted && !this.gameOver) {
            ; Draw start screen
            this.DrawStartScreen()
        } else if (this.gameOver) {
            ; Draw game over screen
            this.DrawGameOverScreen()
        } else {
            ; Game is running
            
            ; Check if it's time to spawn a new ball
            if (A_TickCount - this.lastBallSpawn > this.spawnInterval / this.difficulty) {
                this.SpawnBall()
            }
            
            ; Update ball positions and check collisions
            this.UpdateBalls()
            
            ; Draw game elements
            this.DrawGameElements()
        }
        
        ; End drawing
        this.d2d.endDraw()
    }
    
    ; ==================== Drawing Functions ====================
    DrawStartScreen() {
        ; Draw title
        this.d2d.drawText("CATCH THE BALL", this.width/2 - 150, 150, 36, 0x000000, "Arial", "w300 h50 aCenter")
        
        ; Draw instructions
        instructions := "Use LEFT and RIGHT arrow keys to move the paddle.`n"
                      . "Catch the falling balls to score points.`n"
                      . "Miss 5 balls and the game is over!`n`n"
                      . "Press SPACE to start"
        
        this.d2d.drawText(instructions, this.width/2 - 200, 250, 20, 0x000000, "Arial", "w400 h200 aCenter")
        
        ; Draw paddle
        this.d2d.fillRoundedRectangle(this.paddle.x, this.paddle.y, 
                                     this.paddle.width, this.paddle.height, 
                                     5, 5, 0x3366CC)
    }
    
    DrawGameOverScreen() {
        ; Draw game over message
        this.d2d.drawText("GAME OVER", this.width/2 - 150, 150, 36, 0xFF0000, "Arial", "w300 h50 aCenter")
        
        ; Draw final score
        this.d2d.drawText("Final Score: " this.score, this.width/2 - 100, 250, 24, 0x000000, "Arial", "w200 h30 aCenter")
        
        ; Draw restart instructions
        this.d2d.drawText("Press R to restart or ESC to exit", this.width/2 - 150, 300, 18, 0x000000, "Arial", "w300 h30 aCenter")
    }
    
    DrawGameElements() {
        ; Draw paddle
        this.d2d.fillRoundedRectangle(this.paddle.x, this.paddle.y, 
                                     this.paddle.width, this.paddle.height, 
                                     5, 5, 0x3366CC)
        
        ; Draw balls
        for ball in this.balls {
            this.d2d.fillCircle(ball.x, ball.y, ball.radius, ball.color)
        }
        
        ; Draw score
        this.d2d.drawText("Score: " this.score, 10, 10, 20, 0x000000, "Arial", "w150 h30")
        
        ; Draw lives
        livesText := "Lives: "
        loop this.lives {
            livesText .= "♥ "
        }
        this.d2d.drawText(livesText, this.width - 150, 10, 20, 0xFF0000, "Arial", "w140 h30")
        
        ; Draw difficulty level
        this.d2d.drawText("Level: " Round(this.difficulty, 1), this.width/2 - 50, 10, 20, 0x000000, "Arial", "w100 h30")
    }
}

; ==================== Application Initialization ====================
; Create an instance of the game
game := CatchTheBallGame()