//
//  Exports.swift
//  Log4swift
//
//  Re-exports the split Obj-C modules so that `import Log4swift` continues to
//  expose ASL and (on supported platforms) NSLogger symbols, matching the
//  behaviour of the original single-module CocoaPods build. Only active
//  under SwiftPM — under CocoaPods everything lives in one module already
//  so there is nothing to re-export.
//

#if SWIFT_PACKAGE

@_exported import Log4swiftObjC

#if !os(watchOS)
@_exported import NSLoggerObjC
#endif

#endif
