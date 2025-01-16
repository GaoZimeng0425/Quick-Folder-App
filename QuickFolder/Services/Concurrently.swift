//
//  Cur.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/3.
//

import Foundation
import SwiftUI

func executeConcurrently<T>(
  _ tasks: [() async throws -> T],
  maxConcurrency: Int
) async throws -> [T] {
  let semaphore = AsyncSemaphore(value: maxConcurrency)
  var results = [T?](repeating: nil, count: tasks.count)

  try await withThrowingTaskGroup(of: (Int, Result<T, Error>).self) { group in
    for (index, task) in tasks.enumerated() {
      group.addTask {
        await semaphore.wait()

        do {
          let result = try await task()
          await semaphore.signal()
          return (index, .success(result))
        } catch {
          await semaphore.signal()
          return (index, .failure(error))
        }
      }
    }

    for try await (index, result) in group {
      switch result {
      case let .success(value):
        results[index] = value
      case let .failure(error):
        throw error
      }
    }
  }

  return results.compactMap { $0 }
}

actor AsyncSemaphore {
  private let maxValue: Int
  private var currentValue: Int
  private var queue: [CheckedContinuation<Void, Never>] = []

  init(value: Int) {
    maxValue = value
    currentValue = value
  }

  func wait() async {
    await withCheckedContinuation { continuation in
      if currentValue > 0 {
        currentValue -= 1
        continuation.resume()
      } else {
        queue.append(continuation)
      }
    }
  }

  func signal() {
    if let continuation = queue.first {
      queue.removeFirst()
      continuation.resume()
    } else {
      currentValue += 1
    }
  }
}

//// 一个简单的异步信号量实现
// actor AsyncSemaphore {
//  private var value: Int
//  private var waiters: [CheckedContinuation<Void, Never>] = []
//
//  init(value: Int) {
//    self.value = value
//  }
//
//  func wait() async {
//    while value <= 0 {
//      await withCheckedContinuation { continuation in
//        waiters.append(continuation)
//      }
//    }
//    value -= 1
//  }
//
//  func signal() {
//    value += 1
//    if !waiters.isEmpty {
//      let waiter = waiters.removeFirst()
//      waiter.resume()
//    }
//  }
// }
