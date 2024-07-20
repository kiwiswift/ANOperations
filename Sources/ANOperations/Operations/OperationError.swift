//
//  Copyright © 2015 Apple Inc. All Rights Reserved.
//  See LICENSE.txt for this sample’s licensing information
//
//  Modified by Andrew Podkovyrin, 2019
//

import CloudKit
import Foundation

public enum OperationError: LocalizedError {
    case conditionNotMet(condition: String)
    case negatedConditionFailed(notCondition: String)
    case noCancelledDependenciesConditionFailed(cancelled: [Operation])
    case reachabilityConditionFailed(host: URL)
    case inputValueNotSet(operationName: String)
    case outputValueNotSet
    case dependenciesFailed([Error])
    case timedOut(timeout: TimeInterval)
    case tryingToRunFinishedOperation(operationName: String)

    public var errorDescription: String? {
        switch self {
        case .conditionNotMet(condition: let condition):
            return "Condition \(condition) not met"
        case .negatedConditionFailed(notCondition: let condition):
            return "Negated Condition \(condition) not met"
        case .noCancelledDependenciesConditionFailed(cancelled: let operations):
            return "No Cancelled Dependencies Conditions failed - Operations \(operations.map { $0.name ?? $0.description }.joined(separator: ","))"
        case .reachabilityConditionFailed(host: let url):
            return "Url \(url.absoluteString) not reacheable"
        case .inputValueNotSet(let name):
            return "Input Value not set - operation: \(name)"
        case .tryingToRunFinishedOperation(let name):
            return "Trying to run a finished operation: \(name)"
        case .outputValueNotSet:
            return "Output Value not set"
        case .dependenciesFailed(let errors):
            return "Dependencies failed: \(errors.map { $0.localizedDescription }.joined(separator: ","))"
        case .timedOut(timeout: let timeInterval):
            return "Timeout: (\(timeInterval))"
        }
    }
}

extension OperationError: Equatable {
    public static func == (lhs: OperationError, rhs: OperationError) -> Bool {
        switch (lhs, rhs) {
        case let (.negatedConditionFailed(lhs), .negatedConditionFailed(rhs)):
            return lhs == rhs
        case let (.noCancelledDependenciesConditionFailed(lhs), .noCancelledDependenciesConditionFailed(rhs)):
            return lhs == rhs
        case let (.reachabilityConditionFailed(lhs), .reachabilityConditionFailed(rhs)):
            return lhs == rhs
        case let (.timedOut(lhs), .timedOut(rhs)):
            return lhs == rhs
        default:
            return false
        }
    }
}
