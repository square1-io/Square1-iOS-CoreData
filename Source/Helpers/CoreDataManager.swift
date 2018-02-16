// Copyright © 2017 Square1.
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

import CoreData
import Square1Tools

open class CoreDataManager {
  
  private var modelName: String
  
  public init(modelName: String) {
    self.modelName = modelName
  }
  
  private lazy var storeContainer: NSPersistentContainer = {
    let modelURL = Bundle(for: type(of: self)).url(forResource: modelName, withExtension: "momd")
    let model = NSManagedObjectModel(contentsOf: modelURL!)
    
    let container = NSPersistentContainer(name: modelName, managedObjectModel: model!)
    
    container.loadPersistentStores {
      (storeDescription, error) in
      if let error = error as NSError? {
        Log("Unresolved error \(error), \(error.userInfo)")
      }
    }
    container.viewContext.automaticallyMergesChangesFromParent = true
    return container
  }()
  
  public var viewContext: NSManagedObjectContext {
    return storeContainer.viewContext
  }
  
  public func newBackgroundContext() -> NSManagedObjectContext {
    return storeContainer.newBackgroundContext()
  }
  
  public func performBackgroundTask(_ block: @escaping (NSManagedObjectContext) -> Void) {
    storeContainer.performBackgroundTask(block)
  }
}
