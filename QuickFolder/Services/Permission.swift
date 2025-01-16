//
//  Permission.swift
//  Folder Finder
//
//  Created by GaoZimeng on 2024/12/27.
//
// github: https://github.com/techrisdev/Snap/blob/main/Snap/Permissions.swift#L46

import AppKit
import Contacts
import EventKit

class Permissions {
  /// Request Permissions and set the Authorization Status in UserDefaults.
  static func requestPermissions() {
    // Get the authorization status for contacts.
    let contactAuthorizationStatus = requestContactAccess()

    // Set the value in UserDefaults so it can be used later.
    UserDefaults.standard.setValue(contactAuthorizationStatus, forKey: "ContactAuthorizationStatus")

    // Get the authorization status for calendar events.
    let calendarAuthorizationStatus = requestCalendarAccess()

    // Set the value in UserDefaults so it can be used later.
    UserDefaults.standard.setValue(calendarAuthorizationStatus, forKey: "CalendarAuthorizationStatus")

    // Request Full Disk Access for accessing files in the user's home directory.
    requestFullDiskAccess()

    // Set the Full Disk Access status in UserDefaults so it can be used later.
    UserDefaults.standard.setValue(fullDiskAccess, forKey: "FullDiskAccess")

    // MARK: TODO - Searching for reminders doesn't work right now.

    // Request access for reminders.
//        EKEventStore().requestAccess(to: .reminder, completion: { result, _ in
//          if !result {
//            print("Access denied.")
//          }
//        })
//
//        // Get the authorization status.
//        let remindersAuthorizationStatus = EKEventStore.authorizationStatus(for: .reminder)
//
//        // Set the value in UserDefaults so it can be used later.
//        UserDefaults.standard.setValue(remindersAuthorizationStatus.rawValue, forKey: "RemindersAuthorizationStatus")
  }

  /// Request access for Contacts.
  private static func requestContactAccess() -> Bool {
    var authorizationStatus = false
    CNContactStore().requestAccess(for: .contacts) { result, _ in
      authorizationStatus = result
    }

    // Return the authorization status for contacts.
    return authorizationStatus
  }

  /// Request access for Calendar events.
  private static func requestCalendarAccess() -> Bool {
    var authorizationStatus = false
    EKEventStore().requestFullAccessToEvents { result, _ in
      authorizationStatus = result
    }

    // Return the authorization status for calendar events.
    return authorizationStatus
  }

  /// The current authorization status for Full Disk Access.
  static var fullDiskAccess: Bool {
    return FileManager.default.contents(atPath: "\(NSHomeDirectory())/Library/Safari/CloudTabs.db") != nil
  }

  /// Alert for requesting Full Disk Access.
  private static let fullDiskAccessAlert = NSAlert()

  /// Request access to folders like the users desktop folder.
  static func requestFullDiskAccess() {
    // If there is Full Disk Access, return from the function.
    if fullDiskAccess {
      return
    }

    // Configure the alert.
    fullDiskAccessAlert.messageText = "Snap would like to have Full Disk Access."
    fullDiskAccessAlert.informativeText = "Full Disk Access is required for searching all files."
    fullDiskAccessAlert.icon = NSWorkspace.shared.icon(forFile: "/System/Library/PreferencePanes/Security.prefPane")

    // Add the buttons.
    let okButton = fullDiskAccessAlert.addButton(withTitle: "OK")
    okButton.target = self
    okButton.action = #selector(showFullDiskAccessPreferences)

    fullDiskAccessAlert.addButton(withTitle: "Don't Allow")

    // Present the alert.
    fullDiskAccessAlert.runModal()
  }

  @objc private static func showFullDiskAccessPreferences(alert _: NSAlert) {
    // Create a URL pointing to the Full Disk Access preferences.
    let url = URL(string: "x-apple.systempreferences:com.apple.preference.security?Privacy_AllFiles")!

    // Open the URL.
    NSWorkspace.shared.open(url)

    // Close Alert.
    fullDiskAccessAlert.window.close()
  }
}
