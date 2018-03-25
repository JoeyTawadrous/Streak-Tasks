import Foundation

class Constants {
	
	struct Views {
		static let TASKS = "Tasks"
		static let TASK = "Task"
		static let ADD_TASK = "AddTask"
		static let SETTINGS = "Settings"
		static let PURCHASES = "Purchases"
	}
	
	struct Common {
		static let APP_ID = "id1195440882"
		static let APPNAME = "Tasky"
		static let APP_STORE_LINK = "http://apple.co/2krwSkQ"
		static let LEARNABLE_STORE_LINK = "http://apple.co/2vgq8hY"
		static let APP_TWITTER_LINK = "https://twitter.com/getlearnable"
		static let APP_FACEBOOK_LINK = "https://www.facebook.com/getlearnable"
		static let APP_INSTAGRAM_LINK = "https://www.instagram.com/learnableapp"
		static let CELL = "cell"
		static let MAIN_STORYBOARD = "Main"
		static let SUBMIT = "Create"
		static let CLOSE = "Close"
	}
	
	struct CoreData {
		static let TASK = "Task"
		static let GOAL = "Goal"
		static let NAME = "name"
		static let REASON = "reason"
		static let THUMBNAIL = "thumbnail"
		static let TYPE = "type"
		static let WHEN = "when"
		static let UUID = "uuid"
	}
	
	struct Design {
		static let ICON_TROPHY = "trophy"
		static let LOGO = "AppIcon"
	}
	
	struct IAP {
		static let PURCHASED_PRODUCTS = "PurchasedProducts"
		static let TRANSACTION_IN_PROGRESS = "TransactionInProgress"
		static let CURRENT_THEME = "CurrentTheme"
		static let COLORFUL_THEME = "Colorful Theme"
		static let GIRLY_THEME = "Girly Theme"
		static let MANLY_THEME = "Manly Theme"
		static let RAINBOW_THEME = "Rainbow Theme"
		static let ROYAL_THEME = "Royal Theme"
		static let SLIDE_THEME = "Slide Theme"
		static let STYLE_THEME = "Style Theme"
		static let TIDAL_THEME = "Tidal Theme"
		static let WAVE_THEME = "Wave Theme"
	}
    
    struct LocalData {
        static let SELECTED_GOAL = "selectedGoal"
		static let SELECTED_GOAL_INDEX = "selectedGoalIndex"
        static let SELECTED_TASK_INDEX = "selectedTaskIndex"
        static let DATE_FORMAT = "h:mm a, d MMM, yyyy" // e.g. 4:30 PM, 28 March
    }
    
    struct LocalNotifications {
        static let ACTION_CATEGORY_IDENTIFIER = "ActionCategory"
		static let DONE_ACTION_IDENTIFIER = "DoneAction"
		static let DONE_ACTION_TITLE = "Complete"
		static let REMIND_ACTION_IDENTIFIER = "RemindAction"
		static let REMIND_ACTION_TITLE = "Remind in 30 minutes"
	}
	
	struct Strings {
		static let SHARE = "Check out " + Constants.Common.APPNAME + " on the App Store, where you can easily create goals and tasks to achieve those goals! " + Constants.Common.APP_STORE_LINK
		
		// Send Feedback
		static let EMAIL = "joeytawadrous@gmail.com"
		static let SEND_FEEDBACK_SUBJECT = "Tasky Feedback"
		static let SEND_FEEDBACK_BODY = "Hi there! I really like your app.. please keep updating it and I will be sure to rate you :)"
		static let EMAIL_CLOSING = "\n\nThanks again, and have an amazing day!"
	}
}

struct Colors {
	static let ROYAL_THEME_COLOR_1 = "96e6a1"
	static let ROYAL_THEME_COLOR_2 = "d4fc79"
}
