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

public protocol Managed: class, NSFetchRequestResult {
    static var entityName: String { get }
    static var defaultSortDescriptors: [NSSortDescriptor] { get }
}

public extension Managed {
    static var defaultSortDescriptors: [NSSortDescriptor] { return [] }
    
    static var sortedFetchRequest: NSFetchRequest<Self> {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.sortDescriptors = defaultSortDescriptors
        return request
    }
    
    public static func sortedFetchRequest(withPredicate predicate: NSPredicate) -> NSFetchRequest<Self> {
        let request = sortedFetchRequest
        request.predicate = predicate
        return request
    }
}

public extension Managed where Self: NSManagedObject {
    
    static var entityName: String {
        return String(describing: self)
    }
    
    static func insertObject(in context: NSManagedObjectContext) -> Self {
        guard let obj = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context) as? Self else { fatalError("Wrong object type") }
        return obj
    }
    
    static func count(in context: NSManagedObjectContext, matching predicate: NSPredicate? = nil) -> Int {
        let request = NSFetchRequest<Self>(entityName: entityName)
        request.predicate = predicate
        return try! context.count(for: request)
    }
    
    static func fetch(in context: NSManagedObjectContext, configurationBlock: (NSFetchRequest<Self>) -> () = { _ in }) -> [Self] {
        let request = NSFetchRequest<Self>(entityName: entityName)
        configurationBlock(request)
        return try! context.fetch(request)
    }
    
    static func findOrCreate(in context: NSManagedObjectContext, matching predicate: NSPredicate, configure: (Self) -> ()) -> Self {
        guard let object = findOrFetch(in: context, matching: predicate) else {
            let newObject = insertObject(in: context)
            configure(newObject)
            return newObject
        }
        return object
    }
    
    static func findOrFetch(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        guard let object = materializedObject(in: context, matching: predicate) else {
            return fetch(in: context) { request in
                request.predicate = predicate
                request.returnsObjectsAsFaults = false
                request.fetchLimit = 1
                }.first
        }
        return object
    }
    
    static func materializedObject(in context: NSManagedObjectContext, matching predicate: NSPredicate) -> Self? {
        for object in context.registeredObjects where !object.isFault {
            guard type(of:object) == self, predicate.evaluate(with: object) else { continue }
            return object as! Self
        }
        return nil
    }
}


