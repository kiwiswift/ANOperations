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
    
    public var inputValue: ValueState<Input> = .pending
    
    var passDataBlock: PassDataBlock
    
    public init<O>(outputOperation: O) where O: OutputOperation, O.Output == Input {
        self.passDataBlock = { }
        super.init()
        self.passDataBlock = { [weak self] in
            if let outputValue = outputOperation.outputValue.get() {
                self?.inputValue = .ready(outputValue)
            } else if outputOperation.errors.count > 0 {
                self?.finish(outputOperation.errors)
            }
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
