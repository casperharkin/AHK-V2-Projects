;==================================================================================================================
; Pong Game
;==================================================================================================================
; Description:    A classic Pong game implementation using Direct2D
;                 Two players control paddles to hit a ball back and forth
;
; Features:       - Two-player gameplay with keyboard controls
;                 - Ball physics with angle reflection
;                 - Score tracking
;                 - Increasing difficulty as the game progresses
;
; Usage:          Run the script to start the game
;
; Hotkeys:        W/S - Move left paddle up/down
;                 Up/Down - Move right paddle up/down
;                 R - Restart game
;                 Space - Start/Pause game
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
class PongGame {
    ; Game properties
    width := 800
    height := 600
    scoreLeft := 0
    scoreRight := 0
    gameOver := false
    gamePaused := false
    gameStarted := false
    
    ; D2D1 and GUI references
    d2d := ""
    myGui := ""
    
    ; Game objects
    paddleLeft := {x: 30, y: 250, width: 20, height: 100, speed: 8}
    paddleRight := {x: 750, y: 250, width: 20, height: 100, speed: 8}
    ball := {x: 400, y: 300, radius: 10, speedX: 5, speedY: 3, baseSpeed: 5}
    
    ; Constructor
    __New() {
        ; Create GUI window
        this.myGui := Gui("+AlwaysOnTop +Resize", "Pong Game")
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
        ; Left paddle controls
        Hotkey "w", ObjBindMethod(this, "MoveLeftPaddleUp")
        Hotkey "s", ObjBindMethod(this, "MoveLeftPaddleDown")
        
        ; Right paddle controls
        Hotkey "Up", ObjBindMethod(this, "MoveRightPaddleUp")
        Hotkey "Down", ObjBindMethod(this, "MoveRightPaddleDown")
        
        ; Game controls
        Hotkey "Space", ObjBindMethod(this, "TogglePause")
        Hotkey "r", ObjBindMethod(this, "RestartGame")
        Hotkey "Escape", ObjBindMethod(this, "ExitGame")
    }
    
    ; ==================== Game Control Functions ====================
    MoveLeftPaddleUp(*) {
        if (this.gameOver || this.gamePaused || !this.gameStarted)
            return
            
        this.paddleLeft.y -= this.paddleLeft.speed
        if (this.paddleLeft.y < 0)
            this.paddleLeft.y := 0
    }
    
    MoveLeftPaddleDown(*) {
        if (this.gameOver || this.gamePaused || !this.gameStarted)
            return
            
        this.paddleLeft.y += this.paddleLeft.speed
        if (this.paddleLeft.y + this.paddleLeft.height > this.height)
            this.paddleLeft.y := this.height - this.paddleLeft.height
    }
    
    MoveRightPaddleUp(*) {
        if (this.gameOver || this.gamePaused || !this.gameStarted)
            return
            
        this.paddleRight.y -= this.paddleRight.speed
        if (this.paddleRight.y < 0)
            this.paddleRight.y := 0
    }
    
    MoveRightPaddleDown(*) {
        if (this.gameOver || this.gamePaused || !this.gameStarted)
            return
            
        this.paddleRight.y += this.paddleRight.speed
        if (this.paddleRight.y + this.paddleRight.height > this.height)
            this.paddleRight.y := this.height - this.paddleRight.height
    }
    
    TogglePause(*) {
        if (this.gameOver)
            return
            
        if (!this.gameStarted) {
            this.gameStarted := true
            this.ResetBall()
        } else {
            this.gamePaused := !this.gamePaused
        }
    }
    
    RestartGame(*) {
        this.scoreLeft := 0
        this.scoreRight := 0
        this.gameOver := false
        this.gamePaused := false
        this.gameStarted := false
        
        ; Reset paddle positions
        this.paddleLeft.y := this.height / 2 - this.paddleLeft.height / 2
        this.paddleRight.y := this.height / 2 - this.paddleRight.height / 2
        
        ; Reset ball
        this.ResetBall()
    }
    
    ResetBall() {
        ; Place ball in the center
        this.ball.x := this.width / 2
        this.ball.y := this.height / 2
        
        ; Randomize direction
        this.ball.speedX := this.ball.baseSpeed * (Random(0, 1) ? 1 : -1)
        this.ball.speedY := this.ball.baseSpeed / 2 * (Random(0, 1) ? 1 : -1)
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
        
        ; Update paddle positions
        this.paddleRight.x := this.width - 30 - this.paddleRight.width
        
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
    UpdateBall() {
        if (!this.gameStarted || this.gamePaused || this.gameOver)
            return
            
        ; Move ball
        this.ball.x += this.ball.speedX
        this.ball.y += this.ball.speedY
        
        ; Check for collision with top and bottom walls
        if (this.ball.y - this.ball.radius <= 0 || this.ball.y + this.ball.radius >= this.height) {
            this.ball.speedY *= -1
        }
        
        ; Check for collision with left paddle
        if (this.ball.x - this.ball.radius <= this.paddleLeft.x + this.paddleLeft.width &&
            this.ball.y >= this.paddleLeft.y && 
            this.ball.y <= this.paddleLeft.y + this.paddleLeft.height &&
            this.ball.speedX < 0) {
            
            ; Calculate reflection angle based on where the ball hit the paddle
            hitPosition := (this.ball.y - this.paddleLeft.y) / this.paddleLeft.height
            bounceAngle := (hitPosition - 0.5) * 60  ; -30 to +30 degrees
            
            ; Convert angle to velocity components
            speed := Sqrt(this.ball.speedX * this.ball.speedX + this.ball.speedY * this.ball.speedY)
            this.ball.speedX := Abs(speed * Cos(bounceAngle * 0.0174533))  ; Convert degrees to radians
            this.ball.speedY := speed * Sin(bounceAngle * 0.0174533)
            
            ; Increase speed slightly
            this.ball.speedX *= 1.05
            this.ball.speedY *= 1.05
        }
        
        ; Check for collision with right paddle
        if (this.ball.x + this.ball.radius >= this.paddleRight.x &&
            this.ball.y >= this.paddleRight.y && 
            this.ball.y <= this.paddleRight.y + this.paddleRight.height &&
            this.ball.speedX > 0) {
            
            ; Calculate reflection angle based on where the ball hit the paddle
            hitPosition := (this.ball.y - this.paddleRight.y) / this.paddleRight.height
            bounceAngle := (hitPosition - 0.5) * 60  ; -30 to +30 degrees
            
            ; Convert angle to velocity components
            speed := Sqrt(this.ball.speedX * this.ball.speedX + this.ball.speedY * this.ball.speedY)
            this.ball.speedX := -Abs(speed * Cos(bounceAngle * 0.0174533))  ; Convert degrees to radians
            this.ball.speedY := speed * Sin(bounceAngle * 0.0174533)
            
            ; Increase speed slightly
            this.ball.speedX *= 1.05
            this.ball.speedY *= 1.05
        }
        
        ; Check if ball went past paddles
        if (this.ball.x < 0) {
            ; Right player scores
            this.scoreRight += 1
            this.ResetBall()
            
            ; Check for game over
            if (this.scoreRight >= 10) {
                this.gameOver := true
            }
        } else if (this.ball.x > this.width) {
            ; Left player scores
            this.scoreLeft += 1
            this.ResetBall()
            
            ; Check for game over
            if (this.scoreLeft >= 10) {
                this.gameOver := true
            }
        }
    }
    
    ; ==================== Main Game Loop ====================
    GameLoop(*) {
        ; Begin drawing
        this.d2d.beginDraw()
        
        ; Clear background
        this.d2d.fillRectangle(0, 0, this.width, this.height, 0x000000)
        
        ; Draw game elements
        if (!this.gameStarted) {
            ; Draw start screen
            this.DrawStartScreen()
        } else if (this.gameOver) {
            ; Draw game over screen
            this.DrawGameOverScreen()
        } else {
            ; Update ball position and check collisions
            this.UpdateBall()
            
            ; Draw game elements
            this.DrawGameElements()
            
            ; Draw pause screen if paused
            if (this.gamePaused) {
                this.DrawPauseScreen()
            }
        }
        
        ; End drawing
        this.d2d.endDraw()
    }
    
    ; ==================== Drawing Functions ====================
    DrawStartScreen() {
        ; Draw title
        this.d2d.drawText("PONG", this.width/2 - 100, 150, 72, 0xFFFFFF, "Arial", "w200 h80 aCenter")
        
        ; Draw instructions
        instructions := "Player 1: W/S keys to move paddle`n"
                      . "Player 2: Up/Down arrows to move paddle`n`n"
                      . "First to 10 points wins!`n`n"
                      . "Press SPACE to start"
        
        this.d2d.drawText(instructions, this.width/2 - 200, 250, 20, 0xFFFFFF, "Arial", "w400 h200 aCenter")
        
        ; Draw paddles
        this.d2d.fillRectangle(this.paddleLeft.x, this.paddleLeft.y, 
                              this.paddleLeft.width, this.paddleLeft.height, 0xFFFFFF)
        this.d2d.fillRectangle(this.paddleRight.x, this.paddleRight.y, 
                              this.paddleRight.width, this.paddleRight.height, 0xFFFFFF)
    }
    
    DrawGameOverScreen() {
        ; Draw game over message
        this.d2d.drawText("GAME OVER", this.width/2 - 150, 150, 36, 0xFFFFFF, "Arial", "w300 h50 aCenter")
        
        ; Draw winner message
        if (this.scoreLeft > this.scoreRight) {
            this.d2d.drawText("Player 1 Wins!", this.width/2 - 100, 220, 24, 0xFFFFFF, "Arial", "w200 h30 aCenter")
        } else {
            this.d2d.drawText("Player 2 Wins!", this.width/2 - 100, 220, 24, 0xFFFFFF, "Arial", "w200 h30 aCenter")
        }
        
        ; Draw final score
        this.d2d.drawText("Final Score: " this.scoreLeft " - " this.scoreRight, 
                         this.width/2 - 100, 270, 20, 0xFFFFFF, "Arial", "w200 h30 aCenter")
        
        ; Draw restart instructions
        this.d2d.drawText("Press R to restart or ESC to exit", 
                         this.width/2 - 150, 320, 18, 0xFFFFFF, "Arial", "w300 h30 aCenter")
    }
    
    DrawPauseScreen() {
        ; Semi-transparent overlay
        this.d2d.fillRectangle(0, 0, this.width, this.height, 0x80000000)
        
        ; Pause message
        this.d2d.drawText("PAUSED", this.width/2 - 100, this.height/2 - 50, 36, 0xFFFFFF, "Arial", "w200 h50 aCenter")
        this.d2d.drawText("Press SPACE to continue", this.width/2 - 150, this.height/2 + 20, 20, 0xFFFFFF, "Arial", "w300 h30 aCenter")
    }
    
    DrawGameElements() {
        ; Draw center line
        lineY := 0
        while (lineY < this.height) {
            this.d2d.fillRectangle(this.width/2 - 2, lineY, 4, 10, 0xFFFFFF)
            lineY += 20
        }
        
        ; Draw paddles
        this.d2d.fillRectangle(this.paddleLeft.x, this.paddleLeft.y, 
                              this.paddleLeft.width, this.paddleLeft.height, 0xFFFFFF)
        this.d2d.fillRectangle(this.paddleRight.x, this.paddleRight.y, 
                              this.paddleRight.width, this.paddleRight.height, 0xFFFFFF)
        
        ; Draw ball
        this.d2d.fillCircle(this.ball.x, this.ball.y, this.ball.radius, 0xFFFFFF)
        
        ; Draw scores
        this.d2d.drawText(this.scoreLeft, this.width/4, 50, 36, 0xFFFFFF, "Arial", "w50 h40 aCenter")
        this.d2d.drawText(this.scoreRight, 3*this.width/4, 50, 36, 0xFFFFFF, "Arial", "w50 h40 aCenter")
    }
}

; ==================== Application Initialization ====================
; Create an instance of the game
game := PongGame()