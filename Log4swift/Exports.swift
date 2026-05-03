//
//  Exports.swift
//  Log4swift
//
//  Re-exports the split Obj-C modules so that `import Log4swift` continues to
//  expose ASL and (on supported platforms) NSLogger symbols, matching the
//  behaviour of the original single-module CocoaPods build.
//

@_exported import Log4swiftObjC

#if !os(watchOS)
@_exported import NSLoggerObjC
#endif
