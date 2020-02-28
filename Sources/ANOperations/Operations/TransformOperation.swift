//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

open class TransformOperation<Input, Output>: InputOutputOperation<Input, Output> {
    
    public typealias TransformationBlock = (Input) throws -> Output
    
    private let block: TransformationBlock
    
    public init<O>(outputOperation: O, executeOnlyWhenSuccessful: Bool, block: @escaping TransformationBlock) where O: OutputOperation, O.Output == Input {
        self.block = block
        super.init(outputOperation: outputOperation, executeOnlyWhenSuccessful: executeOnlyWhenSuccessful)
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
