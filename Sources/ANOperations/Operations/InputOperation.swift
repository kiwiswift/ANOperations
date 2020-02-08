//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

public enum ValueState<T> {
    case pending
    case ready(T)
    
    public func get() -> T? {
        guard case let .ready(value) = self else { return nil }
        return value
    }
}

open class InputOperation<Input>: ANOperation {
    
    typealias PassDataBlock = () throws -> Void
    
    var inputValue: ValueState<Input> = .pending
    
    var passDataBlock: PassDataBlock
    
    public init<O>(outputOperation: O) where O: OutputOperation, O.Output == Input {
        self.passDataBlock = { }
        super.init()
        self.passDataBlock = { [weak self] in
            guard let outputValue = try outputOperation.outputResult?.get() else {
                self?.finish() //TODO: when value doesn't exist in Output Result, do we really want to finish the operation without an error?
                return
            }
            self?.inputValue = .ready(outputValue)
        }
        self.addDependency(outputOperation)
    }
    
    override func operationDidStart() {
        do {
            try passDataBlock()
        } catch {
            finishWithError(error)
        }
    }
}

open class InputOutputOperation<Input, Output>: InputOperation<Input>, OutputOperation {
    
    public var outputValue: ValueState<Output> = .pending
    
}
