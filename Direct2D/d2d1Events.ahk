;==================================================================================================================
; Direct2D Event System
;==================================================================================================================
; Description:    Event handling system for the Direct2D library
;                 Provides a flexible event registration and triggering mechanism
;
; Features:       - Event registration and removal
;                 - Event triggering with arguments
;                 - Support for multiple handlers per event
;                 - Handler prioritization
;
; Usage:          events := D2D1EventSystem()
;                 events.on("eventName", callbackFunction)
;                 events.trigger("eventName", arg1, arg2)
;
; Dependencies:   - AutoHotkey v2.0+
;
; Author:         CasperHarkin
; Version:        1.0.0
; Last Updated:   10/03/2025
;==================================================================================================================

#Requires AutoHotkey v2.0

/**
 * Event system for Direct2D library
 * Provides a flexible event registration and triggering mechanism
 */
class D2D1EventSystem {
    ; Store event handlers
    _eventHandlers := Map()
    
    /**
     * Add an event handler
     * @param {String} eventName - Event name
     * @param {Function} handler - Event handler function
     * @param {Integer} priority - Handler priority (higher numbers execute first)
     * @returns {Integer} Handler ID for later removal
     */
    on(eventName, handler, priority := 0) {
        if (!this._eventHandlers.Has(eventName))
            this._eventHandlers[eventName] := []
            
        ; Generate a unique handler ID
        handlerId := this._generateHandlerId()
        
        ; Add the handler to the event list
        this._eventHandlers[eventName].Push({
            id: handlerId,
            fn: handler,
            priority: priority
        })
        
        ; Sort handlers by priority (higher numbers first)
        this._sortHandlers(eventName)
        
        return handlerId
    }
    
    /**
     * Remove an event handler
     * @param {String} eventName - Event name
     * @param {Integer} handlerId - Handler ID returned from on() method
     * @returns {Boolean} True if handler was removed, false otherwise
     */
    off(eventName, handlerId) {
        if (!this._eventHandlers.Has(eventName))
            return false
            
        for i, handler in this._eventHandlers[eventName] {
            if (handler.id = handlerId) {
                this._eventHandlers[eventName].RemoveAt(i)
                return true
            }
        }
        
        return false
    }
    
    /**
     * Remove all handlers for an event
     * @param {String} eventName - Event name
     * @returns {Boolean} True if handlers were removed, false if event doesn't exist
     */
    offAll(eventName) {
        if (!this._eventHandlers.Has(eventName))
            return false
            
        this._eventHandlers.Delete(eventName)
        return true
    }
    
    /**
     * Trigger an event
     * @param {String} eventName - Event name
     * @param {Any} args - Arguments to pass to the handlers
     * @returns {Integer} Number of handlers triggered
     */
    trigger(eventName, args*) {
        if (!this._eventHandlers.Has(eventName))
            return 0
            
        count := 0
        for handler in this._eventHandlers[eventName] {
            try {
                handler.fn(args*)
                count++
            } catch as e {
                ; Log error but continue with other handlers
                OutputDebug("Error in event handler for " eventName ": " e.Message)
            }
        }
        
        return count
    }
    
    /**
     * Check if an event has any handlers
     * @param {String} eventName - Event name
     * @returns {Boolean} True if event has handlers, false otherwise
     */
    hasHandlers(eventName) {
        return this._eventHandlers.Has(eventName) && this._eventHandlers[eventName].Length > 0
    }
    
    /**
     * Get the number of handlers for an event
     * @param {String} eventName - Event name
     * @returns {Integer} Number of handlers
     */
    handlerCount(eventName) {
        if (!this._eventHandlers.Has(eventName))
            return 0
            
        return this._eventHandlers[eventName].Length
    }
    
    /**
     * List all registered event names
     * @returns {Array} Array of event names
     */
    listEvents() {
        events := []
        for eventName in this._eventHandlers
            events.Push(eventName)
        return events
    }
    
    /**
     * Generate a unique handler ID
     * @returns {Integer} Unique handler ID
     * @private
     */
    _generateHandlerId() {
        static nextId := 1
        return nextId++
    }
    
    /**
     * Sort handlers for an event by priority
     * @param {String} eventName - Event name
     * @private
     */
    _sortHandlers(eventName) {
        if (!this._eventHandlers.Has(eventName))
            return
            
        ; Sort by priority (higher numbers first)
        ; Create a new sorted array since AutoHotkey v2 arrays don't have a Sort method
        handlers := this._eventHandlers[eventName]
        sortedHandlers := []
        
        ; First, create a temporary array with indices for sorting
        tempArray := []
        for i, handler in handlers
            tempArray.Push({index: i, priority: handler.priority})
        
        ; Sort the temporary array by priority (bubble sort)
        n := tempArray.Length
        Loop n-1 {
            i := A_Index - 1
            Loop n-1-i {
                j := A_Index - 1
                if (tempArray[j+1].priority < tempArray[j+2].priority) {
                    ; Swap
                    temp := tempArray[j+1]
                    tempArray[j+1] := tempArray[j+2]
                    tempArray[j+2] := temp
                }
            }
        }
        
        ; Create the sorted handlers array
        for item in tempArray
            sortedHandlers.Push(handlers[item.index])
        
        ; Replace the original array with the sorted one
        this._eventHandlers[eventName] := sortedHandlers
    }
}