//
//  Copyright (C) 2015 Apple Inc. All Rights Reserved.
//  See LICENSE.txt for this sample’s licensing information
//
//  Abstract:
//  This file defines the OperationObserver protocol.
//

import Foundation

public protocol OperationObserverProtocol { }

public protocol OperationStartObserver: OperationObserverProtocol {
    /// Invoked immediately prior to the `ANOperation`'s `execute()` method.
    func operationDidStart(_ operation: ANOperation)

}

public protocol OperationFinishObserver: OperationObserverProtocol {
    /**
     Invoked as an `ANOperation` finishes, along with any errors produced during
     execution (or readiness evaluation).
     */
    func operationDidFinish(_ operation: ANOperation, errors: [Error])
}

public protocol OperationCancelObserver: OperationObserverProtocol {
    /// Invoked immediately after the first time the `ANOperation`'s `cancel()` method is called
    func operationDidCancel(_ operation: ANOperation)
}

/**
 The protocol that types may implement if they wish to be notified of significant
 operation lifecycle events.
 */
public protocol OperationProduceObserver: OperationObserverProtocol {

    /// Invoked when `ANOperation.produceOperation(_:)` is executed.
    func operation(_ operation: ANOperation, didProduceOperation newOperation: Operation)
    
}

public protocol OperationObserver:
OperationStartObserver,
OperationFinishObserver,
OperationCancelObserver,
OperationProduceObserver { }
