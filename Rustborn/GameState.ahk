;==================================================================================================================
; Game States
;==================================================================================================================
; Description:    Defines the possible states for the Rustborn game
;                 Used to control game flow and UI rendering
;
; Usage:          Reference states using GameState.STATE_NAME
;
; Dependencies:   - AutoHotkey v2.0
;
; Author:         CasperHarkin
; Version:        0.1.0
; Last Updated:   13/03/2025
;==================================================================================================================

; ==================== Game States ====================
class GameState {
    static MAIN_MENU := "MAIN_MENU"
    static STORY := "STORY"
    static ROBOT_CUSTOMIZATION := "ROBOT_CUSTOMIZATION"
    static BATTLE_SELECTION := "BATTLE_SELECTION"
    static BATTLE := "BATTLE"
    static INVENTORY := "INVENTORY"
    static GAME_OVER := "GAME_OVER"
    static VICTORY := "VICTORY"
    static SETTINGS := "SETTINGS"
}