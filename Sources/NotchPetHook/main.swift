import Dispatch
import Darwin
import EventBridge
import Foundation

let enteredAt = DispatchTime.now().uptimeNanoseconds
let pane = getenv("OTTY_PANE_ID").map { String(cString: $0) }
HookHelper.run(arguments: Array(CommandLine.arguments.dropFirst()),
               environment: pane.map { ["OTTY_PANE_ID": $0] } ?? [:], enteredAt: enteredAt)
