//
//  AddSKAdPanel.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 05.08.2021.
//

import AppKit

protocol AddPanelInput: AnyObject {
    func replaceText(_ text: String)
    func dismiss(with list: SKAdNetworkList)
}

protocol AddPanelDelegate {
    func onFilterText(_ text: String)
    func onConfirmText(_ text: String)
}

final class AddPanel: NSPanel {
    var result: SKAdNetworkList { list ?? SKAdNetworkList() }

    private var list: SKAdNetworkList?

    @IBOutlet private weak var textView: NSTextView!

    private lazy var panelDelegate: AddPanelDelegate = {
        let presenter = AddPanelPresenter()
        presenter.panel = self
        return presenter
    }()

    @IBAction func onCancel(_ sender: NSButton) {
        sheetParent?.endSheet(self, returnCode: .cancel)
    }

    @IBAction func onAdd(_ sender: NSButton) {
        panelDelegate.onConfirmText(textView.string)
    }

    @IBAction func onFilter(_ sender: NSButton) {
        panelDelegate.onFilterText(textView.string)
    }
}

extension AddPanel: AddPanelInput {
    func dismiss(with list: SKAdNetworkList) {
        self.list = list
        sheetParent?.endSheet(self, returnCode: .OK)
    }

    func replaceText(_ text: String) {
        textView.setAlignment(.center, range: .init(text.startIndex..., in: text))
        textView.string = text
    }
}
