//
//  MainPresenter.swift
//  SKAdEditor
//
//  Created by Александр Худяков on 30.07.2021.
//

import Foundation

final class MainPresenter {
    weak var view: MainViewControllerInput?

    var list: SKAdNetworkList?
    var plistURL: URL?
}

extension MainPresenter: MainViewControllerDelegate {
    func didRemoveValues(at indexSet: IndexSet) {
        guard var newList = list, var viewModel = view?.viewModel else { return }

        let sortedIndexSet = indexSet.sorted(by: >)
        sortedIndexSet.forEach { newList.remove(at: $0) }
        list = newList
        viewModel.ids = newList.strings
        view?.viewModel = viewModel
    }

    func didAddValues(list: SKAdNetworkList) {
        guard var newList = self.list, var viewModel = view?.viewModel else { return }

        newList.append(list)
        self.list = newList
        viewModel.ids = newList.strings
        view?.viewModel = viewModel
    }

    func didLoad() {
        view?.viewModel = MainViewController.ViewModel(state: .initial)
        list = SKAdNetworkList()
    }

    func didCreateNewList() {
        list = SKAdNetworkList()
        view?.viewModel = MainViewController.ViewModel(state: .editing,
                                                       title: "New list created.",
                                                       ids: list.strings )
    }

    func didOpenTextFile(at url: URL) {
        guard let data = try? Data(contentsOf: url),
              let newList = try? SKAdNetworkList(format: .json, data: data) else { return }

        list = newList
        view?.viewModel = MainViewController.ViewModel(state: .editing,
                                                       filename: url.lastPathComponent,
                                                       title: "JSON selected:",
                                                       ids: list.strings)
    }

    func didOpenPlist(at url: URL) {
        guard let data = try? Data(contentsOf: url),
              let newList = try? SKAdNetworkList(format: .plistXml, data: data) else { return }

        list = newList
        view?.viewModel = MainViewController.ViewModel(state: .editing,
                                                       filename: url.lastPathComponent,
                                                       title: "JSON selected:",
                                                       ids: list.strings)
        plistURL = url
    }

    func didSaveTextFile(at url: URL) {
        guard let list = list else { return }
        let data = try? list.export(format: .json)
        try? data?.write(to: url)
    }

    func didSavePlist(at url: URL) {
        guard let list = list else { return }
        guard let data = try? list.export(format: .plistXml),
              let exportedDictionary = try? Dictionary<String, Any>.withPlist(data: data) else { return }

        var plistDictionary: Dictionary<String, Any>?
        if let plistURL = plistURL {
            plistDictionary = try? Dictionary<String, Any>.withPlist(at: plistURL)
            let key = PlistKey.skAdItems.rawValue
            plistDictionary?[key] = exportedDictionary[key]
        }

        let dictionaryToExport = plistDictionary ?? exportedDictionary
        (dictionaryToExport as NSDictionary).write(toFile: url.path, atomically: true)
    }
}

extension Optional where Wrapped == SKAdNetworkList {
    var strings: [String] {
        guard let list = self else { return  [] }
        return list.strings
    }
}

extension SKAdNetworkList {
    var strings: [String] {
        self.map { $0.rawValue }
    }
}
