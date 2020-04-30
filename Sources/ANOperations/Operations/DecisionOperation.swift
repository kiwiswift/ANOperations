//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 28/04/20.
//

class DecisionOperation<T>: InputOutputOperation<T,T> {
    
    private let block: (T) -> Bool
    private var onTrueBlock: ((T) -> Void)?
    private var onFalseBlock: ((T) -> Void)?
    
    
    init(name: String = "DecisionOperation", block: @escaping (T) -> Bool) {
        self.block = block
        super.init(name: name)
    }
    
    override func execute(with value: T) {
        let result = block(value)
        if result {
            self.onTrueBlock?(value)
        } else {
            self.onFalseBlock?(value)
        }
        self.finish(with: value)
    }
    
    @discardableResult
    func onTrue(execure block: @escaping (T) -> Void) -> Self {
        self.onTrueBlock = block
        return self
    }
    
    @discardableResult
    func onTrue<I>(execute operation: I) -> Self where I: ANOperation, I: InputOperationProtocol, I.Input == T {
        self.onTrueBlock = { [weak self] _ in
            guard let stongSelf = self else { return }
            stongSelf.produceOperation(operation.injectValue(from: stongSelf, executeOnlyWhenSuccessful: true))
        }
        return self
    }
    
    func onFalse(execute block: @escaping (T) -> Void) -> Self {
        self.onFalseBlock = block
        return self
    }
    
    @discardableResult
    func onFalse<I>(execute operation: I) -> Self where I: ANOperation, I: InputOperationProtocol, I.Input == T {
        self.onFalseBlock = { [weak self] _ in
            guard let stongSelf = self else { return }
            stongSelf.produceOperation(operation.injectValue(from: stongSelf, executeOnlyWhenSuccessful: true))
        }
        return self
    }
    
}
