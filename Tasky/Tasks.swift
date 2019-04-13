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
    var cameFromArchive = false
	
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewWillAppear(_ animated: Bool) {
		tableView.delegate = self
		tableView.dataSource = self
		refresh();
		
		// Styling
		Utils.insertGradientIntoView(viewController: self)
		Utils.createFontAwesomeBarButton(button: addButton, icon: .plus, style: .solid)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
		
		// Observer for every notification received
        NotificationCenter.default.addObserver(self, selector: #selector(Tasks.backgoundNofification(_:)), name: UIApplication.willEnterForegroundNotification, object: nil);
        if self.cameFromArchive {
            self.navigationItem.rightBarButtonItems = []
        }
    }
	
	@objc func backgoundNofification(_ noftification:Notification){
		refresh()
    }
    
	func refresh() {
		selectedGoal = Utils.string(key: Constants.LocalData.SELECTED_GOAL)
		self.title = selectedGoal
		
		tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: selectedGoal)
		tasks = tasks.reversed() // newest first
        for task in tasks {
            task.setValue(false, forKey: Constants.CoreData.ARCHIVED)
        }
        if UserDefaults.standard.bool(forKey: Constants.LocalData.SHOW_COMPLETED_TASKS) {
            let archivedTasks = CoreData.fetchCoreDataObject(Constants.CoreData.ARCHIEVE_TASK, predicate: selectedGoal)
            for task in archivedTasks {
                task.setValue(true, forKey: Constants.CoreData.ARCHIVED)
            }
            tasks.append(contentsOf: archivedTasks)
        }
		
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
                        let archived = task.value(forKey: Constants.CoreData.ARCHIVED) as! Bool? ?? false
                        if archived {
                            return false
                        }
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
    
    func archieveTask(_ task: NSManagedObject) {
        let goalName = task.value(forKey: Constants.CoreData.NAME) as! String? ?? ""
        let type = task.value(forKey: Constants.CoreData.TYPE)
        let date = task.value(forKey: Constants.CoreData.WHEN) as! Date? ?? Date()
        let reason = task.value(forKey: Constants.CoreData.REASON)
        
        CoreData.createArchievedTask(goalName: goalName, type: type as AnyObject, when: date, reason: reason as AnyObject)
    }

	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: TasksTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell") as? TasksTableViewCell
        if cell == nil {
            cell = TasksTableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        }
		let tasks = self.tasks[indexPath.row]
		let type = tasks.value(forKey: Constants.CoreData.TYPE) as! String?
        let archived = tasks.value(forKey: Constants.CoreData.ARCHIVED) as! Bool? ?? false
		
		// Style
		cell!.selectionStyle = .none
		
        cell.reasonLabel!.text = tasks.value(forKey: Constants.CoreData.REASON) as! String?
		cell.thumbnailImageView!.image = UIImage(named: type!)
        cell.thumbnailImageView!.image = cell.thumbnailImageView!.image!.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        if !archived {
            cell.thumbnailImageView!.tintColor = UIColor.white
        } else {
            cell.thumbnailImageView!.tintColor = UIColor(white: 1.0, alpha: 0.1)
            cell.reasonLabel?.textColor =  UIColor(white: 1.0, alpha: 0.1)
            let strikethroughLine = UIView(frame: CGRect(x: 20.0, y: cell.frame.height/2 - 1, width: cell.frame.width - 40, height: 2))
            strikethroughLine.backgroundColor = UIColor(white: 1.0, alpha: 0.1)
            strikethroughLine.tag = 44
            cell.addSubview(strikethroughLine)
        }
		
        cell.updateConstraints()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let task = self.tasks[indexPath.row] as! NSManagedObject
        let archived = task.value(forKey: Constants.CoreData.ARCHIVED) as! Bool? ?? false
        if !archived && !self.cameFromArchive {
            return true
        }
        return false
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let deleteAction = UITableViewRowAction(style: .default, title: "Complete") {_,_ in 
            let task = self.tasks[indexPath.row] as! NSManagedObject
            self.archieveTask(task)
            Tasks.deleteTask(task)
            
            // Refresh table
            self.refresh()
			
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
        taskView.cameFromArchive = self.cameFromArchive
        self.show(taskView as UIViewController, sender: taskView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let emptyView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
		if tasks.count == 0 {
			
			
			let emptyImageView = UIImageView(frame: CGRect(x:0, y:0, width:150, height:150))
			emptyImageView.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.30)
            let emptyImage = Utils.imageResize(UIImage(named: "Fitness")!, sizeChange: CGSize(width: 150, height: 150)).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
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
            self.tableView.backgroundView = emptyView
			return tasks.count
		}
    }
}


class TasksTableViewCell : UITableViewCell {
    @IBOutlet var reasonLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
    
    override func prepareForReuse() {
        for view in self.subviews {
            if reasonLabel?.textColor != UIColor.white {
                reasonLabel?.textColor = UIColor.white
            }
            if view.tag == 44 {
                view.removeFromSuperview()
            }
        }
    }
}
