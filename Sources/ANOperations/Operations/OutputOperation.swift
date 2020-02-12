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
    
//    var outputResult: Result<Output, Error>? {
//        get {
//            if let value = outputValue.get() {
//                return .success(value)
//            } else if errors.count > 0 { //TODO: Create an error object and wrap all error ocurrencies as underlying errors
//                return .failure(self.errors.first!)
//            }
//            return nil
//            }
//    }
    
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
    
}

public extension OutputOperation {
    
    func map<I, O>(_ transform: @escaping (I) -> O) -> ResultOperation<O> where I == Self.Output {
        let resultOperation = ResultOperation<O> { [weak self] in
            guard let outputValue = self?.outputValue.get() else {
                if let error = self?.errors.first {
                    return .failure(error)
                } else {
                    return .failure(OperationError(.resultOperationNotExecuted))
                }
            }
            let returnValue = transform(outputValue)
            return .success(returnValue)
        }
        resultOperation.addSource(self)
        return resultOperation
    }
    
    func bindOutputValue<O: OutputOperation>(from outputOpearation: O) where O.Output == Self.Output {
        let observer = BlockObserver { [weak self] (operation, errors) in
            guard let strongSelf = self,
                let outputOperation = operation as? O else { fatalError() }
            strongSelf.outputValue = outputOperation.outputValue
        }
        self.addObserver(observer)
    }
    
    typealias BindBlock = (Output?, [Error]?) -> Void
    
    func binding<Input>(block: @escaping BindBlock) -> Self where Output == Input {
        let observer = BlockObserver { [weak self] _, errors in
            block(self?.outputValue.get(), self?.errors)
        }
        self.addObserver(observer)
        return self
    }
    
}

