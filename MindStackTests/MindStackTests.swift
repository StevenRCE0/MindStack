//
//  MindStackTests.swift
//  MindStackTests
//
//  Created by 砚渤 on 2024/4/17.
//

import XCTest
@testable import MindStack

final class MindStackTests: XCTestCase {
    func testDefaultShortcutMatchesTheProductShortcut() throws {
        XCTAssertEqual(AppShortcut.defaultValue.displayText, "⌃⇧Z")
    }

    func testShortcutRoundTripsThroughKeyCombo() throws {
        let shortcut = AppShortcut.defaultValue

        XCTAssertEqual(AppShortcut(keyCombo: shortcut.keyCombo), shortcut)
    }
}
