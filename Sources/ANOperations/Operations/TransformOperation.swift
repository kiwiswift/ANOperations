//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 8/02/20.
//

open class TransformOperation<Input, Output>: InputOutputOperation<Input, Output> {
    
    public typealias TransformationBlock = (Input) throws -> Output
    
    private let block: TransformationBlock
    
    public init<O>(name: String? = nil, outputOperation: O, executeOnlyWhenSuccessful: Bool, block: @escaping TransformationBlock) where O: OutputOperation, O.Output == Input {
        self.block = block
        let name = name ?? "TransformOperation<\(Input.self),\(Output.self)>" + (outputOperation.name.map { "injected from \($0)" } ?? "")
        super.init(name: name, outputOperation: outputOperation, executeOnlyWhenSuccessful: executeOnlyWhenSuccessful)
    }
    
    public init(name: String = "TransformOperation<\(Input.self),\(Output.self)>",
                block: @escaping TransformationBlock) {
        self.block = block
        super.init(name: name)
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
