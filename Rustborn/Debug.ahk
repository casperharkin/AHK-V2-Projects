;==================================================================================================================
; Debug Module
;==================================================================================================================
; Description:    A module for logging debug messages to a markdown file
;                 Provides clean, formatted logs with categories and timestamps
;
; Features:       - Formatted markdown logging
;                 - Categorized log entries with emojis
;                 - Timestamp for each log entry
;                 - Prevents duplicate message spam
;
; Usage:          Include this file and call Debug() with message and category
;                 Example: Debug("Game state changed", "STATE")
;
; Dependencies:   - AutoHotkey v2.0
;
; Author:         CasperHarkin
; Version:        1.1.0
; Last Updated:   12/03/2025
;==================================================================================================================

; ==================== Debug Function ====================
Debug(message, category := "INFO") {
    static logFile := A_ScriptDir "\Log.txt"
    static lastMessage := ""
    static lastCategory := ""
    static repeatCount := 0
    static categories := Map(
        "INFO", "ℹ️",
        "WARN", "⚠️",
        "ERROR", "❌",
        "SUCCESS", "✅",
        "STATE", "🔄",
        "BATTLE", "⚔️",
        "ROBOT", "🤖",
        "EVENT", "📢"
    )
    
    ; Check if this is a repeat of the last message
    if (message == lastMessage && category == lastCategory) {
        repeatCount++
        ; Only log repeats occasionally to avoid spam
        if (repeatCount <= 1 || Mod(repeatCount, 10) == 0) {
            ; Format the repeat message
            repeatMsg := message " (repeated " repeatCount " times)"
            ; Output to debug console
            OutputDebug(repeatMsg)
        }
        return ; Skip logging to file for repeats
    }
    
    ; If we had repeats before this new message, log the final count
    if (repeatCount > 1) {
        timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
        emoji := categories.Has(lastCategory) ? categories[lastCategory] : categories["INFO"]
        repeatEntry := "**" timestamp "** " emoji " `[" lastCategory "`] " lastMessage " _(repeated " repeatCount " times)_`n"
        
        ; Append repeat summary to file
        if (FileExist(logFile))
            FileAppend(repeatEntry, logFile)
    }
    
    ; Reset tracking for new message
    lastMessage := message
    lastCategory := category
    repeatCount := 1
    
    ; Format timestamp
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    
    ; Get emoji for category or default to INFO
    emoji := categories.Has(category) ? categories[category] : categories["INFO"]
    
    ; Format the log entry in markdown
    logEntry := "**" timestamp "** " emoji " `[" category "`] " message "`n"
    
    ; Create file if it doesn't exist
    if (!FileExist(logFile)) {
        FileAppend("# Robot Battle Game Log`n`n", logFile)
    }
    
    ; Append log entry to file
    FileAppend(logEntry, logFile)
    
    ; Also output to debug console for immediate feedback
    OutputDebug(message)
}