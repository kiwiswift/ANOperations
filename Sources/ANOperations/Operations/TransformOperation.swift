//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

public final class TransformOperation<Input, Output>: InputOutputOperation<Input, Output> {
    
    public typealias TransformationBlock = (Input) -> Output
    
    private let block: TransformationBlock
    
    public init<O>(outputOperation: O, block: @escaping TransformationBlock) where O: OutputOperation, O.Output == Input {
        self.block = block
        super.init(outputOperation: outputOperation)
    }
    
    public override func execute() {
        guard let inputValue = self.inputValue.get() else { fatalError() } //TODO: Change fatalerror to error handling
        let outputValue = block(inputValue)
        self.finish(with: outputValue)
    }
}
