//
//  Defaults.swift
//  MindStack
//
//  Created by 砚渤 on 2024/4/22.
//

import AppKit
import Defaults

extension Defaults.Keys {
    static let pinnedPanel = Key<Bool>("pinnedPanel", default: false)
    static let hasSeenOnboarding = Key<Bool>(
        "hasSeenOnboarding",
        default: false
    )
    static let shortcutKeyCode = Key<Int>(
        "shortcutKeyCode",
        default: AppShortcut.defaultValue.keyCode
    )
    static let shortcutModifiers = Key<Int>(
        "shortcutModifiers",
        default: AppShortcut.defaultValue.modifiers
    )
    static let hideSignatureLine = Key<Bool>(
        "hideSignatureLine",
        default: false
    )
    static let signatureText = Key<String>(
        "signatureText",
        default: "Thanks for Supporting MindStack"
    )
}
