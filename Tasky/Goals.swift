import UIKit
import CoreData
import SCLAlertView
import FontAwesome_swift


class Goals: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct ClassConstants {
        static let ADD_GOAL_TITLE = "Add A New Goal"
        static let ADD_GOAL_MESSAGE = "that you will achieve...";
        static let ADD_GOAL_NAME = "Enter Goal Name";
	}
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var addButton: UIBarButtonItem!
	@IBOutlet var menuButton: UIBarButtonItem!
	
    var goals = [AnyObject]()
	
	
	
	/* MARK: Init
	/////////////////////////////////////////// */	
    override func viewWillAppear(_ animated: Bool) {
		goals = Utils.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
		goals = goals.reversed() // newest first
		tableView.reloadData()
		
		// Styling
		Utils.insertGradientIntoView(viewController: self)
		tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		
		// Nav bar
		var attributes = [NSAttributedStringKey : Any]()
		attributes = [.font: UIFont.fontAwesome(ofSize: 21)]
		addButton.setTitleTextAttributes(attributes, for: .normal)
		addButton.setTitleTextAttributes(attributes, for: .selected)
		addButton.title = String.fontAwesomeIcon(name: .plus)
		menuButton.setTitleTextAttributes(attributes, for: .normal)
		menuButton.setTitleTextAttributes(attributes, for: .selected)
		menuButton.title = String.fontAwesomeIcon(name: .bars)
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
    
	/* MARK: Button Actions
	/////////////////////////////////////////// */
    @IBAction func addGoal(_ sender: AnyObject) {
		let appearance = SCLAlertView.SCLAppearance(
			kCircleHeight: 100.0,
			kCircleIconHeight: 60.0,
			kTitleTop: 62.0,
			showCloseButton: false
		)
		
		let alertView = SCLAlertView(appearance: appearance)
		let alertViewIcon = UIImage(named: Constants.Design.ICON_TROPHY)
		let textField = alertView.addTextField(ClassConstants.ADD_GOAL_NAME)
		
		alertView.addButton(Constants.Common.SUBMIT) {
			if !textField.text!.isEmpty {
				self.saveGoal(textField.text!, thumbnail: Utils.getRandomImageString())
				self.tableView.reloadData()
			}
		}
		alertView.addButton(Constants.Common.CLOSE) {}
		
		alertView.showCustom(ClassConstants.ADD_GOAL_TITLE, subTitle: ClassConstants.ADD_GOAL_MESSAGE, color: Utils.getMainColor(), icon: alertViewIcon!, animationStyle: .leftToRight)
	}
	
	@IBAction func menuButtonPressed(_ sender: AnyObject) {
		let storyBoard : UIStoryboard = UIStoryboard(name: Constants.Common.MAIN_STORYBOARD, bundle:nil)
		let settingsView = storyBoard.instantiateViewController(withIdentifier: Constants.Views.SETTINGS) as! Settings
		self.show(settingsView as UIViewController, sender: settingsView)
	}
	
	
	
	/* MARK: Core Functionality
	/////////////////////////////////////////// */
	func saveGoal(_ name: String, thumbnail: String) {
		let goal = Utils.createObject(Constants.CoreData.GOAL)
		
		goal.setValue(name, forKey: Constants.CoreData.NAME)
		goal.setValue(thumbnail, forKey: Constants.CoreData.THUMBNAIL)
		Utils.saveObject()
		
		goals.insert(goal, at: 0)
	}
	
	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: GoalTableViewCell! = tableView.dequeueReusableCell(withIdentifier: Constants.Common.CELL) as? GoalTableViewCell
        if cell == nil {
            cell = GoalTableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: Constants.Common.CELL)
        }
        let goal = goals[indexPath.row]
		
		// Style
		cell!.selectionStyle = .none
		
        let name = goal.value(forKey: Constants.CoreData.NAME) as! String?
        cell.nameLabel!.text = name
        
        let tasks = Utils.fetchCoreDataObject(Constants.CoreData.TASK, predicate: name!)
        cell.taskCountLabel!.text = String(tasks.count)
        
        let thumbnail = goal.value(forKey: Constants.CoreData.THUMBNAIL) as! String?
        cell.thumbnailImageView!.image = UIImage(named: thumbnail!)
        cell.thumbnailImageView!.image = cell.thumbnailImageView!.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.thumbnailImageView!.tintColor = UIColor.white
		
        cell.updateConstraints()

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete) {
            
            // Delete tasks associated with this goal
            let tasks = Utils.fetchCoreDataObject(Constants.CoreData.TASK, predicate: "")
            let goal = goals[indexPath.row]
            let selectedGoal = goal.value(forKey: Constants.CoreData.NAME) as! String?
            
            for task in tasks {
                if (selectedGoal == task.name) {
                    Tasks.deleteTask(task as! NSManagedObject)
                }
            }
			
            // Delete goal
            let goalToDelete = goals[indexPath.row]
            
            let managedObjectContect = Utils.fetchManagedObjectContext()
            managedObjectContect.delete(goalToDelete as! NSManagedObject)
            
            do {
                try managedObjectContect.save()
            } catch {
                print(error)
            }
            
            goals = Utils.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
            goals = goals.reversed() // newest first
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
		
        // Get selected goal name
        let cell = tableView.cellForRow(at: indexPath) as! GoalTableViewCell
        let selectedGoal = cell.nameLabel!.text
        
        // Set goal name in NSUserDefaults (so we can attach tasks to it later)
        let defaults = UserDefaults.standard
        defaults.set(selectedGoal, forKey: Constants.LocalData.SELECTED_GOAL)
        defaults.set(indexPath.row, forKey: Constants.LocalData.SELECTED_GOAL_INDEX)
        
        // Show tasks view
        let storyBoard : UIStoryboard = UIStoryboard(name: Constants.Common.MAIN_STORYBOARD, bundle:nil)
        let tasksView = storyBoard.instantiateViewController(withIdentifier: Constants.Views.TASKS) as! Tasks
        self.show(tasksView as UIViewController, sender: tasksView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if goals.count == 0 {
			let emptyView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
			
			let emptyImageView = UIImageView(frame: CGRect(x:0, y:0, width:150, height:150))
			emptyImageView.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.30)
			let emptyImage = Utils.imageResize(UIImage(named: "Hobbies")!, sizeChange: CGSize(width: 150, height: 150)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			emptyImageView.image = emptyImage
			emptyImageView.tintColor = UIColor.white
			emptyView.addSubview(emptyImageView)
			
			let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width - 100, height:self.view.bounds.size.height))
			emptyLabel.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.53)
			emptyLabel.text = "Do you like cooking? Perhaps you're more fitness oriented? Or maybe you'd like more family time? Create a goal now!"
			emptyLabel.font = UIFont.GothamProRegular(size: 15.0)
			emptyLabel.textAlignment = NSTextAlignment.center
			emptyLabel.textColor = UIColor.white
			emptyLabel.numberOfLines = 5
			emptyView.addSubview(emptyLabel)
			
			self.tableView.backgroundView = emptyView
			
			return 0
		}
		else {
			return goals.count
		}
    }
}


class GoalTableViewCell : UITableViewCell {
    @IBOutlet var nameLabel: UILabel?
    @IBOutlet var taskCountLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
}
