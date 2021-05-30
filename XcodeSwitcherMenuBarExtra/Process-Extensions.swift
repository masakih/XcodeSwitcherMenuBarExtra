//
//  Process-Extensions.swift
//  XcodeChangerMenuarExtra
//
//  Created by Hori,Masaki on 2021/04/25.
//

import Foundation

/// 出力を簡単に扱うための補助的な型。FileHandleを隠蔽する。
struct Output {

    private let fileHandle: FileHandle

    init(fileHandle: FileHandle) {
        self.fileHandle = fileHandle
    }

    var data: Data {
        return fileHandle.readDataToEndOfFile()
    }

    var string: String? {
        return String(data: data, encoding: .utf8)
    }

    var lines: [String] {
        return string?.components(separatedBy: "\n") ?? []
    }
}

precedencegroup ArgumentPrecedence {

    associativity: left
    higherThan: AdditionPrecedence
}
infix operator <<< : ArgumentPrecedence

/// Processにexecutable pathを設定する。
func <<< (lhs: Process, rhs: String) -> Process {

    lhs.executableURL = URL(fileURLWithPath: rhs)
    return lhs
}

/// Processに引数を設定する。
func <<< (lhs: Process, rhs: [String]) -> Process {

    lhs.arguments = rhs
    return lhs
}

/// Processをパイプする。
func | (lhs: Process, rhs: Process) -> Process {

    let pipe = Pipe()

    lhs.standardOutput = pipe
    rhs.standardInput = pipe
    lhs.launch()

    return rhs
}

precedencegroup RedirectPrecedence {

    associativity: left
    lowerThan: LogicalDisjunctionPrecedence
}
infix operator >>> : RedirectPrecedence

/// Processの出力をOutput型で受け取り加工などができる。
/// ジェネリクスを利用しているのでどのような型にでも変換して返せる。
func >>> <T>(lhs: Process, rhs: (Output) -> T) -> T {

    let pipe = Pipe()
    lhs.standardOutput = pipe
    lhs.launch()

    return rhs(Output(fileHandle: pipe.fileHandleForReading))
}
