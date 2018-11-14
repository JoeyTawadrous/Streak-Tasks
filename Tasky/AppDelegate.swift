import UIKit
import CoreData


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    var tasks = [AnyObject]()
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
		
		
		// Styling
		UINavigationBar.appearance().setBackgroundImage(UIImage(), for: .default)
		UINavigationBar.appearance().shadowImage = UIImage()
		UINavigationBar.appearance().isTranslucent = true
		UINavigationBar.appearance().backgroundColor = .clear
		UINavigationBar.appearance().tintColor = UIColor.white
		UINavigationBar.appearance().titleTextAttributes = [
			NSAttributedStringKey.foregroundColor : UIColor.white
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
		var currentTheme = Constants.Purchases.MALIBU_THEME
		if Utils.contains(key: Constants.Defaults.CURRENT_THEME) {
			currentTheme = Utils.string(key: Constants.Defaults.CURRENT_THEME)
		}
		
		if currentTheme != Constants.Purchases.FIRE_THEME &&
		   currentTheme != Constants.Purchases.GRASSY_THEME &&
		   currentTheme != Constants.Purchases.LIFE_THEME &&
		   currentTheme != Constants.Purchases.MALIBU_THEME &&
		   currentTheme != Constants.Purchases.NIGHTLIGHT_THEME &&
		   currentTheme != Constants.Purchases.RIPE_THEME &&
		   currentTheme != Constants.Purchases.SALVATION_THEME &&
		   currentTheme != Constants.Purchases.SUNRISE_THEME {
			Utils.set(key: Constants.Defaults.CURRENT_THEME, value: Constants.Purchases.MALIBU_THEME)
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
        tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: "")
        
        let tasksDue = tasks.filter({ (task) -> Bool in
            let when = task.value(forKey: Constants.CoreData.WHEN) as! Date
            let dateComparisionResult: ComparisonResult = when.compare(Date())
            
            return dateComparisionResult == ComparisonResult.orderedAscending
        })
        UIApplication.shared.applicationIconBadgeNumber = tasksDue.count
    }

	
	
	/* MARK: Core Data
	/////////////////////////////////////////// */
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.joeyt.Tasky" in the application's documents Application Support directory.
    lazy var applicationDocumentsDirectory: URL = {
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1] as URL
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
        let url = self.applicationDocumentsDirectory.appendingPathComponent("Tasky.sqlite")
        
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
