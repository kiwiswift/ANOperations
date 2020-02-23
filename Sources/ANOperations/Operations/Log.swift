//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 23/02/20.
//

class Log {
    
    static var active: Bool = false
    
    static func write(name: String, state: State, errors: [Error]?) {
        var message = "[ANOperation] \(name) \(state)"
        if let errors = errors, errors.count > 0 {
            let errorDescriptions = errors.map{ $0.localizedDescription }.joined(separator: "\n")
            message += "with \(errors.count) errors : \(errorDescriptions)"
        }
        print(message)
    }
    
    
}

extension ANOperation {
    
    public static var log: Bool {
        get { Log.active }
        set { Log.active = newValue }
    }
    
    func log(state: State) {
        guard log else { return }
        Log.write(name: self.name ?? "Operation", state: state, errors: self.errors)
    }
    
}
