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

public protocol InputOperationProtocol {
    associatedtype Input
    @discardableResult
    func injectValue<O>(from outputOperation: O, executeOnlyWhenSuccessful: Bool) -> Self where O: OutputOperation, O.Output == Input
}

open class InputOperation<Input>: ANOperation, InputOperationProtocol {
    
    typealias PassDataBlock = () -> ValueState<Input>
    
    private var inputValue: ValueState<Input> = .pending
    
    private var sourceOperations: [ANOperation] = []
    
    private var passDataBlock: PassDataBlock?
    
    private let block: ((Input) -> Void)?
    
    public init<O>(name: String, outputOperation: O, executeOnlyWhenSuccessful: Bool) where O: OutputOperation, O.Output == Input {
        self.block = nil
        super.init(name: name)
        self.injectValue(from: outputOperation, executeOnlyWhenSuccessful: executeOnlyWhenSuccessful)
    }
    
    public override init(name: String) {
        self.block = nil
        super.init(name: name)
    }
    
    public init(name: String, block: @escaping (Input) -> Void) {
        self.block = block
        super.init(name: name)
    }
    
    override open func execute() {
        guard let inputValue = self.getInputValue() else {
            guard !self.isFinished else { return } //The operation might have already been finished with dependency errors after passDataBlock is executed
            self.finishWithError(OperationError(.inputValueNotSet))
            return
        }
        self.execute(with: inputValue)
    }
    
    public func getInputValue() -> Input? {
        return self.passDataBlock?().get() ?? self.inputValue.get()
    }
    
    public func setInputValue(to value: Input) {
        self.inputValue = .ready(value)
    }
    
    open func execute(with value: Input) {
        guard let block = block else {
            print("\(self.name ?? String(describing: self)) Needs Implementation")
            finish()
            return
        }
        block(value)
        self.finish()
    }
    
    @discardableResult
    public func injectValue<O>(from outputOperation: O, executeOnlyWhenSuccessful: Bool) -> Self where O: OutputOperation, O.Output == Input {
        self.passDataBlock = { [weak self, weak outputOperation] in
            self!.log(stage: .injecting(from: outputOperation!.name ?? String(describing: outputOperation!)))
            if outputOperation!.isCancelled {
                self!.cancel()
            } else if outputOperation!.errors.count > 0 && executeOnlyWhenSuccessful {
                self!.finish(outputOperation!.errors)
            }
            return outputOperation!.outputValue
        }
        self.addDependency(outputOperation)
        return self
    }
    
    @discardableResult
    public func injectValue<O>(from outputOperation: O) -> Self where O: OutputOperation, Input == Optional<O.Output> {
        self.passDataBlock = { [weak self, weak outputOperation] in
            self!.log(stage: .injecting(from: outputOperation!.name ?? String(describing: outputOperation!)))
            if outputOperation!.isCancelled {
                self!.cancel()
            } else if outputOperation!.errors.count > 0 {
                return .ready(nil)
            }
            return .ready(outputOperation!.outputValue.get())
        }
        self.addDependency(outputOperation)
        return self
    }
    
    internal func addSource(_ operation: ANOperation) {
        
        self.addDependency(operation)
    }
    
    override public func didEnqueue(in queue: ANOperationQueue) {
        //Extract dependencies that haven't been added to the queue
        //(e.g. when transformation methods such as 'map' is used)
        sourceOperations.forEach{ queue.addOperation($0) }
        super.didEnqueue(in: queue)
    }
    
    @discardableResult
    public func injectingValue(_ value: Input) -> Self {
        let name = "\(self.name ?? "") injector of \(type(of: value))"
        let injector = InjectorOperation(name: name, value: value)
        self.sourceOperations.append(injector)
        self.injectValue(from: injector, executeOnlyWhenSuccessful: false)
        return self
    }

}
