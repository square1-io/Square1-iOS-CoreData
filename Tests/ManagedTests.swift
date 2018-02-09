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

import XCTest
import CoreData
@testable import Square1CoreData

class ManagedTests: XCTestCase {

  var coreDataStack: TestCoreDataManager!
  var context: NSManagedObjectContext {
    return coreDataStack.viewContext
  }
  
  override func setUp() {
    super.setUp()
    coreDataStack = TestCoreDataManager()
    context.performChangesAndWait {
      Person.deleteAll(in: self.context)
    }
  }
  
  override func tearDown() {
    super.tearDown()
    coreDataStack = nil
  }
  
  func testEntityName() {
    XCTAssertEqual(Person.entityName, "Person")
  }
  
  func testInsertion() {
    let ex = expectation(description: "Finished performing changes")
    
    context.perform(changes: {
      _ = Person.insertObject(in: self.context)
      ex.fulfill()
    })
    
    waitForExpectations(timeout: 5, handler: nil)
    XCTAssertEqual(Person.count(in: self.context), 1)
  }
  
  func testFindOrCreateFindsSavedPersonInContext() {
    let person = Person.insertObject(in: self.context)
    person.name = "Alex"
    
    let saved = self.context.saveOrRollback()
    
    let predicate = NSPredicate(format: "name == %@", "Alex")
    XCTAssert(saved)
    XCTAssertEqual(Person.findOrCreate(in: context, matching: predicate), person)
    XCTAssertEqual(Person.count(in: context), 1)
  }
  
  func testFindOrCreateFindsNotYetSavedPersonInContext() {
    let person = Person.insertObject(in: context)
    person.name = "Alex"
    
    let predicate = NSPredicate(format: "name == %@", "Alex")
    XCTAssertEqual(Person.findOrCreate(in: context, matching: predicate), person)
    XCTAssertEqual(Person.count(in: context), 1)
  }
  
  func testCouldntFindButCreatesNewOne() {
    let person = Person.insertObject(in: self.context)
    person.name = "Unknown"
    
    let predicate = NSPredicate(format: "name == %@", "Alex")
    XCTAssertNotEqual(Person.findOrCreate(in: context, matching: predicate), person)
    XCTAssertEqual(Person.count(in: context), 2)
  }
  
  func testFindOrCreateCreatesNew() {
    let predicate = NSPredicate(format: "name == %@", "notexistingname")
    _ = Person.findOrCreate(in: context, matching: predicate)
    XCTAssertEqual(Person.count(in: context), 1)
  }
  
  func testFindOrCreateCreatesNewWithDetails() {
    let predicate = NSPredicate(format: "name == %@", "notexistingname")
    let person = Person.findOrCreate(in: context, matching: predicate, configure: { p in
      p.name = "Alex"
      p.surname = "Rubio"
    })
    
    XCTAssertEqual(Person.count(in: context), 1)
    XCTAssertEqual(person.name, "Alex")
    XCTAssertEqual(person.surname, "Rubio")
  }
  
  func testCountWithPredicate() {
    let person1 = Person.insertObject(in: context)
    person1.name = "Roberto"
    person1.surname = "Pastor"
    
    let person2 = Person.insertObject(in: context)
    person2.name = "Roberto"
    person2.surname = "Prato"
    
    let person3 = Person.insertObject(in: context)
    person3.name = "Alex"
    person3.surname = "Rubio"
    
    let predicate = NSPredicate(format: "name == %@", "Roberto")
    XCTAssertEqual(Person.count(in: context, matching: predicate), 2)
  }
  
  func testFindOrFetchNil() {
    let predicate = NSPredicate(format: "name == %@", "notexistingname")
    let fetchedPerson = Person.findOrFetch(in: context, matching: predicate)
    XCTAssertNil(fetchedPerson)
  }
  
  func testFindOrFetchValidPerson() {
    let person1 = Person.insertObject(in: context)
    person1.name = "Roberto"
    person1.surname = "Pastor"
    
    let predicate = NSPredicate(format: "name == %@", "Roberto")
    let fetchedPerson = Person.findOrFetch(in: context, matching: predicate)
    XCTAssertNotNil(fetchedPerson)
  }
}
