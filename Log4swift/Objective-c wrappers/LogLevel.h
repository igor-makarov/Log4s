//
//  LogLevel.h
//  Log4swift
//
//  Single source of truth for Log4swift's log-severity enumeration.
//  Declared in Obj-C so that both the Obj-C helpers (ASLWrapper) and the
//  Swift code in the sibling target can share the exact same definition
//  without any module-level circular dependency.
//
//  Imported into Swift as a frozen `enum LogLevel: Int` via NS_CLOSED_ENUM.
//  NS_SWIFT_NAME on each case preserves the historical capitalised Swift
//  spelling (e.g. `LogLevel.Trace`) rather than the default Swift-ified
//  lowercased form.
//
// Licensed under the Apache License, Version 2.0 (the "License").
//

@import Foundation;

/**
 Log level defines the importance of the log : is it just a debug log,
 an informational notice, or an error.

 Order of the levels is :

   Trace < Debug < Info < Warning < Error < Fatal < Off
 */
typedef NS_CLOSED_ENUM(NSInteger, LogLevel) {
    LogLevelTrace   NS_SWIFT_NAME(Trace)   = 0,
    LogLevelDebug   NS_SWIFT_NAME(Debug)   = 1,
    LogLevelInfo    NS_SWIFT_NAME(Info)    = 2,
    LogLevelWarning NS_SWIFT_NAME(Warning) = 3,
    LogLevelError   NS_SWIFT_NAME(Error)   = 4,
    LogLevelFatal   NS_SWIFT_NAME(Fatal)   = 5,
    LogLevelOff     NS_SWIFT_NAME(Off)     = 6,
};
