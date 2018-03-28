import UIKit
import Social
import MessageUI


class Settings: UITableViewController, UITextFieldDelegate {
	
	
	/* MARK: Initialising
	/////////////////////////////////////////// */
	override func viewWillAppear(_ animated: Bool) {
		// Styling
		Utils.insertGradientIntoTableView(viewController: self, tableView: tableView)
		tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		tableView.tableHeaderView?.tintColor = UIColor.white
	}
	
	override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
		let label = UILabel()
		label.backgroundColor = UIColor.clear
		label.textColor = UIColor.white
		label.font = UIFont.GothamProBold(size: 15)
		
		if section == 0 {
			label.text = "   APP"
		}
		else {
			label.text = "   SHARE"
		}
		
		return label
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Button Action
	/////////////////////////////////////////// */
	// APP
	@IBAction func learnToCodeButtonPressed() {
		Utils.openURL(url: Constants.Common.LEARNABLE_STORE_LINK)
	}
	
	@IBAction func reviewButtonPressed(sender: UIButton) {
		Utils.openURL(url: Constants.Common.APP_STORE_LINK)
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
