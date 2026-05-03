//
//  Exports.swift
//  Log4swift
//
//  Re-exports the NSLogger C module (where available) so consumers can
//  `import Log4swift` and still see NSLogger symbols, matching the behaviour
//  of the original single-module CocoaPods build. Only active under SwiftPM;
//  under CocoaPods everything lives in one module already.
//

#if SWIFT_PACKAGE && !os(watchOS)
@_exported import NSLoggerObjC
#endif
