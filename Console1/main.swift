//
//  main.swift
//  Console1
//
//  Created by eport2 on 2019/9/19.
//  Copyright © 2019 eport2. All rights reserved.
//

import Foundation

#if os(macOS)
import Darwin.POSIX
#else
import Glibc
#endif

#if SWIFT_PACKAGE
import SwiftFormat
#endif

extension String {
    var inDefault: String { return "\u{001B}[39m\(self)" }
    var inRed: String { return "\u{001B}[31m\(self)\u{001B}[0m" }
    var inGreen: String { return "\u{001B}[32m\(self)\u{001B}[0m" }
    var inYellow: String { return "\u{001B}[33m\(self)\u{001B}[0m" }
}

extension FileHandle: TextOutputStream {
    public func write(_ string: String) {
        write(Data(string.utf8))
    }
}

private var stderr = FileHandle.standardError

private let stderrIsTTY = isatty(STDERR_FILENO) != 0

CLI.print = { message, type in
    switch type {
    case .info:
        print(message, to: &stderr)
    case .success:
        print(stderrIsTTY ? message.inGreen : message, to: &stderr)
    case .error:
        print(stderrIsTTY ? message.inRed : message, to: &stderr)
    case .warning:
        print(stderrIsTTY ? message.inYellow : message, to: &stderr)
    case .content:
        print(message)
    case .raw:
        print(message, terminator: "")
    }
}

exit(CLI.run(in: FileManager.default.currentDirectoryPath).rawValue)


