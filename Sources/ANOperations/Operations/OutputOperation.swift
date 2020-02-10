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
    
    func map<N>(_ transform: @escaping (Output) -> N) -> TransformOperation<Output, N> {
        let transformOperation = TransformOperation<Output, N>(outputOperation: self, block: transform)
        self.addDependency(transformOperation)
        return transformOperation
    }
    
    func bind<O: OutputOperation>(from outputOpearation: O) where O.Output == Self.Output {
        let observer = BlockObserver { [weak self] (operation, errors) in
            guard let strongSelf = self,
                let outputOperation = operation as? O else { return }
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

extension Result {
    
    init(_ value: Success, _ error: Failure?) {
        if let error = error {
            self = .failure(error)
        } else {
            self = .success(value)
        }
    }
    
}
