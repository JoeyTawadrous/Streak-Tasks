import UIKit
import CoreData
import SwiftForms


class AddTask: FormViewController {
    
    struct FormPlaceholders {
        static let REASON_WHEN_NIL = "I will achieve"
    }

    struct FormTitles {
		static let FORM_TITLE = "Add Task"
		static let TYPE_TITLE = "Type"
        static let WHEN_TITLE = "When"
		static let REASON_TITLE = "Description"
    }
	
    struct FormTypes {
        static let DATE = "date"
        static let REASON = "reason"
        static let TYPE = "type"
    }
    
    struct TypeOptions {
        static let TYPE1 = "Health"
        static let TYPE2 = "Fitness"
        static let TYPE3 = "Home"
        static let TYPE4 = "Hobbies"
        static let TYPE5 = "Financial"
		static let TYPE6 = "Efficiency"
		static let TYPE7 = "Future"
		static let TYPE8 = "Social"
        static let TYPE9 = "Custom"
	}
	
	@IBOutlet var cancelButton: UIBarButtonItem!
	@IBOutlet var checkButton: UIBarButtonItem!
	
    var type: FormRowDescriptor!
    var date: FormRowDescriptor!
    var reason: FormRowDescriptor!
    var selectedGoal = String()
    
    
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewWillAppear(_ animated: Bool) {
		selectedGoal = Utils.string(key: Constants.LocalData.SELECTED_GOAL)
		CoreData.fetchCoreDataObject(Constants.CoreData.TASK, predicate: selectedGoal)
		
		// Styling
		Utils.insertGradientIntoTableView(viewController: self, tableView: self.tableView)
		Utils.createFontAwesomeBarButton(button: cancelButton, icon: .times, style: .solid)
		Utils.createFontAwesomeBarButton(button: checkButton, icon: .check, style: .solid)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
		
        // Disable scroll
        tableView.alwaysBounceVertical = false;
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadForm()
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Button Actions
	/////////////////////////////////////////// */
	@IBAction func cancel(_ sender: AnyObject) {
		self.dismiss(animated: true, completion: nil)
	}
	
	@IBAction func add(_ sender: AnyObject) {
		let typeValue = type.value
		var whenValue = date.value as! Date?
		var reasonValue = reason.value
		let uuid = UUID().uuidString

		// Make sure no nil values
		let today = Date()
		let tomorrow = (Calendar.current as NSCalendar).date(
			byAdding: .day,
			value: 1,
			to: today,
			options: NSCalendar.Options(rawValue: 0))
		if whenValue == nil { whenValue = tomorrow }
		if reasonValue == nil { reasonValue = FormPlaceholders.REASON_WHEN_NIL as NSObject? }
		
		CoreData.createTask(goalName: selectedGoal, type: typeValue!, when: whenValue!, reason: reasonValue!)
		
		// Create local notification
		let notification = UILocalNotification()
		notification.alertBody = "\(selectedGoal): \(reasonValue as! NSString)" // text that will be displayed in the notification
		notification.alertAction = "Open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
		notification.fireDate = whenValue // NOTE: dates in the past, chosen by the user, will not create a notification
		notification.repeatInterval = NSCalendar.Unit.day
		notification.soundName = UILocalNotificationDefaultSoundName // play default sound
		notification.userInfo = ["UUID": uuid]
		notification.category = Constants.LocalNotifications.ACTION_CATEGORY_IDENTIFIER
		UIApplication.shared.scheduleLocalNotification(notification)
		
		Tasks.setBadgeNumbers()
		
		self.dismiss(animated: true, completion: nil)
	}
	
	
	
	/* MARK: Core Functionality
	/////////////////////////////////////////// */
	func loadForm() {
        let form = FormDescriptor(title: FormTitles.FORM_TITLE)
        let section = FormSectionDescriptor(headerTitle: nil, footerTitle: nil)

        // Type
		type = FormRowDescriptor(tag: FormTypes.TYPE, type: .picker, title: FormTitles.TYPE_TITLE)
		type.configuration.selection.options = [TypeOptions.TYPE1 as AnyObject, TypeOptions.TYPE2 as AnyObject, TypeOptions.TYPE3 as AnyObject, TypeOptions.TYPE4 as AnyObject, TypeOptions.TYPE5 as AnyObject, TypeOptions.TYPE6 as AnyObject, TypeOptions.TYPE7 as AnyObject, TypeOptions.TYPE8 as AnyObject, TypeOptions.TYPE9 as AnyObject]
        type.configuration.selection.optionTitleClosure = { value in
            switch(value) {
				default:
					return String(describing: value)
			}
		}
        type.value = TypeOptions.TYPE1 as AnyObject?
        type.configuration.cell.appearance = ["backgroundColor": UIColor.clear]
        section.rows.append(type)

        // Date and time
		date = FormRowDescriptor(tag: FormTypes.DATE, type: .dateAndTime, title: FormTitles.WHEN_TITLE)
		date.configuration.cell.appearance = ["backgroundColor": UIColor.clear]
        section.rows.append(date)

        // Reason
		reason = FormRowDescriptor(tag: FormTypes.REASON, type: .text, title: FormTitles.REASON_TITLE)
		reason.configuration.cell.appearance = ["textField.placeholder": FormPlaceholders.REASON_WHEN_NIL as AnyObject, "textField.textColor": UIColor.white, "textField.textAlignment": NSTextAlignment.right.rawValue as AnyObject, "backgroundColor": UIColor.clear]
        section.rows.append(reason)

		form.sections = [section]
		self.form = form
    }
}
