//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 10/02/20.
//

public class ResultOperation<Output>: ANOperation, OutputOperation {
    
    public var outputValue: ValueState<Output> = .pending
    
    public typealias TransformationBlock = () -> Output
    
    private let block: TransformationBlock
    
    public init(block: @escaping TransformationBlock) {
        self.block = block
        super.init()
    }
    
    public override func execute() {
        let outputValue = block()
        self.finish(with: outputValue)
    }
}
