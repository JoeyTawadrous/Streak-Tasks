import Foundation


class Constants {
	
	struct Colors {
		static let BLUE = "69CDFC"
		static let GREEN = "2ecc71"
		static let PURPLE = "B0B1F1"
		static let PRIMARY_TEXT_GRAY = "5D5D5C"
	}
	
	
	struct Core {
		static let APP_ID = "1195440882"
		static let APP_NAME = "Tasky"
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
	
	
	struct Defaults {
		static let CURRENT_THEME = "CurrentTheme"
		static let PURCHASED_THEMES = "PurchasedThemes"
		static let USER_HAS_MONTHLY_SUBSCRIPTION = "userHasMonthlySubscription"
		static let USER_HAS_YEARLY_SUBSCRIPTION = "userHasYearlySubscription"
		static let USER_HAS_UNLOCKED_APP = "userHasUnlockedApp"
	}
	
	
	struct Design {
		static let LOGO = "Logo"
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
		// Upgrade
		static let SHARED_SECRET = "5e1830a7afcd4f49afb516046e071828"
		static let SUBSCRIPTION_MONTHLY_KEY = "com.joeyt.tasky.subscription.monthly"
		static let SUBSCRIPTION_YEARLY_KEY = "com.joeyt.tasky.subscription.yearly"
		static let UNLOCK_KEY = "com.joeyt.tasky.unlock"
		
		// Themes
		static let THEME_ID_PREFIX = "com.joeyt.tasky.iap.theme."
		static let GRASSY_THEME = "grassy"
		static let SUNRISE_THEME = "sunrise"
		static let NIGHTLIGHT_THEME = "nightlight"
		static let SALVATION_THEME = "salvation"
		static let RIPE_THEME = "ripe"
		static let MALIBU_THEME = "malibu"
		static let LIFE_THEME = "life"
		static let FIRE_THEME = "fire"
		
		static let Colors: [String : [String]] = [
			GRASSY_THEME: ["96e6a1", "d4fc79"],
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
		// Dialog: Alert
		static let ALERT_SUBMIT = "Submit"
		static let ALERT_CLOSE = "Close"
		
		
		// Links
		static let LINK_APP_REVIEW = "itms-apps://itunes.apple.com/app/apple-store/id" + Core.APP_ID + "?action=write-review"
		static let LINK_FACEBOOK = "https://www.facebook.com/getlearnable"
		static let LINK_INSTAGRAM = "https://www.instagram.com/learnableapp"
		static let LINK_IOS_STORE = "https://itunes.apple.com/gb/app/tasky-your-to-do-list-tracker/id1195440882?mt=8"
		static let LINK_PRIVACY_AND_TERMS = "https://www.getLearnable.com/privacy&terms.php"
		static let LINK_LEARNABLE_IOS_STORE = "https://itunes.apple.com/gb/app/learnable-learn-to-code-from-scratch-level-up/id1254862243?mt=8"
		static let LINK_TWITTER = "https://twitter.com/getlearnable"
		static let LINK_WEB = "http://www.getlearnable.com"
		
		
		// Purchases: Strings
		static let PURCHASE_ERROR_CONTACT_US = " Please contact us."
		static let PURCHASE_ERROR_NOT_AVAILABLE = "The product is not available in the current storefront." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_IDENTIFIER_INVALID = "The purchase identifier was invalid." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_CANCELLED = "Your payment was cancelled." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_NOT_ALLOWED = "You are not allowed to make payments." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_ERROR_UNKNOWN = "Unknown error." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_RESTORE_ERROR = "Restore error." + PURCHASE_ERROR_CONTACT_US
		static let PURCHASE_RESTORE_NOTHING = "You have no purchases to restore!"
		static let PURCHASE_RESTORE_SUCCESS = "You have successfully restored your previous purchases."
		static let PURCHASE_SUCCESS = "Your new theme has been succesfully set. Enjoy :)"
		
		
		// Purchases: Upgrade Strings
		static let UPGRADE_SCREEN_TITLE = "Tasky Premium"
		static let UPGRADE_SCREEN_ONE_TITLE = "Unlock Everything"
		static let UPGRADE_SCREEN_ONE_TEXT = "Gain access to all features, themes & unlockable content."
		static let UPGRADE_SCREEN_TWO_TITLE = "Access Themes"
		static let UPGRADE_SCREEN_TWO_TEXT = "Gain access to our Sunrise, Salvation, Nightlight themes & more."
		static let UPGRADE_SCREEN_THREE_TITLE = "Unlimited Goals"
		static let UPGRADE_SCREEN_THREE_TEXT = "Create unlimited goals & tasks to keep you motivated."
		static let UPGRADE_SCREENS_MONTHLY_SUBSCRIBE_BUTTON_TITLE = "$1.99 \nmonth"
		static let UPGRADE_SCREENS_YEARLY_SUBSCRIBE_BUTTON_TITLE = "$4.99 \nyear"
		static let UPGRADE_SCREENS_UNLOCK_BUTTON_TITLE = "$6.99 \nonce"
		static let UPGRADE_SCREENS_INFO = "You'll be charged $1.99/$4.99 month at confirmation of purchase. Your subscription will renew after 1 month unless turned off 24-hours before the end of the subscription period. You can manage this in your App Store settings. For details, see " + Constants.Strings.LINK_PRIVACY_AND_TERMS
	
		
		// Send Feedback
		static let EMAIL = "joeytawadrous@gmail.com"
		static let SEND_FEEDBACK_SUBJECT = "Tasky Feedback!"
		static let SEND_FEEDBACK_BODY = "I want to make Tasky better. Here are my ideas... \n\n What I like about Tasky: \n 1. \n 2. \n 3. \n\n What I don't like about Tasky: \n 1. \n 2. \n 3. \n\n"
		
		
		// Share
		static let SHARE = "Check out " + Constants.Core.APP_NAME + " on the App Store, where you can easily create goals and tasks to achieve those goals! #Tasky #iOS \n\nDownload for free now: " + Constants.Strings.LINK_IOS_STORE
	}
	
	
	struct Views {
		static let ADD_TASK = "AddTask"
		static let TASK = "Task"
		static let TASKS = "Tasks"
		static let GOALS = "Goals"
		static let GOALS_NAV_CONTROLLER = "GoalsNavController"
		static let SETTINGS = "Settings"
		static let SETTINGS_NAV_CONTROLLER = "SettingsNavController"
		static let THEMES = "Themes"
		static let THEMES_NAV_CONTROLLER = "ThemesNavController"
		static let UPGRADE = "Upgrade"
	}
}
