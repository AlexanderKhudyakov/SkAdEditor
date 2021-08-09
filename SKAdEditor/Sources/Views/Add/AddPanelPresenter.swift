//
//  AddPanelController.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 05.08.2021.
//

import Foundation

final class AddPanelPresenter: AddPanelDelegate {
    weak var panel: AddPanel?

    func onFilterText(_ text: String) {
        let string = list(from: text).map { $0.rawValue }.joined(separator: "\n")
        panel?.replaceText(string)
    }

    func onConfirmText(_ text: String) {
        panel?.dismiss(with: list(from: text))
    }

    private func list(from text: String) -> SKAdNetworkList {
        (try? SKAdNetworkList(string: text)) ?? SKAdNetworkList()
    }
}
