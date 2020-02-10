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

public extension OutputOperation {
    
    func map<I, O>(_ transform: @escaping (I) -> O) -> ResultOperation<O> where I == Self.Output {
        let resultOperation = ResultOperation<O> { [weak self] in
            guard let outputValue = self?.outputValue.get() else { fatalError() }
            return transform(outputValue)
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
    
    typealias BindBlock = (Result<Output, Error>) -> Void
    
    func binding<Input>(block: @escaping BindBlock) -> Self where Output == Input {
        let observer = BlockObserver { [weak self] _, errors in
            guard let strongSelf = self,
                let result = strongSelf.outputResult else {
                    let error = OperationError(.inputValueNotSet)
                    block(Result.failure(error))
                    return
            }
            block(result)
        }
        self.addObserver(observer)
        return self
    }
    
}

