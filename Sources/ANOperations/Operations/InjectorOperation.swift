//
//  File.swift
//  
//
//  Created by Christiano Gontijo on 3/03/20.
//

public class InjectorOperation<T>: AnyOutputOperation<T> {
    
    let value: T
    
    public init(value: T) {
        self.value = value
        super.init(name: "InjectorOperation of \(type(of: value))")
    }
    
    override public func execute() {
        self.finish(with: value)
    }
    
}
