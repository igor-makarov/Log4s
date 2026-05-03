//
//  SystemAppender.swift
//  Log4swift
//
//  Created by Jérôme Duquennoy on 24/10/2017.
//  Copyright © 2017 jerome. All rights reserved.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

import Foundation

/**
 The SystemAppender is a meta-appender, that will select the preferable appender depending on the system.
 - For MacOS 10.11, it will be an ASL appender.
 - For MacOS 10.12 and latter, it will be a Unified Logging System appender
 - ...
 This appender is the best suited one for production software that targets multiple platforms.
 */
@objc
public class SystemAppender: Appender {
  public override var thresholdLevel: LogLevel {
    get {
      return self.backendAppender?.thresholdLevel ?? .Off
    }
    set {
      self.backendAppender?.thresholdLevel = newValue
    }
  }
  public override var formatter: Formatter? {
    get {
      return self.backendAppender?.formatter
    }
    set {
      self.backendAppender?.formatter = newValue
    }
  }
  
  internal let backendAppender: Appender?
  
  @objc
  public required init(_ identifier: String) {
    // AppleUnifiedLoggerAppender requires iOS 10 / macOS 10.12 / watchOS 3,
    // all of which are below the package's deployment targets, so it is
    // always available and no fallback is needed.
    self.backendAppender = AppleUnifiedLoggerAppender(identifier)
    super.init(identifier)
  }
  
  internal init(_ identifier: String, withBackendAppender appender: Appender?) {
    self.backendAppender = appender
    
    super.init(identifier)
  }
  
  public override func update(withDictionary dictionary: Dictionary<String, Any>, availableFormatters: Array<Formatter>) throws {
    try self.backendAppender?.update(withDictionary: dictionary, availableFormatters: availableFormatters)
  }
  
  public override func performLog(_ log: String, level: LogLevel, info: LogInfoDictionary) {
    self.backendAppender?.performLog(log, level: level, info: info)
  }
}
