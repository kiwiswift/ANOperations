//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 10/02/20.
//

open class InputOutputOperation<Input, Output>: InputOperation<Input>, OutputOperation {
    
    public var outputValue: ValueState<Output> = .pending
    
}


