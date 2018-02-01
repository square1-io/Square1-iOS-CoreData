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

import Foundation
import Square1CoreData
import CoreData

class TestCoreDataManager: SQ1CoreDataManager {
  
  convenience init() {
    self.init(modelName: "Test")
  }
  
//  override init(modelName: String) {
//    super.init(modelName: modelName)
//    
//    let persistentStoreDescription = NSPersistentStoreDescription()
//    persistentStoreDescription.type = NSInMemoryStoreType
//    
//    let bundle = Bundle(for: type(of: self))
//    guard let url = bundle.url(forResource: modelName, withExtension: "momd") else {
//      fatalError("Could not parse url from model name: \(modelName)")
//    }
//    
//    guard let model = NSManagedObjectModel(contentsOf: url) else {
//      fatalError("Could not find a model with model name: \(modelName)")
//    }
//    
//    let container = NSPersistentContainer(name: modelName, managedObjectModel: model)
//    container.persistentStoreDescriptions = [persistentStoreDescription]
//    container.loadPersistentStores {
//      (storeDescription, error) in
//      if let error = error {
//        fatalError (
//          "Unresolved error \(error.localizedDescription)")
//      }
//    }
//    self.storeContainer = container
//  }
}
