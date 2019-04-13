import CoreData
import UIKit


class Task: UIViewController {
    
    @IBOutlet var titleButton: UIBarButtonItem?
    @IBOutlet var reasonLabel: UILabel?
    @IBOutlet var goalImageView: UIImageView?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var typeLabel: UILabel?
    @IBOutlet var taskImageView: UIImageView?
    @IBOutlet var markDoneButton: UIButton?
    var cameFromArchive:Bool = false
    
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
    override func viewWillAppear(_ animated: Bool) {
        var goals = CoreData.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
        goals = goals.reversed()
		
        let selectedGoal = Utils.string(key: Constants.LocalData.SELECTED_GOAL)
        let selectedGoalIndex = Utils.int(key: Constants.LocalData.SELECTED_GOAL_INDEX)
        let selectedTaskIndex = Utils.int(key: Constants.LocalData.SELECTED_TASK_INDEX)
        var tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: selectedGoal)
        let archivedTasks = CoreData.fetchCoreDataObject(Constants.CoreData.ARCHIEVE_TASK, predicate: selectedGoal)
        tasks = tasks.reversed()
        tasks.append(contentsOf: archivedTasks)
		
		// Styling
		Utils.insertGradientIntoView(viewController: self)
        
        // Reason label
		reasonLabel?.text = "\"" + (tasks[selectedTaskIndex].value(forKey: Constants.CoreData.REASON) as! String?)! + "\""
		
        // Goal thumbnail
        let thumbnailFile = goals[selectedGoalIndex].value(forKey: Constants.CoreData.THUMBNAIL) as! String?
        goalImageView!.image = UIImage(named: thumbnailFile!)
        goalImageView!.image! = Utils.imageResize(goalImageView!.image!, sizeChange: CGSize(width: 45, height: 45)).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        goalImageView!.tintColor = UIColor.white
		
        // Date label
        let when = tasks[selectedTaskIndex].value(forKey: Constants.CoreData.WHEN) as! Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.LocalData.DATE_FORMAT
        let formattedWhen = dateFormatter.string(from: when!)
        let whenArray = formattedWhen.characters.split{$0 == ","}.map(String.init)
        dateLabel?.text = Utils.getDayOfWeek(formattedWhen)! + ", " + whenArray[1]
		
        // Time label
        timeLabel?.text = whenArray[0]
		
        // Type label
        let type = tasks[selectedTaskIndex].value(forKey: Constants.CoreData.TYPE) as! String?
        typeLabel?.text = type!.uppercased()
		
        // Type thumbnail
		taskImageView!.image = UIImage(named: type!)
        taskImageView!.image! = Utils.imageResize(taskImageView!.image!, sizeChange: CGSize(width: 40, height: 40)).withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        taskImageView!.tintColor = UIColor.white
		
        // Title bar button
        titleButton?.title = Utils.getDayOfWeek(formattedWhen)! + ", " + whenArray[1] + " @ " + whenArray[0]
		
        // Complete button
        markDoneButton!.layer.cornerRadius = 3
        markDoneButton!.setTitleColor(Utils.getMainColor(), for: UIControl.State())
        if cameFromArchive || tasks[selectedTaskIndex].value(forKey: Constants.CoreData.ARCHIVED) as! Bool? ?? false {
            markDoneButton?.isHidden = true
        }
        self.styleBorders()
    }
    
    func styleBorders() {
        
        self.reasonLabel?.layer.borderColor = UIColor.white.cgColor
        self.reasonLabel?.layer.borderWidth = 3
        
        self.goalImageView?.layer.borderColor = UIColor.white.cgColor
        self.goalImageView?.layer.borderWidth = 3
        
        self.dateLabel?.layer.borderColor = UIColor.white.cgColor
        self.dateLabel?.layer.borderWidth = 3
        
        self.timeLabel?.layer.borderColor = UIColor.white.cgColor
        self.timeLabel?.layer.borderWidth = 3
        
        self.typeLabel?.layer.borderColor = UIColor.white.cgColor
        self.typeLabel?.layer.borderWidth = 3
        
        self.taskImageView?.layer.borderColor = UIColor.white.cgColor
        self.taskImageView?.layer.borderWidth = 3
        
        self.markDoneButton?.layer.borderColor = UIColor.white.cgColor
        self.markDoneButton?.layer.borderWidth = 3
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Button Actions
	/////////////////////////////////////////// */
    @IBAction func markDoneButtonTapped(_ sender : UIButton!) {
        sender.isEnabled = false
		
        let selectedGoal = Utils.string(key: Constants.LocalData.SELECTED_GOAL)
        let selectedTaskIndex = Utils.int(key: Constants.LocalData.SELECTED_TASK_INDEX)
        var tasks = CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: selectedGoal)
        tasks = tasks.reversed()
        let task = tasks[selectedTaskIndex] as! NSManagedObject
        self.archieveTask(task)
        Tasks.deleteTask(task)
		
		// Achievements
		Task.updateTasksCompleted(view: self)
		
        navigationController?.popViewController(animated: true)
    }
    
    func archieveTask(_ task: NSManagedObject) {
        let goalName = task.value(forKey: Constants.CoreData.NAME) as! String? ?? ""
        let type = task.value(forKey: Constants.CoreData.TYPE)
        let date = task.value(forKey: Constants.CoreData.WHEN) as! Date? ?? Date()
        let reason = task.value(forKey: Constants.CoreData.REASON)
        
        CoreData.createArchievedTask(goalName: goalName, type: type as AnyObject, when: date, reason: reason as AnyObject)
    }
	
	class func updateTasksCompleted(view: UIViewController) {
		var totalTasksCompleted = Utils.double(key: Constants.Defaults.APP_DATA_TOTAL_TASKS_COMPLETED)
		totalTasksCompleted = totalTasksCompleted + 1
		Utils.set(key: Constants.Defaults.APP_DATA_TOTAL_TASKS_COMPLETED, value: totalTasksCompleted)
		
		var totalPoints = Utils.double(key: Constants.Defaults.APP_DATA_TOTAL_POINTS)
		totalPoints = totalPoints + 2
		Utils.set(key: Constants.Defaults.APP_DATA_TOTAL_POINTS, value: totalPoints)
		
		// Has the user reached an achievement?
		ProgressManager.checkAndSetAchievementReached(view: view, type: Constants.Achievements.POINTS_TYPE)
		ProgressManager.checkAndSetAchievementReached(view: view, type: Constants.Achievements.TASKS_TYPE)
		
		let points = Utils.int(key: Constants.Defaults.APP_DATA_TOTAL_POINTS)
		if(ProgressManager.shouldLevelUp(points: (points - 3))) {
			Dialogs.showLevelUpDialog(view: view, level: ProgressManager.getLevel(points: (points - 3)))
		}
	}
}
