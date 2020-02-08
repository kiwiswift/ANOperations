//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

public protocol OutputOperation: ANOperation {
    
    associatedtype Output
    var outputValue: ValueState<Output> { get set }
    var outputResult: Result<Output, Error>? { get }
    
    func finish(with value: Output)
    
}

public extension OutputOperation {
    
    var outputResult: Result<Output, Error>? {
        if let value = outputValue.get() {
            return .success(value)
        } else if errors.count > 0 { //TODO: Create an error object and wrap all error ocurrencies as underlying errors
            return .failure(self.errors.first!)
        }
        return nil
    }

    func finish(with value: Output) {
        self.outputValue = .ready(value)
        self.finish()
    }
    
}

extension Result {
    
    init(_ value: Success, _ error: Failure?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(value)
        }
    }
    
}
