import UIKit
import Social
import MessageUI


class Settings: UITableViewController, UITextFieldDelegate {
	
	@IBOutlet var tableView: UITableView!
	
	
	
	/* MARK: Initialising
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		Utils.insertGradientIntoView(viewController: self)
		Utils.insertGradientIntoTableView(viewController: self, tableView: self.tableView)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Button Action
	/////////////////////////////////////////// */
	// APP
	@IBAction func themesButtonPressed() {
		Utils.presentView(self, viewName: Constants.Views.PURCHASES)
	}
	
	@IBAction func learnToCodeButtonPressed() {
		Utils.openURL(url: Constants.Common.APP_STORE_LINK)
	}
	
	@IBAction func reviewButtonPressed(sender: UIButton) {
		Utils.openReviewAppURL(appId: Constants.Common.APP_ID) { success in
			// success
		}
	}
	
	@IBAction func sendFeedbackButtonPressed() {
		Utils.openSendMailView(view: self, subject: Constants.Strings.SEND_FEEDBACK_SUBJECT, message: Constants.Strings.SEND_FEEDBACK_BODY + Constants.Strings.EMAIL_CLOSING)
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	
	// SHARE
	@IBAction func shareButtonPressed() {
		Utils.openShareView(viewController: self)
	}
	
	@IBAction func twitterButtonPressed() {
		Utils.openURL(url: Constants.Common.APP_TWITTER_LINK)
	}
	
	@IBAction func facebookButtonPressed() {
		Utils.openURL(url: Constants.Common.APP_FACEBOOK_LINK)
	}
	
	@IBAction func instagramButtonPressed() {
		Utils.openURL(url: Constants.Common.APP_INSTAGRAM_LINK)
	}
}
