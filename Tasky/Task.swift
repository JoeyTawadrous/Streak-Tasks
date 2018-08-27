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
    
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
    override func viewWillAppear(_ animated: Bool) {
		let defaults = UserDefaults.standard
        var goals = Utils.fetchCoreDataObject(Constants.CoreData.GOAL, predicate: "")
        goals = goals.reversed()
		
        let selectedGoal = defaults.string(forKey: Constants.LocalData.SELECTED_GOAL)!
        let selectedGoalIndex = defaults.integer(forKey: Constants.LocalData.SELECTED_GOAL_INDEX)
        let selectedTaskIndex = defaults.integer(forKey: Constants.LocalData.SELECTED_TASK_INDEX)
        var tasks = Utils.fetchCoreDataObject(Constants.CoreData.TASK, predicate: selectedGoal)
        tasks = tasks.reversed()
		
		// Styling
		Utils.insertGradientIntoView(viewController: self)
        
        // Reason label
		reasonLabel?.text = "\"" + (tasks[selectedTaskIndex].value(forKey: Constants.CoreData.REASON) as! String?)! + "\""
		
        // Goal thumbnail
        let thumbnailFile = goals[selectedGoalIndex].value(forKey: Constants.CoreData.THUMBNAIL) as! String?
        goalImageView!.image = UIImage(named: thumbnailFile!)
        goalImageView!.image! = Utils.imageResize(goalImageView!.image!, sizeChange: CGSize(width: 45, height: 45)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
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
        taskImageView!.image! = Utils.imageResize(taskImageView!.image!, sizeChange: CGSize(width: 40, height: 40)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        taskImageView!.tintColor = UIColor.white
		
        // Title bar button
        titleButton?.title = Utils.getDayOfWeek(formattedWhen)! + ", " + whenArray[1] + " @ " + whenArray[0]
		
        // Complete button
        markDoneButton!.layer.cornerRadius = 3
        markDoneButton!.setTitleColor(Utils.getMainColor(), for: UIControlState())
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Button Actions
	/////////////////////////////////////////// */
    @IBAction func markDoneButtonTapped(_ sender : UIButton!) {
        sender.isEnabled = false
		
        let defaults = UserDefaults.standard
        let selectedGoal = defaults.string(forKey: Constants.LocalData.SELECTED_GOAL)!
        let selectedTaskIndex = defaults.integer(forKey: Constants.LocalData.SELECTED_TASK_INDEX)
        var tasks = Utils.fetchCoreDataObject(Constants.CoreData.TASK, predicate: selectedGoal)
        let task = tasks[selectedTaskIndex] as! NSManagedObject
        Tasks.deleteTask(task)
		
        navigationController?.popViewController(animated: true)
    }
}
