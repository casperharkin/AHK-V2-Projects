#Requires AutoHotkey v2
#SingleInstance Force
#ErrorStdOut

;==================================================================================================================
; RecentFilesViewer
;==================================================================================================================
; Description:    A utility class that displays and manages a GUI for accessing recently used files in Windows.
;                 Provides functionality to view, open, and manage recent files with various operations.
;
; Features:       - Retrieves recent files from Windows' Recent Items folder
;                 - Displays files in a customizable ListView interface
;                 - Supports file operations: open file, open containing folder
;                 - Copy file/folder paths to clipboard
;                 - Context menu for additional operations
;                 - Translucent GUI with keyboard navigation
;                 - Toggle visibility with hotkey (default: q)
;
; Usage:          Simply instantiate the class to activate:
;                 RecentFilesViewer()
;
; Hotkeys:        q - Toggle the Recent Files Viewer GUI
;                 Shift+Click - Copy folder path to clipboard
;                 Double-click - Open selected file
;                 Right-click - Show context menu
;                 Escape - Close the GUI
;
; Dependencies:   - Windows COM objects for accessing Recent Items
;                 - AutoHotkey v2
;
; Author:         CasperHarkin
; Version:        1.0
; Last Updated:   08/03/2025
;==================================================================================================================


RecentFilesViewer()

class RecentFilesViewer {
    ; Configuration properties
    MaxFilesToShow := 20
    WindowTitle := "Recent Files"
    ListWidth := 700
    ListHeight := 400
    FontSize := 10
    
    ; GUI elements
    Gui := ""
    LvFiles := ""
    RecentFiles := []
    static IsOpen := false
    
    __New() {
        this.SetupHotkeys()
        this.ShowRecentFiles()
    }
    
    SetupHotkeys() {
        HotKey("q", this.ShowRecentFiles.Bind(this))
    }
    
    ; ==================== Windows Integration Functions ====================
    GetRecentFolder() => ComObject("Shell.Application").NameSpace(8).Self.Path ; 8 = Recent Items
    
    ResolveShortcut(shortcutPath) => ComObject("WScript.Shell").CreateShortcut(shortcutPath).TargetPath
    
    GetRecentFiles(maxFiles) {
        recentFiles := []
        shortcutFiles := Map()
        
        recentFolder := this.GetRecentFolder()
        
        if (!FileExist(recentFolder))
            return recentFiles
        
        ; Process all .lnk files in the Recent folder
        loop files, recentFolder . "\*.lnk" {
            fullPath := A_LoopFileFullPath
            targetPath := this.ResolveShortcut(fullPath)
            
            if (targetPath && FileExist(targetPath) && !InStr(FileExist(targetPath), "D")) {
                modTime := FileGetTime(fullPath)
                shortcutFiles[modTime] := {path: targetPath}
            }
        }
        
        ; Sort by modification time (newest first)
        modTimes := []
        for time, _ in shortcutFiles
            modTimes.Push(time)
        
        ; Sort descending (newest first)
        this.SortModTimes(modTimes)
        
        ; Add files to our list (up to maxFiles)
        count := 0
        for _, modTime in modTimes {
            if (++count > maxFiles)
                break
                
            filePath := shortcutFiles[modTime].path
            fileInfo := this.ParseFilePath(filePath)
            recentFiles.Push(fileInfo)
        }
        
        return recentFiles
    }
    
    ; Sort modification times in descending order (newest first)
    SortModTimes(times) {
        ; Simple bubble sort implementation for descending order
        n := times.Length
        Loop n {
            i := A_Index
            Loop n - i {
                j := A_Index
                ; Compare in descending order (newer dates first)
                if (StrCompare(times[j], times[j + 1]) < 0) {
                    ; Swap elements
                    temp := times[j]
                    times[j] := times[j + 1]
                    times[j + 1] := temp
                }
            }
        }
        return times
    }
    
    ; Extract filename and folder path from a full path
    ParseFilePath(filePath) {
        lastSlash := InStr(filePath, "\", , -1)
        if (lastSlash > 0) {
            fileName := SubStr(filePath, lastSlash + 1)
            folderPath := SubStr(filePath, 1, lastSlash - 1)
        } else {
            fileName := filePath
            folderPath := ""
        }
        
        return {name: fileName, path: filePath, folder: folderPath}
    }
    
    ; ==================== GUI Functions ====================
    CreateRecentFilesGUI() {
        ; Get recent files data
        this.RecentFiles := this.GetRecentFiles(this.MaxFilesToShow)
        
        if (!this.RecentFiles.Length) {
            MsgBox("No recent files found.")
            return
        }
        
        ; Create GUI
        this.Gui := Gui("+Resize +AlwaysOnTop -Caption -ToolWindow", this.WindowTitle)
        this.Gui.SetFont("s" . this.FontSize)
        
        ; Create ListView for files
        this.LvFiles := this.Gui.Add("ListView", "r20 -Multi w" . this.ListWidth . " h" . this.ListHeight, ["Filename", "Folder Path", "Full Path"])
        
        ; Configure columns
        this.ConfigureListView()
        
        ; Set up event handlers
        this.SetupGuiEvents()
        
        ; Populate the ListView
        this.PopulateListView()
        
        ; Show the GUI
        this.Gui.Show()
        
        ; Make the GUI translucent (78% opacity)
        WinSetTransparent(200, "ahk_id " this.Gui.Hwnd)
        
        ; Select the first item
        this.LvFiles.Modify(1, "Select Focus")
    }
    
    ConfigureListView() {
        ; Hide the Full Path column (used for storing the path)
        this.LvFiles.ModifyCol(3, 0)
        
        ; Set column widths
        this.LvFiles.ModifyCol(1, 200)
        this.LvFiles.ModifyCol(2, 300)
    }
    
    SetupGuiEvents() {
        ; ListView events
        this.LvFiles.OnEvent("DoubleClick", this.OpenFile.Bind(this))
        this.LvFiles.OnEvent("Click", this.HandleClick.Bind(this))
        this.LvFiles.OnEvent("ContextMenu", this.ShowContextMenu.Bind(this))
        
        ; GUI events
        this.Gui.OnEvent("Close", this.CloseGui.Bind(this))
        this.Gui.OnEvent("Escape", this.CloseGui.Bind(this))
    }
    
    PopulateListView() {
        ; Clear the ListView
        this.LvFiles.Delete()
        
        ; Add each file to the ListView
        for i, fileInfo in this.RecentFiles {
            fileName := fileInfo.name
            folderPath := fileInfo.folder
            filePath := fileInfo.path
            this.LvFiles.Add("", fileName, folderPath, filePath)
        }
    }
    
    ; Get the path of the selected file
    GetSelectedFilePath() {
        row := this.LvFiles.GetNext(0, "Focused")
        if (!row)
            return ""
        
        return this.LvFiles.GetText(row, 3)  ; Get text from the hidden Full Path column
    }
    
    ; Show context menu for right-click
    ShowContextMenu(*) {
        filePath := this.GetSelectedFilePath()
        if (!filePath)
            return
            
        ; Create context menu
        contextMenu := Menu()
        contextMenu.Add("Open File", this.OpenFile.Bind(this))
        contextMenu.Add("Open Containing Folder", this.OpenContainingFolder.Bind(this))
        contextMenu.Add("Copy File Path to Clipboard", this.CopyPathToClipboard.Bind(this))
        contextMenu.Add("Copy Folder Path to Clipboard", this.CopyFolderPathToClipboard.Bind(this))
        contextMenu.Add("Close", this.CloseGui.Bind(this))
        
        ; Show the menu at cursor position
        contextMenu.Show()
    }
    
    ; ==================== File Operation Functions ====================
    OpenFile(*) {
        filePath := this.GetSelectedFilePath()
        if (!filePath)
            return
        
        ; Check if file still exists
        if (!FileExist(filePath)) {
            MsgBox("File no longer exists:`n" . filePath)
            return
        }
        
        ; Open the file with its default application
        Run(filePath)
        ; Close the GUI after opening the file
        this.CloseGui()
    }
    
    ; Open the containing folder of the selected file
    OpenContainingFolder(*) {
        filePath := this.GetSelectedFilePath()
        if (!filePath)
            return
        
        fileInfo := this.ParseFilePath(filePath)
        fileDir := fileInfo.folder
        
        ; Check if directory exists
        if (!FileExist(fileDir)) {
            MsgBox("Folder no longer exists:`n" . fileDir)
            return
        }
        
        ; Open the folder
        Run("explorer.exe `"" . fileDir . "`"")
        ; Close the GUI after opening the folder
        this.CloseGui()
    }
    
    ; Copy the path of the selected file to clipboard
    CopyPathToClipboard(*) {
        filePath := this.GetSelectedFilePath()
        if (!filePath)
            return
        
        ; Copy to clipboard
        A_Clipboard := filePath
        
        ; Show a tooltip
        this.ShowTooltip("File path copied to clipboard")
        
        ; Close the GUI after copying
        this.CloseGui()
    }
    
    ; Copy the folder path of the selected file to clipboard
    CopyFolderPathToClipboard(*) {
        filePath := this.GetSelectedFilePath()
        if (!filePath)
            return
        
        fileInfo := this.ParseFilePath(filePath)
        folderPath := fileInfo.folder
        
        ; Copy to clipboard
        A_Clipboard := folderPath
        
        ; Show a tooltip
        this.ShowTooltip("Folder path copied to clipboard")
        
        ; Close the GUI after copying
        this.CloseGui()
    }
    
    ; Display a tooltip that automatically disappears
    ShowTooltip(message, duration := 1000) {
        ToolTip(message)
        SetTimer(() => ToolTip(), -duration)
    }
    
    ; Close the GUI and set IsOpen to false
    CloseGui(*) {
        this.Gui.Destroy()
        RecentFilesViewer.IsOpen := false
    }
    
    ; Handle click events on the ListView
    HandleClick(LV, RowNumber) {
        ; Check if Shift key is pressed
        if (GetKeyState("Shift")) {
            filePath := this.GetSelectedFilePath()
            if (!filePath)
                return
            
            fileInfo := this.ParseFilePath(filePath)
            folderPath := fileInfo.folder
            
            ; Copy to clipboard
            A_Clipboard := folderPath
            
            ; Show a tooltip
            this.ShowTooltip("Folder path copied to clipboard")
            
            ; Close the GUI after copying
            this.CloseGui()
        }
    }
    
    ; Toggle the recent files GUI (show if hidden, hide if visible)
    ShowRecentFiles(*) {
        ; Check if GUI is already open
        if (RecentFilesViewer.IsOpen && IsObject(this.Gui) && WinExist("ahk_id " this.Gui.Hwnd)) {
            this.CloseGui()
            return
        }
        
        ; Create and show the GUI
        this.CreateRecentFilesGUI()
        RecentFilesViewer.IsOpen := true
    }
}