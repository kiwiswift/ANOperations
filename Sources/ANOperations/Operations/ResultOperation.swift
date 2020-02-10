//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 10/02/20.
//

public class ResultOperation<Output>: ANOperation, OutputOperation {
    
    public var outputValue: ValueState<Output> = .pending
    
    // MARK: Transformation Dependencies
    internal var sourceOperations: [ANOperation] = []
    
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
    
    internal func addSource(_ operation: ANOperation) {
        self.sourceOperations.append(operation)
        self.addDependency(operation)
    }
    
    override public func didEnqueue(in queue: ANOperationQueue) {
        //Extract dependencies that haven't been added to the queue
        //(e.g. when transformation methods such as 'map' is used)
        sourceOperations.forEach{ queue.addOperation($0) }
        super.didEnqueue(in: queue)
    }
}
