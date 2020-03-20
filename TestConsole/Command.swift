//
//  Command.swift
//  TestConsole
//
//  Created by eport2 on 2019/9/19.
//  Copyright © 2019 eport2. All rights reserved.
//

import Cocoa

public struct CLI {
    /// Output type for printed content
    public enum OutputType {
        case info
        case success
        case error
        case warning
        case content
        case raw
    }
    
    /// Output handler - override this to intercept output from the CLI
    public static var print: (String, OutputType) -> Void = { _, _ in
        fatalError("No print hook set.")
    }
    
    /// Input handler - override this to inject input into the CLI
    /// Injected lines should include the terminating newline character
    public static var readLine: () -> String? = {
        Swift.readLine(strippingNewline: false)
    }
    
    /// Run the CLI with the specified input arguments
    public static func run(in directory: String, with args: [String] = CommandLine.arguments) -> ExitCode {
//        var g = args
//        g.append(readLine()!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))
        print("Please Choose AES :", .info)
        print("1. Encrypt", .info)
        print("2. Decrypt", .info)
        let index = readLine()!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        switch Int(index) {
        case 1:
            print("Please Input JSON Strings",.info)
            print("data = \(aesEnCrypt(readLine()!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))", .content)
        case 2:
            print("Please Input AES Strings",.info)
            print("json = \(aesDeCrypt(readLine()!.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)))", .content)
        default:
            break
        }
        return .ok
    }
    
    /// Run the CLI with the specified input string (this will be parsed into multiple arguments)
    public static func run(in directory: String, with argumentString: String) -> ExitCode {
        return run(in: directory, with: parseArguments(argumentString))
    }
}

public enum ExitCode: Int32 {
    case ok = 0 // EX_OK
    case lintFailure = 1
    case error = 70 // EX_SOFTWARE
}

func processArguments(_ args: [String], in directory: String) -> ExitCode {
    if args.count <= 1 {
        print("参数输入不正确！")
        return .ok
    }
    switch args[1] {
    case "--help":
        print("help")
    case "-h":
        print("help")
    default:
        print("")
    }
    return .ok
}

func parseArguments(_ argumentString: String, ignoreComments: Bool = true) -> [String] {
    return []
}

func aesDeCrypt(_ str: String) -> String {
    var tmp = str
    tmp = IUMEncryptor.decryptDES(str)
    return tmp
}

func aesEnCrypt(_ str: String) -> String {
    var tmp = str
    tmp = IUMEncryptor.encryptDES(str)
    return tmp
}
