//
//  InfoTableSource.swift
//  Aerial
//
//  Created by Guillaume Louel on 16/12/2019.
//  Copyright © 2019 Guillaume Louel. All rights reserved.
//

import Cocoa

class InfoTableSource: NSTableView, NSTableViewDataSource, NSTableViewDelegate {
    private var dragDropType = NSPasteboard.PasteboardType(rawValue: "private.table-row")
    var controller: PreferencesWindowController?

    fileprivate enum CellIdentifiers {
        static let InfoSourceCellID = "InfoSourceCellID"
    }

    func setController(_ controller: PreferencesWindowController) {
        self.controller = controller
    }

    override func draw(_ dirtyRect: NSRect) {
        super.draw(dirtyRect)
    }

    func numberOfRows(in tableView: NSTableView) -> Int {
        return PrefsInfo.layers.count
    }

    func tableView(_ tableView: NSTableView, heightOfRow row: Int) -> CGFloat {
        return 30
    }

    // This is where we fill each cell
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cid = NSUserInterfaceItemIdentifier(rawValue: "InfoSourceCellID")

        if let cell = tableView.makeView(withIdentifier: cid, owner: self) as? NSTableCellView {
            cell.textField?.stringValue = PrefsInfo.layers[row].rawValue
            return cell
        }

        return nil
    }

    // This is where selection happens
    func tableViewSelectionDidChange(_ notification: Notification) {
        let tableView = notification.object as! NSTableView
        print("selrow \(tableView.selectedRow)")
        if tableView.selectedRow < 0 {
            controller!.resetInfoPanel()
        } else {
            controller!.drawInfoPanel(forType: PrefsInfo.layers[tableView.selectedRow])
        }
    }

    // MARK: - Drag 'n Drop
    func tableView(_ tableView: NSTableView, pasteboardWriterForRow row: Int) -> NSPasteboardWriting? {

        let item = NSPasteboardItem()
        item.setString(String(row), forType: self.dragDropType)
        return item
    }

    // swiftlint:disable:next line_length
    func tableView(_ tableView: NSTableView, validateDrop info: NSDraggingInfo, proposedRow row: Int, proposedDropOperation dropOperation: NSTableView.DropOperation) -> NSDragOperation {

        if dropOperation == .above {
            return .move
        }
        return []
    }

    func tableView(_ tableView: NSTableView, acceptDrop info: NSDraggingInfo, row: Int, dropOperation: NSTableView.DropOperation) -> Bool {

        var oldIndexes = [Int]()
        info.enumerateDraggingItems(options: [], for: tableView, classes: [NSPasteboardItem.self], searchOptions: [:]) { dragItem, _, _ in
            if let str = (dragItem.item as! NSPasteboardItem).string(forType: self.dragDropType), let index = Int(str) {
                oldIndexes.append(index)
            }
        }

        var oldIndexOffset = 0
        var newIndexOffset = 0

        for oldIndex in oldIndexes {
            if oldIndex < row {
                PrefsInfo.layers.move(from: oldIndex + oldIndexOffset, to: row - 1)
                oldIndexOffset -= 1
            } else {
                PrefsInfo.layers.move(from: oldIndex, to: row + newIndexOffset)
                newIndexOffset += 1
            }
        }

        tableView.reloadData()
        return true
    }
}

// Helpers to move items in array
extension Array where Element: Equatable {
    mutating func move(_ element: Element, to newIndex: Index) {
        if let oldIndex: Int = self.firstIndex(of: element) { self.move(from: oldIndex, to: newIndex) }
    }
}

extension Array {
    mutating func move(from oldIndex: Index, to newIndex: Index) {
        // Don't work for free and use swap when indices are next to each other - this
        // won't rebuild array and will be super efficient.
        if oldIndex == newIndex { return }
        if abs(newIndex - oldIndex) == 1 { return self.swapAt(oldIndex, newIndex) }
        self.insert(self.remove(at: oldIndex), at: newIndex)
    }
}
