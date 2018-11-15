import UIKit
import CoreData


class Tasks: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct ClassConstants {
        static let REASON = "Desctiption: "
	}
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var addButton: UIBarButtonItem!
	
    var tasks = [AnyObject]()
    var selectedGoal = String()
	
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewWillAppear(_ animated: Bool) {
		tableView.delegate = self
		tableView.dataSource = self
		refresh();
		
		// Styling
		Utils.insertGradientIntoView(viewController: self)
		Utils.createFontAwesomeBarButton(button: addButton, icon: .plus, style: .solid)
		tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		
		// Observer for every notification received
		NotificationCenter.default.addObserver(self, selector: #selector(Tasks.backgoundNofification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil);
    }
	
	@objc func backgoundNofification(_ noftification:Notification){
		refresh()
    }
    
	func refresh() {
		selectedGoal = Utils.string(key: Constants.LocalData.SELECTED_GOAL)
		self.title = selectedGoal
		
		tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: selectedGoal)
		tasks = tasks.reversed() // newest first
		
		self.tableView.reloadData()
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Core Functionality
	/////////////////////////////////////////// */
    class func deleteTask(_ task: NSManagedObject) {
        let taskUUID = task.value(forKey: Constants.CoreData.UUID) as! String
		
        // Remove notification for task object & update app icon badge notification count
        for notification in UIApplication.shared.scheduledLocalNotifications!{
            let notificationUUID = notification.userInfo!["UUID"] as! String
            
            if (notificationUUID == taskUUID) {
                UIApplication.shared.cancelLocalNotification(notification)
                break
            }
        }
        Tasks.setBadgeNumbers()
		
        // Remove task object
        let managedObjectContect = CoreData.fetchManagedObjectContext()
        managedObjectContect.delete(task)
        do {
            try managedObjectContect.save()
        }
		catch {
            print(error)
        }
    }
    
    class func setBadgeNumbers() {
        let notifications = UIApplication.shared.scheduledLocalNotifications // all scheduled notifications
        let tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: "")
        
        UIApplication.shared.cancelAllLocalNotifications()
        
        // for every notification
        for notification in notifications! {
            for task in tasks {
                let taskUUID = task.value(forKey: Constants.CoreData.UUID) as! String
                let notificationUUID = notification.userInfo!["UUID"] as! String
				
                if (notificationUUID == taskUUID) {
                    let overdueTasks = tasks.filter({ (task) -> Bool in
                        let when = task.value(forKey: Constants.CoreData.WHEN) as! Date
                        let dateComparisionResult: ComparisonResult = notification.fireDate!.compare(when)
                        return dateComparisionResult == ComparisonResult.orderedAscending
                    })
					
					notification.repeatInterval = NSCalendar.Unit.day
                    notification.applicationIconBadgeNumber = overdueTasks.count   // set new badge number
                    UIApplication.shared.scheduleLocalNotification(notification)      // reschedule notification
                }
            }
        }
    }

	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TasksTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell") as? TasksTableViewCell
        if cell == nil {
            cell = TasksTableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
        }
		let tasks = self.tasks[indexPath.row]
		let type = tasks.value(forKey: Constants.CoreData.TYPE) as! String?
		
		// Style
		cell!.selectionStyle = .none
		
        cell.reasonLabel!.text = tasks.value(forKey: Constants.CoreData.REASON) as! String?
		cell.thumbnailImageView!.image = UIImage(named: type!)
        cell.thumbnailImageView!.image = cell.thumbnailImageView!.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.thumbnailImageView!.tintColor = UIColor.white
		
        cell.updateConstraints()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let deleteAction = UITableViewRowAction(style: .default, title: "Complete") {_,_ in 
            let task = self.tasks[indexPath.row] as! NSManagedObject
            Tasks.deleteTask(task)
			
            // Refresh table
            self.tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: self.selectedGoal)
            self.tasks = self.tasks.reversed() // newest first
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.reloadData()
			
			// Achievements
			Task.updateTasksCompleted(view: self)
        }
        
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		
        // Set task in defaults (so we can get task details it later)
		Utils.set(key: Constants.LocalData.SELECTED_TASK_INDEX, value: NSInteger(indexPath.row))
		
        // Show task view
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
        let taskView = storyBoard.instantiateViewController(withIdentifier: Constants.Views.TASK) as! Task
        self.show(taskView as UIViewController, sender: taskView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if tasks.count == 0 {
			let emptyView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
			
			let emptyImageView = UIImageView(frame: CGRect(x:0, y:0, width:150, height:150))
			emptyImageView.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.30)
			let emptyImage = Utils.imageResize(UIImage(named: "Fitness")!, sizeChange: CGSize(width: 150, height: 150)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			emptyImageView.image = emptyImage
			emptyImageView.tintColor = UIColor.white
			emptyView.addSubview(emptyImageView)
			
			let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width - 100, height:self.view.bounds.size.height))
			emptyLabel.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.53)
			emptyLabel.text = "Now that you have created a goal, what will it take to achieve it? Create a task now!"
			emptyLabel.font = UIFont.GothamProRegular(size: 15.0)
			emptyLabel.textAlignment = NSTextAlignment.center
			emptyLabel.textColor = UIColor.white
			emptyLabel.numberOfLines = 5
			emptyView.addSubview(emptyLabel)
			
			self.tableView.backgroundView = emptyView
			
			return 0
		}
		else {
			return tasks.count
		}
    }
}


class TasksTableViewCell : UITableViewCell {
    @IBOutlet var reasonLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
}
