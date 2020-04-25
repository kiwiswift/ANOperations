//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 10/02/20.
//

open class InputOutputOperation<Input, Output>: InputOperation<Input>, OutputOperation {
    
    public var outputValue: ValueState<Output> = .pending
    
    @discardableResult
    func onSuccess(executeBlock block: @escaping (Output) -> Void) -> Self {
        let observer = BlockObserver { [weak self] _, errors in
            if let value = self?.outputValue.get() {
                block(value)
            }
        }
        self.addObserver(observer)
        return self
    }

    @discardableResult
    func onCompletion(executeBlock block: @escaping (Output?, [Error]?) -> Void) -> Self {
        let observer = BlockObserver { operation, errors in
            guard let operation = operation as? Self, !operation.isCancelled else { return }
            let errorsCount = errors.count
            block(operation.outputValue.get(), errorsCount > 0 ? errors : nil)
        }
        self.addObserver(observer)
        return self
    }
    
}

