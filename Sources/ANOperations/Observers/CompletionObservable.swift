//
//  CompletionObservable.swift
//  CloudKitNotes
//
//  Created by Andrew Podkovyrin on 16/05/2019.
//  Copyright © 2019 AP. All rights reserved.
//

import Foundation

public protocol CompletionObservable {}

extension ANOperation: CompletionObservable {}

public extension CompletionObservable where Self: ANOperation {
    func addCompletionObserver(_ completion: @escaping (Self, [Error]) -> Void) {
        addObserver(CompletionObserver { _, errors in
            completion(self, errors)
        })
    }
}
