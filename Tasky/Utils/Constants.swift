import Foundation

class Constants {
	
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
	
	
	struct Purchases {
		static let SHARED_SECRET = "7e01d48a5e7646dd82282cf26a97af2c"
		static let SUBSCRIPTION_KEY = "com.joeyt.learnable.subscription"
		static let UNLOCK_KEY = "com.joeyt.learnable.unlock"
		
		static let PURCHASED_PRODUCTS = "PurchasedProducts"
		static let CURRENT_THEME = "CurrentTheme"
		static let PRODUCT_ID_PREFIX = "com.joeyt.tasky.iap.theme."
		
		static let GRASSY_THEME = "grassy"
		static let SUNRISE_THEME = "sunrise"
		static let NIGHTLIGHT_THEME = "nightlight"
		static let SALVATION_THEME = "salvation"
		static let RIPE_THEME = "ripe"
		static let MALIBU_THEME = "malibu"
		static let LIFE_THEME = "life"
		static let FIRE_THEME = "fire"
		
		static let Colors: [String : [String]] = [
			GRASSY_THEME: ["67c200", "9fe558"],
			SUNRISE_THEME: ["f6d365", "fda085"],
			NIGHTLIGHT_THEME: ["a18cd1", "fbc2eb"],
			SALVATION_THEME: ["f43b47", "453a94"],
			RIPE_THEME: ["f093fb", "f5576c"],
			MALIBU_THEME: ["4facfe", "00f2fe"],
			LIFE_THEME: ["43e97b", "38f9d7"],
			FIRE_THEME: ["fa709a", "fee140"]
		]
	}
	
	
	struct Strings {
		static let SHARE = "Check out " + Constants.Common.APPNAME + " on the App Store, where you can easily create goals and tasks to achieve those goals! " + Constants.Common.APP_STORE_LINK
		
		// Purchases
		static let PURCHASE_ERROR_CONTACT_US = " Please contact us."
		static let PURCHASE_ERROR_NOT_AVAILABLE = "The product is not available in the current storefront." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_IDENTIFIER_INVALID = "The purchase identifier was invalid." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_CANCELLED = "Your payment was cancelled." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_NOT_ALLOWED = "You are not allowed to make payments." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_UNKNOWN = "Unknown error." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_RESTORE_ERROR = "Restore error." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_RESTORE_NOTHING = "You have no purchases to restore!"
		static let PURCHASE_RESTORE_SUCCESS = "You have restored your previous purchase and now have access to the entire app!"
		
		// Send Feedback
		static let EMAIL = "joeytawadrous@gmail.com"
		static let SEND_FEEDBACK_SUBJECT = "Tasky Feedback"
		static let SEND_FEEDBACK_BODY = "Hi there! I really like your app.. please keep updating it and I will be sure to rate you :)"
		static let EMAIL_CLOSING = "\n\nThanks again, and have an amazing day!"
	}
	
	
	struct Views {
		static let TASKS = "Tasks"
		static let TASK = "Task"
		static let ADD_TASK = "AddTask"
		static let SETTINGS = "Settings"
		static let THEMES = "Themes"
	}
}
