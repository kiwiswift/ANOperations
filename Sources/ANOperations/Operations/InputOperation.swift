//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

import Foundation

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
    
    private var passDataBlock: PassDataBlock = { }
    
    public init<O>(outputOperation: O) where O: OutputOperation, O.Output == Input {
        super.init()
        self.bindValue(from: outputOperation)
        self.addDependency(outputOperation)
    }
    
    override public init() {
        super.init()
    }
    
    public func bindValue<O>(from outputOperation: O) where O: OutputOperation, O.Output == Input {
        self.passDataBlock = { [weak self] in
            if let outputValue = outputOperation.outputValue.get() {
                self?.inputValue = .ready(outputValue)
            } else if outputOperation.errors.count > 0 {
                self?.finish(outputOperation.errors)
            }
        }
    }
    
    public func bindingValue<O>(from outputOperation: O) -> Self where O: OutputOperation, O.Output == Input {
        self.bindValue(from: outputOperation)
        return self
    }
    
    public func injectValue<O>(from operation: O, block: @escaping (O) -> Input) where O: Operation {
        self.passDataBlock = { [weak self] in
            self?.inputValue = .ready(block(operation))
        }
    }
    
    override func operationDidStart() {
        do {
            try passDataBlock()
        } catch {
            finishWithError(error)
        }
    }
}
