import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tasks = [AnyObject]()
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
		
        self.setShowCompletedDefaultValue()
        
        // Migrate Core Data to App Group
        self.migratePersistentStore()
		
		// Styling
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = true
		UINavigationBar.appearance().backgroundColor = .clear
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().titleTextAttributes = [
            NSAttributedString.Key.foregroundColor : UIColor.white
		]
		window?.tintColor = UIColor.white
		
		
        // Local notifications
        let doneAction = UIMutableUserNotificationAction()
        doneAction.identifier = Constants.LocalNotifications.DONE_ACTION_IDENTIFIER
        doneAction.title = Constants.LocalNotifications.DONE_ACTION_TITLE
        doneAction.activationMode = .background          // don't bring app to foreground
        doneAction.isAuthenticationRequired = false      // don't require unlocking before performing action
        doneAction.isDestructive = true                 // display action in red
        
        let remindAction = UIMutableUserNotificationAction()
        remindAction.identifier = Constants.LocalNotifications.REMIND_ACTION_IDENTIFIER
        remindAction.title = Constants.LocalNotifications.REMIND_ACTION_TITLE
        remindAction.activationMode = .background
        remindAction.isDestructive = false
        
        let actionCategory = UIMutableUserNotificationCategory()
        actionCategory.identifier = Constants.LocalNotifications.ACTION_CATEGORY_IDENTIFIER
        actionCategory.setActions([remindAction, doneAction], for: .default)     // 4 actions max
        actionCategory.setActions([doneAction, remindAction], for: .minimal)     // for when space is limited - 2 actions max
        
        application.registerUserNotificationSettings(UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: NSSet(array: [actionCategory]) as? Set<UIUserNotificationCategory>))
		
	
		// Purchases
		Purchase.supportStorePurchase()
		Purchase.completeTransactions()
		Purchase.verifyReceiptCheck()
		
		
		// Migration from old themes
        var currentTheme = Constants.Purchases.WHITE_THEME
        if Utils.contains(key: Constants.Defaults.CURRENT_THEME) {
            currentTheme = Utils.string(key: Constants.Defaults.CURRENT_THEME)
        }
        
		
        if currentTheme != Constants.Purchases.FIRE_THEME &&
           currentTheme != Constants.Purchases.GRASSY_THEME &&
           currentTheme != Constants.Purchases.LIFE_THEME &&
           currentTheme != Constants.Purchases.NIGHTLIGHT_THEME &&
           currentTheme != Constants.Purchases.RIPE_THEME &&
           currentTheme != Constants.Purchases.SALVATION_THEME &&
           currentTheme != Constants.Purchases.SUNRISE_THEME &&
            currentTheme != Constants.Purchases.MALIBU_THEME {
            Utils.set(key: Constants.Defaults.CURRENT_THEME, value: Constants.Purchases.WHITE_THEME)
        }
        
        return true
    }
	
	
	func applicationWillEnterForeground(_ application: UIApplication) {
//		Purchase.restorePurchases(view: self.inputViewController!, showDialog: false)
		Purchase.verifyReceiptCheck()
	}
	
	
    func application(_ application: UIApplication, handleActionWithIdentifier identifier: String?, for notification: UILocalNotification, completionHandler: @escaping () -> Void) {
        
        // Get task attached to notification
        tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: "")
        
        for task in tasks {
            let taskUUID = task.value(forKey: Constants.CoreData.UUID) as! String
            let notificationUUID = notification.userInfo!["UUID"] as! String
            
            if (notificationUUID == taskUUID) {
                switch (identifier!) {
                    case Constants.LocalNotifications.DONE_ACTION_IDENTIFIER:
                        Tasks.deleteTask(task as! NSManagedObject)
                    case Constants.LocalNotifications.REMIND_ACTION_IDENTIFIER:
                        Utils.scheduleReminder(task as! NSManagedObject)
                    default: // switch statements must be exhaustive - this condition should never be met
                        print("Error: unexpected notification action identifier!")
                }
            }
        }
        
        completionHandler() // per developer documentation, app will terminate if we fail to call this
    }
	
	
    func application(_ application: UIApplication, didReceive notification: UILocalNotification) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    }
	
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "TodoListShouldRefresh"), object: self)
    }
	
	
    func applicationWillResignActive(_ application: UIApplication) {
        var badgeCount = 0
        var allGoals = CoreData.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
        allGoals = allGoals.filter({ (goal) -> Bool in
            return !(goal.value(forKey: Constants.CoreData.ARCHIVED) as! Bool? ?? false)
        })
        if allGoals.count > 0 {
            for goal in allGoals {
                let tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: goal.value(forKey: Constants.CoreData.NAME) as! String? ?? "")
                for task in tasks {
                    let archived = task.value(forKey: Constants.CoreData.ARCHIVED) as! Bool? ?? false
                    if !archived {
                        let when = task.value(forKey: Constants.CoreData.WHEN) as! Date
                        let dateComparisionResult: ComparisonResult = when.compare(Date())
                        if dateComparisionResult == ComparisonResult.orderedAscending {
                            badgeCount += 1
                        }
                    }
                }
            }
        }
        UIApplication.shared.applicationIconBadgeNumber =  badgeCount //tasksDue.count
    }
    
    func setShowCompletedDefaultValue() {
        if UserDefaults.standard.object(forKey: Constants.LocalData.SHOW_COMPLETED_TASKS) == nil {
            UserDefaults.standard.set(true, forKey: Constants.LocalData.SHOW_COMPLETED_TASKS)
        }
    }

    //* MARK: migrate Core Data
    func migratePersistentStore(){
        
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        var storeOptions = [AnyHashable : Any]()
        storeOptions[NSMigratePersistentStoresAutomaticallyOption] = true
        storeOptions[NSInferMappingModelAutomaticallyOption] = true
        let oldStoreUrl = self.applicationDocumentsDirectory.appendingPathComponent("Tasky.sqlite")
        let newStoreUrl = self.secureAppGroupPersistentStoreURL.appendingPathComponent("Tasky.sqlite")
        var targetUrl : URL? = nil
        var needMigrate = false
        var needDeleteOld = false
        
        if FileManager.default.fileExists(atPath: oldStoreUrl.path){
            needMigrate = true
            targetUrl = oldStoreUrl
        }
        
        if FileManager.default.fileExists(atPath: newStoreUrl.path){
            needMigrate = false
            targetUrl = newStoreUrl
            
            if FileManager.default.fileExists(atPath: oldStoreUrl.path){
                needDeleteOld = true
            }
        }
        if targetUrl == nil {
            targetUrl = newStoreUrl
        }
        needMigrate = true
        needDeleteOld = true
        if needMigrate {
            do {
                try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: targetUrl!, options: storeOptions)
                if let store = coordinator.persistentStore(for: targetUrl!)
                {
                    do {
                        try coordinator.migratePersistentStore(store, to: newStoreUrl, options: storeOptions, withType: NSSQLiteStoreType)
                        
                    } catch let error {
                        print("migrate failed with error : \(error)")
                    }
                }
            } catch let error {
                print(error)
            }
        }
        if needDeleteOld {
            self.deleteDocumentAtUrl(url: oldStoreUrl)
            let shmDocumentUrl = self.applicationDocumentsDirectory.appendingPathComponent("NoddApp.sqlite-shm")
            self.deleteDocumentAtUrl(url: shmDocumentUrl)
            let walDocumentUrl = self.applicationDocumentsDirectory.appendingPathComponent("NoddApp.sqlite-wal")
            self.deleteDocumentAtUrl(url: walDocumentUrl)
        }
    }
    
    func deleteDocumentAtUrl(url: URL!){
        let fileCoordinator = NSFileCoordinator(filePresenter: nil)
        fileCoordinator.coordinate(writingItemAt: url, options: .forDeleting, error: nil, byAccessor: {
            (urlForModifying) -> Void in
            do {
                try FileManager.default.removeItem(at: urlForModifying)
            }catch let error {
                print("Failed to remove item with error: \(error.localizedDescription)")
            }
        })
    }
    
	
	/* MARK: Core Data
	/////////////////////////////////////////// */
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.joeyt.Tasky" in the application's documents Application Support directory.
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as URL
    }()
    
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.joeyt.contact" in the application's App Group Application Support directory.
    lazy var secureAppGroupPersistentStoreURL : URL = {
        let fileManager = FileManager.default
        let groupDirectory = fileManager.containerURL(forSecurityApplicationGroupIdentifier: Constants.AppGroup.NAME)!
        return groupDirectory
    }()
    
    // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
    lazy var managedObjectModel: NSManagedObjectModel = {
        let modelURL = Bundle.main.url(forResource: "Tasky", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
    }()
    
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
    // Create the coordinator and store
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.secureAppGroupPersistentStoreURL.appendingPathComponent("Tasky.sqlite")
        
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
            
            print(error!)
        }
        
        return coordinator
    }()
    
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
    lazy var managedObjectContext: NSManagedObjectContext? = {
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    func saveContext () {
        if let moc = self.managedObjectContext {
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
