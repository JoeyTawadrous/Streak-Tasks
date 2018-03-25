import UIKit
import CoreData

class Tasks: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct ClassConstants {
        static let REASON = "Desctiption: "
	}
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var addButton: UIBarButtonItem!
	
    var catchUps = [AnyObject]()
    var selectedPerson = String()
	
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		Utils.insertGradientIntoView(viewController: self)
		Utils.insertGradientIntoTableView(viewController: self, tableView: tableView)
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)

		// init
		tableView.delegate = self
		tableView.dataSource = self
		refresh();
		
		// Styling
		tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		
		// Nav bar
		var attributes = [NSAttributedStringKey : Any]()
		attributes = [.font: UIFont.fontAwesome(ofSize: 21)]
		addButton.setTitleTextAttributes(attributes, for: .normal)
		addButton.setTitleTextAttributes(attributes, for: .selected)
		addButton.title = String.fontAwesomeIcon(name: .plus)
		
		// Observer for every notification received
		NotificationCenter.default.addObserver(self, selector: #selector(Tasks.backgoundNofification(_:)), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil);
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	@objc func backgoundNofification(_ noftification:Notification){
		refresh()
    }
    
	func refresh() {
		selectedPerson = UserDefaults.standard.string(forKey: Constants.LocalData.SELECTED_PERSON)!
		self.title = selectedPerson
		
		catchUps = Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: selectedPerson)
		catchUps = catchUps.reversed() // newest first
		
		view.backgroundColor = Utils.getMainColor()
		
		self.tableView.backgroundColor = Utils.getNextTableColour(catchUps.count, reverse: false)
		self.tableView.reloadData()
	}
	
	
	/* MARK: Core Functionality
	/////////////////////////////////////////// */
    class func deleteCatchUp(_ catchUp: NSManagedObject) {
        let catchUpUUID = catchUp.value(forKey: Constants.CoreData.UUID) as! String
        
        
        // Remove notification for catchUp object & update app icon badge notification count
        for notification in UIApplication.shared.scheduledLocalNotifications!{
            let notificationUUID = notification.userInfo!["UUID"] as! String
            
            if (notificationUUID == catchUpUUID) {
                UIApplication.shared.cancelLocalNotification(notification)
                break
            }
        }
        Tasks.setBadgeNumbers()
        
        
        // Remove catchUp object
        let managedObjectContect = Utils.fetchManagedObjectContext()
        managedObjectContect.delete(catchUp)
        do {
            try managedObjectContect.save()
        }
		catch {
            print(error)
        }
    }
    
    class func setBadgeNumbers() {
        let notifications = UIApplication.shared.scheduledLocalNotifications // all scheduled notifications
        let catchUps = Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: "")
        
        UIApplication.shared.cancelAllLocalNotifications()
        
        // for every notification
        for notification in notifications! {
            
            for catchUp in catchUps {
                
                let catchUpUUID = catchUp.value(forKey: Constants.CoreData.UUID) as! String
                let notificationUUID = notification.userInfo!["UUID"] as! String
				
                if (notificationUUID == catchUpUUID) {
                    let overdueCatchUps = catchUps.filter({ (catchUp) -> Bool in
                        let when = catchUp.value(forKey: Constants.CoreData.WHEN) as! Date
                        let dateComparisionResult: ComparisonResult = notification.fireDate!.compare(when)
                        
                        return dateComparisionResult == ComparisonResult.orderedAscending
                    })
                    
                    notification.applicationIconBadgeNumber = overdueCatchUps.count   // set new badge number
                    UIApplication.shared.scheduleLocalNotification(notification)      // reschedule notification
                }
            }
        }
    }

	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
    internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: CatchUpsTableViewCell! = tableView.dequeueReusableCell(withIdentifier: Constants.Common.CELL) as? CatchUpsTableViewCell
        if cell == nil {
            cell = CatchUpsTableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Constants.Common.CELL)
        }
        let catchUp = catchUps[indexPath.row]
		let type = catchUp.value(forKey: Constants.CoreData.TYPE) as! String?
		
		
		// Style
		cell!.selectionStyle = .none
		
        cell.reasonLabel!.text = catchUp.value(forKey: Constants.CoreData.REASON) as! String?
		cell.thumbnailImageView!.image = UIImage(named: type!)
        cell.thumbnailImageView!.image = cell.thumbnailImageView!.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.thumbnailImageView!.tintColor = UIColor.white
		
        cell.updateConstraints()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {

    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
		let deleteAction = UITableViewRowAction(style: .default, title: "Complete") {_,_ in 
            let catchUp = self.catchUps[indexPath.row] as! NSManagedObject
            Tasks.deleteCatchUp(catchUp)
			
            // Refresh table
            self.catchUps = Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: self.selectedPerson)
            self.catchUps = self.catchUps.reversed() // newest first
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.backgroundColor = Utils.getNextTableColour(self.catchUps.count, reverse: false)
            tableView.reloadData()
        }
        
        return [deleteAction]
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        
        // Set catchup in NSUserDefaults (so we can get catchup details it later)
        let defaults = UserDefaults.standard
        defaults.set(NSInteger(indexPath.row), forKey: Constants.LocalData.SELECTED_CATCHUP_INDEX)
        
        
        // Show CatchUp view
        let storyBoard : UIStoryboard = UIStoryboard(name: Constants.Common.MAIN_STORYBOARD, bundle:nil)
        let catchUpView = storyBoard.instantiateViewController(withIdentifier: Constants.Classes.CATCH_UP) as! Tasks
        self.show(catchUpView as UIViewController, sender: catchUpView)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if catchUps.count == 0 {
			let emptyView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
			
			let emptyImageView = UIImageView(frame: CGRect(x:0, y:0, width:150, height:150))
			emptyImageView.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.30)
			let emptyImage = Utils.imageResize(UIImage(named: "Efficiency")!, sizeChange: CGSize(width: 150, height: 150)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			emptyImageView.image = emptyImage
			emptyImageView.tintColor = UIColor.white
			emptyView.addSubview(emptyImageView)
			
			let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width - 100, height:self.view.bounds.size.height))
			emptyLabel.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.53)
			emptyLabel.text = "Now that you have created a goal, what will it take to achieve it? Well, don't tell me, create a task now!"
			emptyLabel.font = UIFont.GothamProRegular(size: 15.0)
			emptyLabel.textAlignment = NSTextAlignment.center
			emptyLabel.textColor = UIColor.white
			emptyLabel.numberOfLines = 4
			emptyView.addSubview(emptyLabel)
			
			self.tableView.backgroundView = emptyView
			
			return 0
		}
		else {
			return catchUps.count
		}
    }
}

class CatchUpsTableViewCell : UITableViewCell {
    @IBOutlet var reasonLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
}
