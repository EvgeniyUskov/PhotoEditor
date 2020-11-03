//
//  AsyncOperationTest.swift
//  PhotoEditorTests
//
//  Created by Evgeniy Uskov on 03.11.2020.
//

import Foundation
import XCTest

struct AsyncOperation<Value> {
    let queue: DispatchQueue = .main
    let closure: () -> Value

    func perform(then handler: @escaping (Value) -> Void) {
        queue.async {
            let value = self.closure()
            handler(value)
        }
    }
}
