//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

public protocol OutputOperation: ANOperation {
    
    associatedtype Output
    var outputValue: ValueState<Output> { get set }
//    var outputResult: Result<Output, Error>? { get }
    
    func finish(with value: Output)
    
}

public extension OutputOperation {
    
    func finish(with value: Output) {
        self.outputValue = .ready(value)
        self.finish()
    }
    
    func finish(with result: Result<Output, Error>) {
        switch result {
        case let .success(value): self.finish(with: value)
        case let .failure(error): self.finishWithError(error)
        }
        self.finish()
    }
    
    func finish(value: Output?, errors: [Error]?) {
        if let errors = errors, errors.count > 0 {
            self.finish(errors)
        } else if let value = value {
            self.finish(with: value)
        } else {
            self.finish()
        }
    }
    
    func finish(catching block: @autoclosure () throws -> Output) {
        do {
            let output = try block()
            self.finish(with: output)
        } catch {
            self.finishWithError(error)
        }
    }
    
}

public extension OutputOperation {
    
//    func then<Input>(execute operation: InputOperation<Input>, onlyIfSuccessful: Bool) -> [ANOperation] where Input == Output {
//        operation.injectValue(from: self, executeOnlyWhenSuccessful: onlyIfSuccessful)
//        return [self, operation]
//    }
    
    func map<I, O>(_ transform: @escaping (I) -> O) -> ResultOperation<O> where I == Self.Output {
        let resultOperation = ResultOperation<O> { [weak self] in
            guard let outputValue = self?.outputValue.get() else {
                if let error = self?.errors.first {
                    return .failure(error)
                } else {
                    return .failure(OperationError(.inputValueNotSet))
                }
            }
            let returnValue = transform(outputValue)
            return .success(returnValue)
        }
        if let name = self.name {
            resultOperation.name = "Result of \(name)"
        }
        resultOperation.addSource(self)
        return resultOperation
    }
    
    func bindOutput<O: OutputOperation>(toResultOf outputOperation: O) where O.Output == Self.Output {
        let observer = BlockObserver { [weak self] (operation, errors) in
            guard let strongSelf = self else { fatalError() }
            strongSelf.outputValue = outputOperation.outputValue
            strongSelf.finish()
        }
        self.addObserver(observer)
    }
    
    
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
    func onFailure(executeBlock block: @escaping ([Error]) -> Void) -> Self {
        let observer = BlockObserver { _, errors in
            block(errors)
        }
        self.addObserver(observer)
        return self
    }

    func onCompletion<Input>(executeBlock block: @escaping (Output?, [Error]?) -> Void) -> Self where Output == Input {
        let observer = BlockObserver { [weak self] _, errors in
            block(self?.outputValue.get(), self?.errors)
        }
        self.addObserver(observer)
        return self
    }

    @discardableResult
    func bindOutputValue(toValueOf block:  @escaping @autoclosure () -> Output) -> Self {
        self.addObserver(BlockObserver(finishHandler: { [weak self] _, _ in
            self?.outputValue = .ready(block())
        }))
        return self
    }
    
}

