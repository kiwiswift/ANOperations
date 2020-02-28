//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 10/02/20.
//

/*open class FinishOperation<Input>: InputOperation<Input> {
    
    typealias BindBlock = (Result<Input, Error>) -> Void
    
    var bindBlock: BindBlock
    
    init<O>(bindBlock: @escaping BindBlock, outputOperation: O, executeOnlyWhenSuccessful: Bool) where O: OutputOperation, O.Output == Input {
        self.bindBlock = bindBlock
        super.init(outputOperation: outputOperation, executeOnlyWhenSuccessful: executeOnlyWhenSuccessful)
    }
    
    public override func execute() {
        guard let inputValue = self.inputValue.get() else {
            self.finishWithError(OperationError(.inputValueNotSet))
            return
        }
        let result = Result(inputValue, self.errors.first)
        bindBlock(result)
        self.finish()
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
*/
