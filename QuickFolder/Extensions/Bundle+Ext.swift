//
//  Bundle+Ext.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2025/1/3.
//

import Foundation

// Returns the current build number
extension Bundle {
    var appName: String {
        getInfo("CFBundleName") ?? "⚠️"
    }

    var displayName: String {
        getInfo("CFBundleDisplayName") ?? "⚠️"
    }

    var bundleID: String {
        getInfo("CFBundleIdentifier") ?? "⚠️"
    }

    var copyright: String {
        getInfo("NSHumanReadableCopyright") ?? "⚠️"
    }

    var appBuild: Int? {
        Int(getInfo("CFBundleVersion") ?? "")
    }

    var appVersion: String? {
        getInfo("CFBundleShortVersionString")
    }

    func getInfo(_ str: String) -> String? {
        infoDictionary?[str] as? String
    }
}

