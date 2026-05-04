//
//  Logger-AsynchronicityTests.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 28/10/2015.
//  Copyright © 2015 jerome. All rights reserved.
//

import XCTest
@testable import Log4swift

class LoggerAsynchronicityTests: XCTestCase {
  
  override func setUp() {
    super.setUp()
    LoggerFactory.sharedInstance.resetConfiguration()
  }
  
  override func tearDown() {
    super.tearDown()
  }  

  func testLoggerIsSynchronousByDefault() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger
    
    XCTAssertFalse(rootLogger.asynchronous)
  }
  
  func testResetConfigurationSetsLoggerSynchronous() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger
    rootLogger.asynchronous = true
    
    // Execute
    rootLogger.resetConfiguration()
    
    // Validate
    XCTAssertFalse(rootLogger.asynchronous)
  }
  
  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible.
  /// If the logger is synchronous, the three logs should already be recorded.
  func testSynchronousLoggerLogsMessagesSynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger
    let slowAppender = MemoryAppender()
    slowAppender.loggingDelay = 0.1
    rootLogger.asynchronous = false
    rootLogger.appenders = [slowAppender]
    
    // execute
    rootLogger.error("log1")
    rootLogger.error("log2")
    rootLogger.error("log3")
    
    // Validate
    let loggedMessagesCount = slowAppender.logMessages.count
    XCTAssertEqual(loggedMessagesCount, 3, "Logged messages were not recorded synchronously (3 messages sent, \(loggedMessagesCount) recorded")
  }
  
  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible.
  /// If the logger is synchronous, the three logs should already be recorded.
  func testSynchronousLoggerLogsBlocsSynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger
    let slowAppender = MemoryAppender()
    slowAppender.loggingDelay = 0.1
    rootLogger.asynchronous = false
    rootLogger.appenders = [slowAppender]
    
    // execute
    rootLogger.error{"log1"}
    rootLogger.error{"log2"}
    rootLogger.error{"log3"}
    
    // Validate
    let loggedMessagesCount = slowAppender.logMessages.count
    XCTAssertEqual(loggedMessagesCount, 3, "Logged messages were not recorded synchronously (3 messages sent, \(loggedMessagesCount) recorded")
  }

  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible, and after a long enough
  /// delay for all messages to be logged
  /// If the logger is synchronous, no message should have been logged right after,
  /// 3 should have been after the delay.
  func testAsynchronousLoggerLogsMessagesAsynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger
    let slowAppender = MemoryAppender()
    slowAppender.loggingDelay = 0.1
    rootLogger.asynchronous = true
    rootLogger.appenders = [slowAppender]
    
    // execute
    rootLogger.error("log1")
    rootLogger.error("log2")
    rootLogger.error("log3")

    let immediateLoggedMessagesCount = slowAppender.logMessages.count
    drainLoggingQueue()
    let delayedLoggedMessagesCount = slowAppender.logMessages.count

    // Validate
    XCTAssertEqual(immediateLoggedMessagesCount, 0, "Some messages were not logged asynchronously")
    XCTAssertEqual(delayedLoggedMessagesCount, 3, "Some messages were not logged after")
  }

  /// This test logs three message to an appender that takes 0.1 second to execute.
  /// It then counts the number of logged messages as soon as possible, and after a long enough
  /// delay for all messages to be logged
  /// If the logger is synchronous, no message should have been logged right after,
  /// 3 should have been after the delay.
  func testAsynchronousLoggerLogsBlocsAsynchronously() {
    let rootLogger = LoggerFactory.sharedInstance.rootLogger
    let slowAppender = MemoryAppender()
    slowAppender.loggingDelay = 0.1
    rootLogger.asynchronous = true
    rootLogger.appenders = [slowAppender]
    
    // execute
    rootLogger.error{"log1"}
    rootLogger.error{"log2"}
    rootLogger.error{"log3"}
    
    let immediateLoggedMessagesCount = slowAppender.logMessages.count
    drainLoggingQueue()
    let delayedLoggedMessagesCount = slowAppender.logMessages.count
        
    // Validate
    XCTAssertEqual(immediateLoggedMessagesCount, 0, "Some messages were not logged asynchronously")
    XCTAssertEqual(delayedLoggedMessagesCount, 3, "Some messages were not logged after delay")
  }
  
  func testMessagesSentToAsynchronousLoggersAreOrdered() {
    let logger1 = LoggerFactory.sharedInstance.getLogger("logger1")
    logger1.asynchronous = true
    let logger2 = LoggerFactory.sharedInstance.getLogger("logger2")
    logger2.asynchronous = true

    let slowAppender = MemoryAppender()
    logger1.appenders = [slowAppender]
    logger2.appenders = [slowAppender]
    
    // Execute
    logger2.info{ Thread.sleep(forTimeInterval: 0.2); return "1"; }
    logger1.info{ Thread.sleep(forTimeInterval: 0.1); return "2"; }
    logger2.info{ Thread.sleep(forTimeInterval: 0.2); return "3"; }
    logger1.info{ Thread.sleep(forTimeInterval: 0.1); return "4"; }
    
    drainLoggingQueue()
    
    // Validate
    let expectedOrderedMessages: [LoggedMessage] = [
      ("1", .Info),
      ("2", .Info),
      ("3", .Info),
      ("4", .Info)]

    // Snapshot once so the count check and the per-index comparisons agree
    // even if more work is still draining. If drain timed out, fail cleanly
    // instead of indexing into a short array and crashing the test runner.
    let recorded = slowAppender.logMessages
    guard recorded.count == expectedOrderedMessages.count else {
      XCTFail("All messages were not logged (got \(recorded.count) of \(expectedOrderedMessages.count))")
      return
    }
    for index in 0..<expectedOrderedMessages.count {
      XCTAssertTrue(recorded[index] == expectedOrderedMessages[index], "Order of logged messages is not correct")
    }
  }
  
  //MARK: private methods

  /// Block the test thread until every async log block queued before this
  /// call has run. Previously this was a `Thread.sleep`-polling wait, then a
  /// `RunLoop.main.run`-parked wait. Both relied on libdispatch voluntarily
  /// scheduling a worker for `Logger.loggingQueue` (.background QoS) within
  /// the test's timeout; on GitHub-hosted iOS Simulator runners it does not,
  /// and the async tests fail with "got 0 of N" while the production logger
  /// works fine everywhere else.
  ///
  /// `dispatch_sync` from the test thread onto the same serial queue sidesteps
  /// that scheduling question entirely: the caller's QoS is inherited onto
  /// the queue for the duration of the sync, forcing libdispatch to run every
  /// previously-enqueued block before returning. Deterministic drain, no
  /// polling, no timeout, no flakiness.
  fileprivate func drainLoggingQueue() {
    Logger.loggingQueue.sync {}
  }
}
