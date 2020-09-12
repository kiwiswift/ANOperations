//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 23/02/20.
//

import Foundation
import os

class Log {
    
    enum Stage {
        case state(State)
        case enqueuing
        case injecting(from: String)
        case deinitialising
        case finishedWithError
        case cancelled
        case notDeinitialised
        
        var description: String {
            switch self {
            case let .state(state):
                switch state {
                case .initialized           : return "initialized"
                case .evaluatingConditions  : return "evaluatingConditions"
                case .executing             : return "executing"
                case .finished              : return "finished"
                case .finishing             : return "finishing"
                case .ready                 : return "ready"
                case .pending               : return "pending"
                }
            case .cancelled                 : return "Cancelled"
            case .enqueuing                 : return "Enqueueing"
            case .injecting(let operation)  : return "Injecting from \(operation)"
            case .deinitialising            : return "Deinitialising"
            case .finishedWithError         : return "Failed"
            case .notDeinitialised          : return "Retained In Memory"
            }
        }
        
        var symbol: String {
            switch self {
            case let .state(state):
                switch state {
                case .initialized           : return "⚙️"
                case .evaluatingConditions  : return "🔬"
                case .executing             : return "🛠"
                case .finished              : return "✅"
                case .finishing             : return "🏁"
                case .ready                 : return "🎬"
                case .pending               : return "⌛️"
                }
            case .cancelled                 : return "❌"
            case .enqueuing                 : return "📥"
            case .deinitialising            : return "👻"
            case .finishedWithError         : return "🛑"
            case .injecting                 : return "🔗"
            case .notDeinitialised          : return "💦"
            }
        }
        
        var finished: Bool {
            switch self {
            case .finishedWithError,
                 .cancelled:
                return true
            case .state(let state):
                switch state {
                case .finished:
                    return true
                default: return false
                }
            default: return false
            }
        }
    }
    
    static var active: Bool = false
    
    /*static let queue = DispatchQueue(label: "com.kiwiswift.ANOperations.Log", attributes: .concurrent)
    static var _activeOperations: [Int:Stage] = [:]
    static var activeOperations: [Int:Stage] {
        get { queue.sync { _activeOperations } }
        set { queue.sync { _activeOperations = newValue } }
    }*/
    
    static func write(name: String, hashValue: Int, stage: Stage, errors: [Error]?) {
        
        let identifier = "\(hashValue)-\(name)"//.padding(toLength: 100, withPad: " ", startingAt: 0)
        var message = "\(identifier) \(stage.description)"
        /*self.activeOperations[hashValue] = stage
        switch stage {
        case .state(let state):
            if case State.initialized = state {
//                self.activeOperations[hashValue] =
            }
        default:
            if case Stage.deinitialising = stage {
                self.activeOperations.removeValue(forKey: hashValue)
                message += " (\(self.activeOperations.count ) on heap)"
            }
        }*/
        
        var symbol: String
        var logType: OSLogType
        if let errors = errors, errors.count > 0, stage.finished {
            let errorDescriptions = errors.map{ String(describing: $0) }.joined(separator: "\n")
            message += " with \(errors.count) errors : \(errorDescriptions)"
            symbol = Log.Stage.finishedWithError.symbol
            logType = .error
        } else {
            symbol = stage.symbol
            logType = .debug
        }
        let logString = "[ANOperation] \(symbol) - \(message)"
        let logObj = OSLog(subsystem: "com.kiwiswift.anoperations", category: name)
        #if DEBUG
        debugPrint(logString)
        #else
        os_log("%{public}@", log: logObj, type: logType, logString )
        #endif
    }
    
    
}

extension ANOperation {
    
    public static var log: Bool {
        get { Log.active }
        set { Log.active = newValue }
    }
    
    func log(stage: Log.Stage) {
        guard log else { return }
        let text = "\(name ?? "Operation")"
        Log.write(name: text, hashValue: self.hash, stage: stage, errors: self.errors)
    }
    
    func log(state: State) {
        guard log else { return }
        let stage = Log.Stage.state(state)
        let text = "\(name ?? "Operation")"
        Log.write(name: text, hashValue: self.hash, stage: stage, errors: self.errors)
    }
    
}
