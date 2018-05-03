import Foundation

@objc open class ConsoleOutput: BaseLogsOutput {
    
    override open func send(level: LogLevel, message: String, file: String, function: String, line: Int) {
        let finalMessage = formMessage(level: level, message: message, file: file, function: function, line: line)
        print(finalMessage)
    }
}
