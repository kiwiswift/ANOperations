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
    
    typealias PassDataBlock = () -> ValueState<Input>
    
    public var inputValue: ValueState<Input> = .pending
    
    private var passDataBlock: PassDataBlock?
    
    public init<O>(outputOperation: O, executeOnlyWhenSuccessful: Bool) where O: OutputOperation, O.Output == Input {
        super.init()
        self.injectValue(from: outputOperation, executeOnlyWhenSuccessful: executeOnlyWhenSuccessful)
    }
    
    override public init() {
        super.init()
    }
    
    override open func execute() {
        guard let inputValue = self.passDataBlock?().get() ?? self.inputValue.get() else {
            guard !self.isFinished else { return } //The operation might have already been finished with dependency errors after passDataBlock is executed
            self.finishWithError(OperationError(.inputValueNotSet))
            return
        }
        self.execute(with: inputValue)
    }
    
    open func execute(with value: Input) {
        fatalError("Needs Implementation")
    }
    
    @discardableResult
    public func injectValue<O>(from outputOperation: O, executeOnlyWhenSuccessful: Bool) -> Self where O: OutputOperation, O.Output == Input {
        self.passDataBlock = { [weak self] in
            if outputOperation.errors.count > 0 && executeOnlyWhenSuccessful {
                self?.finish(outputOperation.errors)
            }
            return outputOperation.outputValue
        }
        self.addDependency(outputOperation)
        return self
    }

}
