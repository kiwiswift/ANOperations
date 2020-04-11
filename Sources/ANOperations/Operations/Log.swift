//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 23/02/20.
//

class Log {
    
    enum Stage {
        case state(State)
        case enqueuing
        case deinitialising
        case finishedWithError
        
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
            case .enqueuing                 : return "Enqueueing"
            case .deinitialising            : return "Deinitialising"
            case .finishedWithError         : return "Failed"
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
            case .enqueuing                 : return "📥"
            case .deinitialising            : return "👻"
            case .finishedWithError         : return "🛑"
            }
        }
    }
    
    static var active: Bool = false
    
    static func write(name: String, stage: Stage, errors: [Error]?) {
        var message = "\(name) \(stage.description)"
        if let errors = errors, errors.count > 0 {
            let errorDescriptions = errors.map{ String(describing: $0) }.joined(separator: "\n")
            message += " with \(errors.count) errors : \(errorDescriptions)"
            print("[ANOperation] \(Log.Stage.finishedWithError.symbol) " + message)
        } else {
            print("[ANOperation] \(stage.symbol) " + message)
        }
    }
    
    
}

extension ANOperation {
    
    public static var log: Bool {
        get { Log.active }
        set { Log.active = newValue }
    }
    
    func log(stage: Log.Stage) {
        guard log else { return }
        Log.write(name: self.name ?? "Operation", stage: stage, errors: self.errors)
    }
    
    func log(state: State) {
        guard log else { return }
        let stage = Log.Stage.state(state)
        Log.write(name: self.name ?? "Operation", stage: stage, errors: self.errors)
    }
    
}
