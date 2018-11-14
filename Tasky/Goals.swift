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
	@IBOutlet var achievementsButton: UIBarButtonItem!
	@IBOutlet var menuButton: UIBarButtonItem!
	
    var goals = [AnyObject]()
	
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewWillAppear(_ animated: Bool) {
		goals = CoreData.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
		goals = goals.reversed() // newest first
		
		// Demo data
//		if goals.count == 0 {
//			goals = Utils.createDemoData()
//		}
		
		tableView.reloadData()
		
		// Styling
		Utils.insertGradientIntoView(viewController: self)
		Utils.createFontAwesomeBarButton(button: addButton, icon: .plus, style: .solid)
		Utils.createFontAwesomeBarButton(button: achievementsButton, icon: .gem, style: .solid)
		Utils.createFontAwesomeBarButton(button: menuButton, icon: .bars, style: .solid)
		tableView.separatorStyle = UITableViewCellSeparatorStyle.none
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
		let alertViewIcon = UIImage(named: "trophy")
		let textField = alertView.addTextField(ClassConstants.ADD_GOAL_NAME)
		
		alertView.addButton(Constants.Strings.ALERT_DIALOG_SUBMIT) {
			if !textField.text!.isEmpty {
				self.goals.insert(CoreData.createGoal(name: textField.text!), at: 0)
				self.tableView.reloadData()
				
				
				// Achievements
				var totalGoals = Utils.double(key: Constants.Defaults.APP_DATA_TOTAL_GOALS_CREATED)
				totalGoals = totalGoals + 1
				Utils.set(key: Constants.Defaults.APP_DATA_TOTAL_GOALS_CREATED, value: totalGoals)
				
				var totalPoints = Utils.double(key: Constants.Defaults.APP_DATA_TOTAL_POINTS)
				totalPoints = totalPoints + 3
				Utils.set(key: Constants.Defaults.APP_DATA_TOTAL_POINTS, value: totalPoints)
				
				// Has the user reached an achievement?
				ProgressManager.checkAndSetAchievementReached(view: self, type: Constants.Achievements.POINTS_TYPE)
				ProgressManager.checkAndSetAchievementReached(view: self, type: Constants.Achievements.GOALS_TYPE)
				
				let points = Utils.int(key: Constants.Defaults.APP_DATA_TOTAL_POINTS)
				if(ProgressManager.shouldLevelUp(points: (points - 3))) {
					Dialogs.showLevelUpDialog(view: self, level: ProgressManager.getLevel(points: (points - 3)))
				}
			}
		}
		alertView.addButton(Constants.Strings.ALERT_DIALOG_CLOSE) {}
		
		alertView.showCustom(ClassConstants.ADD_GOAL_TITLE, subTitle: ClassConstants.ADD_GOAL_MESSAGE, color: Utils.getMainColor(), icon: alertViewIcon!, animationStyle: .leftToRight)
	}
	
	@IBAction func achievementsButtonPressed(_ sender: AnyObject) {
		Utils.presentView(self, viewName: Constants.Views.ACHIEVEMENTS)
	}
	
	@IBAction func menuButtonPressed(_ sender: AnyObject) {
		Utils.presentView(self, viewName: Constants.Views.SETTINGS_NAV_CONTROLLER)
	}
	
	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: GoalTableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell") as? GoalTableViewCell
        if cell == nil {
            cell = GoalTableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: "cell")
        }
        let goal = goals[indexPath.row]
		
		// Style
		cell!.selectionStyle = .none
		
        let name = goal.value(forKey: Constants.CoreData.NAME) as! String?
        cell.nameLabel!.text = name
        
        let tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: name!)
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
            let tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: "")
            let goal = goals[indexPath.row]
            let selectedGoal = goal.value(forKey: Constants.CoreData.NAME) as! String?
            
            for task in tasks {
                if (selectedGoal == task.name) {
                    Tasks.deleteTask(task as! NSManagedObject)
                }
            }
			
            // Delete goal
            let goalToDelete = goals[indexPath.row]
            
            let managedObjectContect = CoreData.fetchManagedObjectContext()
            managedObjectContect.delete(goalToDelete as! NSManagedObject)
            
            do {
                try managedObjectContect.save()
            } catch {
                print(error)
            }
            
            goals = CoreData.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
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
        
        // Set goal name in defaults (so we can attach tasks to it later)
		Utils.set(key: Constants.LocalData.SELECTED_GOAL, value: selectedGoal!)
		Utils.set(key: Constants.LocalData.SELECTED_GOAL_INDEX, value: indexPath.row)
        
        // Show tasks view
        let storyBoard : UIStoryboard = UIStoryboard(name: "Main", bundle:nil)
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
