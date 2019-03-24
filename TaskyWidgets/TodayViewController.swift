import UIKit
import NotificationCenter
import CoreData

class TodayViewController: UIViewController, NCWidgetProviding, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var goals = [AnyObject]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tasks = self.fetchTodayCatchups(Constants.CoreData.TASK, startDate: Date().startOfDay, endDate: Date().endOfDay)
        
        for task in tasks
        {
            let name = task.value(forKey: Constants.CoreData.NAME) as! String?
            goals.append(self.fetchPeople(Constants.CoreData.GOAL, name: name!)[0])
        }
        
        self.goals = goals.reversed() // newest first
        
        if self.goals.count > 2
        {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .expanded
        }
        else
        {
            self.extensionContext?.widgetLargestAvailableDisplayMode = .compact
        }
        
        self.tableView.reloadData()
        
        // Do any additional setup after loading the view from its nib.
    }
        
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        if goals.count == 0 {
            return 1
        }
        else {
            return goals.count
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if goals.count == 0 {
            return 110
        }
        else {
            return 55
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        if goals.count == 0
        {
            var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "noCell")
            if cell == nil {
                cell = GoalTableViewCell(style: UITableViewCell.CellStyle.value1, reuseIdentifier: "noCell")
            }
            return cell
        }
        else
        {
            var cell: GoalTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell") as? GoalTableViewCell
            if cell == nil {
                cell = GoalTableViewCell(style:UITableViewCell.CellStyle.value1, reuseIdentifier: "cell")
            }
            let goal = goals[indexPath.row]
            
            
            let name = goal.value(forKey: Constants.CoreData.NAME) as! String?
            cell.nameLabel!.text = name
            
            let tasks = self.fetchCatchupsCount(Constants.CoreData.TASK, name: name!, startDate: Date().startOfDay, endDate: Date().endOfDay)
            
            cell.taskCountLabel!.text = String(tasks.count)
            
            let thumbnail = goal.value(forKey: Constants.CoreData.THUMBNAIL) as! String?
            cell.thumbnailImageView!.image = UIImage(named: thumbnail!)
            cell.thumbnailImageView!.image = cell.thumbnailImageView!.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
            cell.thumbnailImageView!.tintColor = UIColor.black.withAlphaComponent(0.7)
            
            return cell
        }
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if let url = URL(string: "TestyLocalHost://")
        {
            self.extensionContext?.open(url, completionHandler: {success in print("called url complete handler: \(success)")})
        }
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        completionHandler(NCUpdateResult.newData)
    }
    
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize)
    {
        if activeDisplayMode == .expanded
        {
            preferredContentSize = self.tableView.contentSize
        }
        else
        {
            preferredContentSize = maxSize
        }
    }
    func fetchPeople(_ key: String, name: String) -> [AnyObject] {
        var fetchedResults = [AnyObject]()
        let managedContext = CoreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: key)
        
        fetchRequest.predicate = NSPredicate(format:"name == %@", name)
        
        do {
            fetchedResults = try managedContext!.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return fetchedResults
    }
    func fetchCatchupsCount(_ key: String, name: String, startDate: Date, endDate : Date) -> [AnyObject] {
        var fetchedResults = [AnyObject]()
        let managedContext = CoreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: key)
        
        fetchRequest.predicate = NSPredicate(format:"name == %@ AND when>= %@ AND when<= %@", name, startDate as CVarArg, endDate as CVarArg)
        
        do {
            fetchedResults = try managedContext!.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return fetchedResults
    }
    func fetchTodayCatchups(_ key: String, startDate: Date, endDate : Date) -> [AnyObject] {
        var fetchedResults = [AnyObject]()
        let managedContext = CoreDataStack.managedObjectContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: key)
        
        fetchRequest.predicate = NSPredicate(format: "when>= %@ AND when<= %@", startDate as CVarArg, endDate as CVarArg)
        fetchRequest.returnsObjectsAsFaults = false
        fetchRequest.propertiesToGroupBy = ["name"]
        fetchRequest.propertiesToFetch = ["name"]
        fetchRequest.resultType = .dictionaryResultType
        
        do {
            fetchedResults = try managedContext!.fetch(fetchRequest)
        } catch {
            print(error)
        }
        
        return fetchedResults
    }
    
}

class GoalTableViewCell : UITableViewCell {
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var taskCountLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
}

class CoreDataStack {
    
    /* MARK: Core Data
     /////////////////////////////////////////// */
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.joeyt.contact" in the application's documents Application Support directory.
    static var secureAppGroupPersistentStoreURL : URL = {
        let fileManager = FileManager.default
        let groupDirectory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppGroup.NAME)!
        return groupDirectory
    }()
    
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    static var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Tasky", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    static var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: CoreDataStack.managedObjectModel)
        let url = CoreDataStack.secureAppGroupPersistentStoreURL.appendingPathComponent("Tasky.sqlite")
        
        var failureReason = "There was an error creating or loading the application's saved data."
        
        do {
            try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: nil)
        } catch {
            var error: NSError? = nil
            var dict = [String: AnyObject]()
            
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
            dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            
            print(error)
        }
        
        return coordinator
    }()
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    static var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = CoreDataStack.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()
    
    func saveContext () {
        if let moc = CoreDataStack.managedObjectContext {
            do {
                if moc.hasChanges {
                    try moc.save()
                }
            } catch {
                print(error)
            }
        }
    }
}
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }
}
