import UIKit
import CoreData


class CoreData {
	class func createDemoData() -> [AnyObject] {
		var goals = [AnyObject]()
		let goal1Name = "Start Up Company"
		let goal2Name = "Write For Forbes"
		let goal3Name = "Become Master Cook"
		let goal4Name = "Skiing Trip"
		let goal5Name = "Learn To Code"
		
		goals.insert(CoreData.createGoal(name: goal1Name), at: 0)
		goals.insert(CoreData.createGoal(name: goal2Name), at: 0)
		goals.insert(CoreData.createGoal(name: goal3Name), at: 0)
		goals.insert(CoreData.createGoal(name: goal4Name), at: 0)
		goals.insert(CoreData.createGoal(name: goal5Name), at: 0)
		
		CoreData.createTask(goalName: goal1Name, type: "Financial" as AnyObject, when: Date(), reason: "Discuss Financials" as AnyObject)
		CoreData.createTask(goalName: goal1Name, type: "Financial" as AnyObject, when: Date(), reason: "Discuss Financials" as AnyObject)
		CoreData.createTask(goalName: goal1Name, type: "Financial" as AnyObject, when: Date(), reason: "Discuss Financials" as AnyObject)
		CoreData.createTask(goalName: goal2Name, type: "Financial" as AnyObject, when: Date(), reason: "Discuss Financials" as AnyObject)
		CoreData.createTask(goalName: goal3Name, type: "Hobbies" as AnyObject, when: Date(), reason: "Learn 5 new recipes" as AnyObject)
		CoreData.createTask(goalName: goal3Name, type: "Health" as AnyObject, when: Date(), reason: "Only eat protein & veg" as AnyObject)
		CoreData.createTask(goalName: goal3Name, type: "Financial" as AnyObject, when: Date(), reason: "Buy in bulk" as AnyObject)
		CoreData.createTask(goalName: goal3Name, type: "Efficiency" as AnyObject, when: Date(), reason: "Meal prep" as AnyObject)
		CoreData.createTask(goalName: goal4Name, type: "Financial" as AnyObject, when: Date(), reason: "Discuss Financials" as AnyObject)
		CoreData.createTask(goalName: goal4Name, type: "Financial" as AnyObject, when: Date(), reason: "Discuss Financials" as AnyObject)
		CoreData.createTask(goalName: goal5Name, type: "Financial" as AnyObject, when: Date(), reason: "Discuss Financials" as AnyObject)
		
		return goals
	}
	
	class func createGoal(name: String) -> AnyObject {
		let goal = CoreData.createObject(Constants.CoreData.GOAL)
		goal.setValue(name, forKey: Constants.CoreData.NAME)
		goal.setValue(CoreData.getRandomImageString(), forKey: Constants.CoreData.THUMBNAIL)
		CoreData.saveObject()
		return goal
	}
	
	class func createTask(goalName: String, type: AnyObject, when: Date, reason: AnyObject) {
		let task = CoreData.createObject(Constants.CoreData.TASK)
		task.setValue(goalName, forKey: Constants.CoreData.NAME)
		task.setValue(type, forKey: Constants.CoreData.TYPE)
		task.setValue(when, forKey: Constants.CoreData.WHEN)
		task.setValue(reason, forKey: Constants.CoreData.REASON)
		task.setValue(UUID().uuidString, forKey: Constants.CoreData.UUID);
		CoreData.saveObject()
	}
    
    class func createArchievedTask(goalName: String, type: AnyObject, when: Date, reason: AnyObject) {
        let task = CoreData.createObject(Constants.CoreData.ARCHIEVE_TASK)
        task.setValue(goalName, forKey: Constants.CoreData.NAME)
        task.setValue(type, forKey: Constants.CoreData.TYPE)
        task.setValue(when, forKey: Constants.CoreData.WHEN)
        task.setValue(reason, forKey: Constants.CoreData.REASON)
        task.setValue(UUID().uuidString, forKey: Constants.CoreData.UUID);
        task.setValue(true, forKey: Constants.CoreData.ARCHIVED)
        CoreData.saveObject()
    }
	
	class func createObject(_ type: String) -> NSManagedObject {
		let entity = NSEntityDescription.entity(forEntityName: type, in: fetchManagedObjectContext())
		let object = NSManagedObject(entity: entity!, insertInto:fetchManagedObjectContext())
		return object;
	}
	
	class func saveObject() {
		do {
			try fetchManagedObjectContext().save()
		}
		catch {
			print("Could not save \(error)")
		}
	}
	
	class func fetchCoreDataObject(_ key: String, predicate: String) -> [AnyObject] {
		var fetchedResults = [AnyObject]()
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: key)
		
		if predicate != "" {
			fetchRequest.predicate = NSPredicate(format:"name == %@", predicate)
		}
		
		do {
			fetchedResults = try managedContext.fetch(fetchRequest)
		} catch {
			print(error)
		}
		
		return fetchedResults
	}
	
	class func fetchManagedObjectContext() -> NSManagedObjectContext {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		return managedContext
	}
	
	class func getRandomImageString() -> String {
		var imageArray:[String] = []
		
		for i in 1...54 {
			let image = String(i) + ".png"
			imageArray.append(image)
		}
		
		let randomImageIndex = Int(arc4random_uniform(UInt32(imageArray.count)))
		return imageArray[randomImageIndex]
	}
}


