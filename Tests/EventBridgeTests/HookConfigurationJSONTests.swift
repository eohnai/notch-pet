import Foundation
import Testing
@testable import EventBridge

struct HookConfigurationJSONTests {
    @Test func preservesNumericLexemesAndUnrelatedFormatting() throws {
        let source = Data(" { \"large\":90071992547409931234567890, \"exponent\":1.2300e+40, \"negative\":-0.00 } \n".utf8)
        let document = try HookConfigurationJSON(data: source)
        #expect(document.data == source)
        #expect(document.rawValue(at: [.key("large")]) == Data("90071992547409931234567890".utf8))
        #expect(document.rawValue(at: [.key("exponent")]) == Data("1.2300e+40".utf8))
        #expect(document.rawValue(at: [.key("negative")]) == Data("-0.00".utf8))
        #expect(document.rawValue(at: []) == Data("{ \"large\":90071992547409931234567890, \"exponent\":1.2300e+40, \"negative\":-0.00 }".utf8))
    }

    @Test func pathsLocateNestedArraysAndDecodedEscapedKeys() throws {
        let source = Data(#"{"ho\u006fks":{"SessionStart":[{"hooks":[{"command":"quoted \\\" value","timeout":3}]}]},"flags":[true,false,null]}"#.utf8)
        let document = try HookConfigurationJSON(data: source)
        #expect(document.rawValue(at: [.key("hooks"), .key("SessionStart"), .index(0), .key("hooks"), .index(0), .key("timeout")]) == Data("3".utf8))
        #expect(document.rawValue(at: [.key("flags"), .index(0)]) == Data("true".utf8))
        #expect(document.rawValue(at: [.key("flags"), .index(1)]) == Data("false".utf8))
        #expect(document.rawValue(at: [.key("flags"), .index(2)]) == Data("null".utf8))
        #expect(document.range(at: [.key("missing")]) == nil)
        #expect(document.range(at: [.key("flags"), .index(3)]) == nil)
    }

    @Test func duplicatesAndMalformedDocumentsAreRejectedBeforeAnyEdit() throws {
        for text in [#"{"x":1,"x":2}"#, #"{"hooks":{"a":[{"x":1,"x":2}]}}"#,
                     #"{"x":1,"\u0078":2}"#, #"{"x": [1,]}"#, "{}{}", "[]", "null", "{", #"{"x":NaN}"#] {
            #expect(throws: (any Error).self) { try HookConfigurationJSON(data: Data(text.utf8)) }
        }
        #expect(throws: (any Error).self) { try HookConfigurationJSON(data: Data([255])) }
    }

    @Test func sizeAndDepthLimitsApplyToTheWholeConfiguration() throws {
        let boundary = Data("{}".utf8) + Data(repeating: 32, count: 262142)
        #expect(try HookConfigurationJSON(data: boundary).data == boundary)
        #expect(throws: (any Error).self) { try HookConfigurationJSON(data: boundary + Data([32])) }
        let nested = Data(("{\"x\":" + String(repeating: "[", count: 64) + "0" + String(repeating: "]", count: 64) + "}").utf8)
        #expect(throws: (any Error).self) { try HookConfigurationJSON(data: nested) }
    }

    @Test func locatedInsertionPreservesEveryUnrelatedByte() throws {
        let source = Data(#"{"statusLine":{"command":"fictional; never execute"}, "number":9.007199254740993e+15,"hooks":{"SessionStart":[]}}"#.utf8)
        let document = try HookConfigurationJSON(data: source)
        let range = try #require(document.range(at: [.key("hooks"), .key("SessionStart")]))
        var edited = document.data
        let inserted = Data(#"{"hooks":[]}"#.utf8)
        edited.insert(contentsOf: inserted, at: range.upperBound - 1)
        let checked = try HookConfigurationJSON(data: edited)
        #expect(checked.rawValue(at: [.key("hooks"), .key("SessionStart"), .index(0)]) == inserted)
        edited.removeSubrange((range.upperBound - 1)..<(range.upperBound - 1 + inserted.count))
        #expect(edited == source)
        #expect(checked.rawValue(at: [.key("number")]) == Data("9.007199254740993e+15".utf8))
    }

    @Test func containerMembersExposeOnlyDirectDecodedChildren() throws {
        let document = try HookConfigurationJSON(data: Data(#"{"ho\u006fks":{"SessionStart":[{"hooks":[]}]},"other":{},"value":3}"#.utf8))
        #expect(Set(try #require(document.members(at: []))) == [.key("hooks"), .key("other"), .key("value")])
        #expect(document.members(at: [.key("hooks")]) == [.key("SessionStart")])
        #expect(document.members(at: [.key("hooks"), .key("SessionStart")]) == [.index(0)])
        #expect(document.members(at: [.key("other")]) == [])
        #expect(document.members(at: [.key("value")]) == nil)
        #expect(document.members(at: [.key("missing")]) == nil)
    }
}
