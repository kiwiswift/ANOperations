//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

open class TransformOperation<Input, Output>: InputOperation<Input>, OutputOperation {
    
    public var outputValue: ValueState<Output> = .pending
    
    public typealias TransformationBlock = (Input) throws -> Output
    
    private let block: TransformationBlock
    
    public init<O>(outputOperation: O, block: @escaping TransformationBlock) where O: OutputOperation, O.Output == Input {
        self.block = block
        super.init(outputOperation: outputOperation)
    }
    
    public init(block: @escaping TransformationBlock) {
        self.block = block
        super.init()
    }
    
    public override func execute(with value: Input) {
        do {
            let outputValue = try block(value)
            self.finish(with: outputValue)
        } catch {
            self.finishWithError(error)
        }
    }
}
