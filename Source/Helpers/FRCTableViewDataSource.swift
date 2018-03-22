// Copyright © 2018 Square1.
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit
import CoreData

public protocol FRCTableViewDataSourceDelegate: class {
  associatedtype Object: NSFetchRequestResult
  associatedtype Cell: UITableViewCell
  func configure(_ cell: Cell, for object: Object)
  func dataSourceDidChangeContent()
}

public class FRCTableViewDataSource<Delegate: FRCTableViewDataSourceDelegate>: NSObject, UITableViewDataSource, NSFetchedResultsControllerDelegate {
  
  public typealias Object = Delegate.Object
  public typealias Cell = Delegate.Cell
  
  fileprivate let tableView: UITableView
  fileprivate let fetchedResultsController: NSFetchedResultsController<Object>
  fileprivate weak var delegate: Delegate!
  fileprivate let cellIdentifier: String
  
  public var count: Int {
    return fetchedResultsController.fetchedObjects?.count ?? 0
  }
  
  public init(tableView: UITableView,
                cellIdentifier: String,
                fetchedResultsController: NSFetchedResultsController<Object>,
                delegate: Delegate) {
    self.tableView = tableView
    self.fetchedResultsController = fetchedResultsController
    self.cellIdentifier = cellIdentifier
    self.delegate = delegate
    super.init()
    fetchedResultsController.delegate = self
    try! fetchedResultsController.performFetch()
    tableView.dataSource = self
    tableView.reloadData()
  }
  
  public var selectedObject: Object? {
    guard let indexPath = tableView.indexPathForSelectedRow else { return nil }
    return objectAtIndexPath(indexPath)
  }
  
  public func objectAtIndexPath(_ indexPath: IndexPath) -> Object {
    return fetchedResultsController.object(at: indexPath)
  }
  
  public func reconfigureFetchRequest(_ configure: (NSFetchRequest<Object>) -> ()){
    NSFetchedResultsController<NSFetchRequestResult>.deleteCache(withName: fetchedResultsController.cacheName)
    configure(fetchedResultsController.fetchRequest)
    do {
      try fetchedResultsController.performFetch()
    } catch {
      fatalError("Error performing fetch request")
    }
    tableView.reloadData()
  }
  
  // MARK: - UITableViewDataSource
  
  public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    guard let section = fetchedResultsController.sections?[section] else { return 0 }
    return section.numberOfObjects
  }
  
  public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let object = fetchedResultsController.object(at: indexPath)
    guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? Cell else {
      fatalError("Unexpected cell type for indentifier \(cellIdentifier) at indexPath \(indexPath)")
    }
    delegate.configure(cell, for: object)
    return cell
  }
  
  // MARK: - NSFetchedResultsControllerDelegate
  
  public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.beginUpdates()
  }
  
  public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>,
                  didChange anObject: Any,
                  at indexPath: IndexPath?,
                  for type: NSFetchedResultsChangeType,
                  newIndexPath: IndexPath?) {
    switch type {
    case .insert:
      guard let indexPath = newIndexPath else { fatalError("IndexPath can't be nil") }
      tableView.insertRows(at: [indexPath], with: .fade)
    case .update:
      guard let indexPath = indexPath else { fatalError("IndexPath can't be nil") }
      let object = objectAtIndexPath(indexPath)
      guard let cell = tableView.cellForRow(at: indexPath) as? Cell else { break }
      delegate.configure(cell, for: object)
    case .move:
      guard let indexPath = indexPath else { fatalError("IndexPath can't be nil") }
      guard let newIndexPath = newIndexPath else { fatalError("IndexPath can't be nil") }
      tableView.deleteRows(at: [indexPath], with: .fade)
      tableView.insertRows(at: [newIndexPath], with: .fade)
    case .delete:
      guard let indexPath = indexPath else { fatalError("IndexPath can't be nil") }
      tableView.deleteRows(at: [indexPath], with: .fade)
    }
  }
  
  public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
    tableView.endUpdates()
    delegate.dataSourceDidChangeContent()
  }
}
