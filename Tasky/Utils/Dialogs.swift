import UIKit
import SCLAlertView


class Dialogs {
	
	class func showAchievementDialog(view: UIViewController, reached: Bool, achievement: [String]) {
		let appearance = SCLAlertView.SCLAppearance(
			kCircleHeight: 120.0,
			kCircleIconHeight: 80.0,
			kTitleTop: 72.0,
			showCloseButton: true
		)
		
		let alertView = SCLAlertView(appearance: appearance)
		let alertViewIcon = UIImage(named: achievement[2])
		
		if reached {
			alertView.addButton(Constants.Strings.ACHIEVEMENT_DIALOG_SHARE_BUTTON) {
				Utils.openShareView(viewController: view)
			}
		}
		
		alertView.showCustom(achievement[3], subTitle: achievement[4], color: UIColor(hex: achievement[1]), icon: alertViewIcon!, animationStyle: .leftToRight)
	}
	
	
	class func showLevelUpDialog(view: UIViewController, level: Int) {
		let appearance = SCLAlertView.SCLAppearance(
			kCircleHeight: 100.0,
			kCircleIconHeight: 60.0,
			kTitleTop: 62.0,
			showCloseButton: false
		)
		
		let alertView = SCLAlertView(appearance: appearance)
		let alertViewIcon = UIImage(named: "diamond-1")
		
		alertView.addButton(Constants.Strings.ACHIEVEMENT_DIALOG_SHARE_BUTTON) {
			Utils.openShareView(viewController: view)
		}
		alertView.addButton(Constants.Strings.ACHIEVEMENT_DIALOG_CLOSE_BUTTON) {}
		
		alertView.showInfo(Constants.Strings.ACHIEVEMENT_DIALOG_TITLE, subTitle: Constants.Strings.LEVEL_UP + String(level + 1) + ". \n", circleIconImage: alertViewIcon)
	}
	
	
	class func showOkButtonDialog(view: UIViewController, message: String) {
		let alert = UIAlertController(title: "Info", message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in }))
		
		view.present(alert, animated: true, completion: nil)
	}
}
