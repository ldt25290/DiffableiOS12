//
//  QuickSearchDelegateDatasource.swift
//  DiffableiOS12
//
//  Created by Daniel Yount on 2/7/20.
//  Copyright © 2020 Daniel Yount. All rights reserved.
//

import Foundation
import UIKit

class QuickSearchDataSourceAdapter {
    weak var delgate: SearchViewController?
    
    var dataSource = QuickSearchTableViewDatasource()
    
    @available(iOS 13.0, *)
    lazy var quickSearchDiffableDatasource: UITableViewDiffableDataSource<SearchSection, Employee> = makeQuickSearchDatasource()
    
    @available(iOS 13, *)
    private func makeQuickSearchDatasource() -> UITableViewDiffableDataSource<SearchSection, Employee> {
        guard let tableView = delgate?.quickResultsTableView else {
            fatalError("Missing delegate for RecentSearchDataSourceAdapter.")
        }
        return UITableViewDiffableDataSource(tableView: tableView) { tableView, indexPath, result in
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? SearchResultTableViewCell else { return UITableViewCell() }
            cell.categoryLabel.text = result.salary
            cell.titleLabel.text = result.name
            cell.model = result
            return cell
        }
    }
    
    func updateQuickSearchData(results: [Employee]) {
        if #available(iOS 13, *) {
            var snapshot = NSDiffableDataSourceSnapshot<SearchSection, Employee>()
            snapshot.appendSections([.main])
            snapshot.appendItems(results, toSection: .main)
            quickSearchDiffableDatasource.apply(snapshot, animatingDifferences: true)
        } else {
            dataSource.quickSearchItems = results
        }
    }
}

class QuickSearchTableViewDelegate: NSObject, UITableViewDelegate {
    
    weak var searchViewController: SearchViewController?

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? SearchResultTableViewCell, let model = cell.model else { return }
        if !Coordinators.search.cachedRecentResults.contains(model) {
            Coordinators.search.cachedRecentResults.append(model)
        }
        searchViewController?.quickResultsTableView.isHidden = true
        searchViewController?.searchBar.resignFirstResponder()
        searchViewController?.updateUI()
        searchViewController?.recentResultsTableView.isHidden = false

        tableView.deselectRow(at: indexPath, animated: false)
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        UIView()
    }
}

class QuickSearchTableViewDatasource: NSObject, UITableViewDataSource {

    var quickSearchItems: [Employee]?

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let results = quickSearchItems else { return 0 }
        return results.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let results = quickSearchItems, let cell = tableView.dequeueReusableCell(withIdentifier: "searchResultCell") as? SearchResultTableViewCell else {
            return UITableViewCell()
        }
        cell.model = results[indexPath.row]
        cell.titleLabel.text = results[indexPath.row].name
        cell.categoryLabel.text = results[indexPath.row].salary
        return cell
    }


}
