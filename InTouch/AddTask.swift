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
    var selectedPerson = String()
    
    
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		// init
		selectedPerson = UserDefaults.standard.string(forKey: Constants.LocalData.SELECTED_PERSON)!
		Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: selectedPerson)
		
		// Styling
		cancelButton.image = Utils.imageResize(UIImage(named: "cross")!, sizeChange: CGSize(width: 18, height: 18)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
		checkButton.image = Utils.imageResize(UIImage(named: "check")!, sizeChange: CGSize(width: 22, height: 22)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
		
        // Disable scroll
        tableView.alwaysBounceVertical = false;
		
		Utils.insertGradientIntoView(viewController: self)
		Utils.insertGradientIntoTableView(viewController: self, tableView: tableView)
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
		
		
		let catchUp = Utils.createObject(Constants.CoreData.CATCHUP)
		catchUp.setValue(selectedPerson, forKey: Constants.CoreData.NAME)
		catchUp.setValue(typeValue, forKey: Constants.CoreData.TYPE)
		catchUp.setValue(whenValue, forKey: Constants.CoreData.WHEN)
		catchUp.setValue(reasonValue, forKey: Constants.CoreData.REASON)
		catchUp.setValue(uuid, forKey: Constants.CoreData.UUID);
		Utils.saveObject()
		
		
		// Create local notification
		let notification = UILocalNotification()
		notification.alertBody = "\(selectedPerson): \(reasonValue as! NSString)" // text that will be displayed in the notification
		notification.alertAction = "Open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
		notification.fireDate = whenValue // NOTE: dates in the past, chosen by the user, will not create a notification
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
//		type = FormRowDescriptor(tag: FormTypes.TYPE, type: .picker, title: FormTitles.TYPE_TITLE)
//        type.configuration[FormRowDescriptor.Configuration.Options] = [TypeOptions.TYPE1, TypeOptions.TYPE2, TypeOptions.TYPE3, TypeOptions.TYPE4, TypeOptions.TYPE5, TypeOptions.TYPE6, TypeOptions.TYPE7, TypeOptions.TYPE8, TypeOptions.TYPE9]
//        type.configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] = { value in
//            switch( value ) {
//				default:
//					return String(describing: value)
//                }
//            } as TitleFormatterClosure
//        type.value = TypeOptions.TYPE1 as NSObject?
//        type.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["backgroundColor" : UIColor.clear]
//        section.addRow(type)
//
//
//        // Date and time
//		date = FormRowDescriptor(tag: FormTypes.DATE, type: .dateAndTime, title: FormTitles.WHEN_TITLE)
//        date.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["backgroundColor" : UIColor.clear]
//        section.addRow(date)
//
//
//        // Reason
//		reason = FormRowDescriptor(tag: FormTypes.REASON, type: .text, title: FormTitles.REASON_TITLE)
//        reason.configuration[FormRowDescriptor.Configuration.CellConfiguration] = ["textField.placeholder" : FormPlaceholders.REASON_WHEN_NIL, "textField.textAlignment" : NSTextAlignment.right.rawValue, "backgroundColor" : UIColor.clear]
//        section.addRow(reason)
		
		
        form.sections = [section]
        self.form = form
    }
}
