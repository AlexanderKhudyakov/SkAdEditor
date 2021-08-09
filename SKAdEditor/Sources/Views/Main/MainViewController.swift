//
//  MainViewController.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 30.07.2021.
//

import AppKit

protocol MainViewControllerDelegate: AnyObject {
    func didLoad()
    func didCreateNewList()
    func didOpenTextFile(at url: URL)
    func didOpenPlist(at url: URL)
    func didSaveTextFile(at url: URL)
    func didSavePlist(at url: URL)
    func didRemoveValues(at indexSet: IndexSet)
    func didAddValues(list: SKAdNetworkList)
}

protocol MainViewControllerInput: NSViewController {
    var viewModel: MainViewController.ViewModel { get set }
}

final class MainViewController: NSViewController, MainViewControllerInput {
    enum State: Equatable {
        case initial
        case editing
    }

    struct ViewModel {
        var state: State = .initial
        var filename: String? = nil
        var title: String? = nil
        var ids: [String] = []
    }

    enum TableColumn: String {
        case number = "NumberIdentifier"
        case value = "ValueIdentifier"
    }

    var viewModel = ViewModel() {
        didSet {
            update(viewModel)
        }
    }

    @IBOutlet private weak var createButton: NSButton!
    @IBOutlet private weak var openTxtButton: NSButton!
    @IBOutlet private weak var openPlistButton: NSButton!
    @IBOutlet private weak var saveJsonButton: NSButton!
    @IBOutlet private weak var savePlistButton: NSButton!
    @IBOutlet private weak var addButton: NSButton!
    @IBOutlet private weak var deleteButton: NSButton!
    @IBOutlet private weak var tableView: NSTableView!
    @IBOutlet private weak var countLabel: NSTextField!
    @IBOutlet private weak var titleLabel: NSTextField!
    @IBOutlet private weak var filenameLabel: NSTextField!

    lazy var delegate: MainViewControllerDelegate? = {
        let presenter = MainPresenter()
        presenter.view = self
        return presenter
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate?.didLoad()
    }

    @IBAction func onCreate(_ sender: NSButton) {
        self.delegate?.didCreateNewList()
    }

    @IBAction func onImportTxt(_ sender: NSButton) {
        showOpenPanel(for: ["txt", "json"]) { url in
            self.delegate?.didOpenTextFile(at: url)
        }
    }
    @IBAction func onImportPlist(_ sender: NSButton) {
        showOpenPanel(for: ["plist"]) { url in
            self.delegate?.didOpenPlist(at: url)
        }
    }

    @IBAction func onExportJson(_ sender: NSButton) {
        showSavePanel(for: "json") { url in
            self.delegate?.didSaveTextFile(at: url)
        }

    }

    @IBAction func onExportPlist(_ sender: NSButton) {
        showSavePanel(for: "plist") { url in
            self.delegate?.didSavePlist(at: url)
        }
    }

    @IBAction func onAdd(_ sender: NSButton) {
        var topLevelArray: NSArray? = nil
        Bundle.main.loadNibNamed("AddPanel", owner: self, topLevelObjects: &topLevelArray)
        dump(topLevelArray)
        guard let sheet = topLevelArray?.first(where: {$0 is AddPanel}) as? AddPanel else { return }


        view.window?.beginSheet(sheet) { [weak self] response in
            guard let self = self, response == .OK else { return }
            self.delegate?.didAddValues(list: sheet.result)
        }
    }

    @IBAction func onDelete(_ sender: NSButton) {
        let selection = self.tableView.selectedRowIndexes
        guard !selection.isEmpty else { return }
        tableView.beginUpdates()
        tableView.removeRows(at: selection, withAnimation: .slideUp)
        tableView.reloadData(forRowIndexes: IndexSet(0..<viewModel.ids.count), columnIndexes: IndexSet([0]))
        tableView.endUpdates()
        delegate?.didRemoveValues(at: selection)
    }

    func update(_ vm: ViewModel) {
        switch vm.state {
        case .initial:
            saveJsonButton.isEnabled = false
            savePlistButton.isEnabled = false
            deleteButton.isEnabled = false
        case .editing:
            enableEditing(title: vm.title, filename: vm.filename)
        }
        countLabel.stringValue = !vm.ids.isEmpty ? String(vm.ids.count) : ""
        tableView.reloadData()
    }

    func enableEditing(title: String?, filename: String?) {
        titleLabel.stringValue = title ?? ""
        filenameLabel.stringValue = filename ?? ""
        saveJsonButton.isEnabled = true
        savePlistButton.isEnabled = true
    }

    private func showSavePanel(for type: String, completion: @escaping (URL) -> Void) {
        let openPanel = NSSavePanel()
        openPanel.canCreateDirectories = false
        openPanel.allowedFileTypes = [type]
        openPanel.begin { (result) -> Void in
            if result == .OK {
                guard let url = openPanel.url else { return }
                completion(url)
            }
        }
    }

    private func showOpenPanel(for types: [String]?, completion: @escaping (URL) -> Void) {
        let openPanel = NSOpenPanel()
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = false
        openPanel.canCreateDirectories = false
        openPanel.canChooseFiles = true
        openPanel.allowedFileTypes = types
        openPanel.begin { (result) -> Void in
            if result == .OK {
                guard let url = openPanel.url else { return }
                completion(url)
            }
        }
    }
}

extension MainViewController: NSTableViewDelegate {
    func tableViewSelectionDidChange(_ notification: Notification) {
        deleteButton.isEnabled = !tableView.selectedRowIndexes.isEmpty
    }
}

extension MainViewController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        viewModel.ids.count
    }

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let columnId = tableColumn?.identifier.rawValue, let column = TableColumn(rawValue: columnId) else { return nil }

        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(column.rawValue), owner: nil) as? NSTableCellView
        let string: String
        switch column {
        case .number: string = String(row + 1)
        case .value: string = viewModel.ids[row]
        }

        cell?.textField?.stringValue = string
        return cell
    }
}
