import UIKit
import Social
import MessageUI


class Settings: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {
	
	@IBOutlet var upgradeButtonIcon: UIButton!
	@IBOutlet var changeThemeButtonIcon: UIButton!
	@IBOutlet var learnableiOSAppButtonIcon: UIButton!
	@IBOutlet var reviewButtonIcon: UIButton!
	@IBOutlet var sendFeedbackButtonIcon: UIButton!
	@IBOutlet var shareButtonIcon: UIButton!
	@IBOutlet var twitterButtonIcon: UIButton!
	@IBOutlet var facebookButtonIcon: UIButton!
	@IBOutlet var instagramButtonIcon: UIButton!
	@IBOutlet var backButton: UIBarButtonItem!
	
	
	
	/* MARK: Initialising
	/////////////////////////////////////////// */
	override func viewWillAppear(_ animated: Bool) {
		setButtonIcon(button: upgradeButtonIcon, icon: String.fontAwesomeIcon(name: .trophy))
		setButtonIcon(button: changeThemeButtonIcon, icon: String.fontAwesomeIcon(name: .star))
		setButtonIcon(button: learnableiOSAppButtonIcon, icon: String.fontAwesomeIcon(name: .heart))
		setButtonIcon(button: reviewButtonIcon, icon: String.fontAwesomeIcon(name: .gamepad))
		setButtonIcon(button: sendFeedbackButtonIcon, icon: String.fontAwesomeIcon(name: .pencil))
		setButtonIcon(button: shareButtonIcon, icon: String.fontAwesomeIcon(name: .rocket))
		setButtonIcon(button: twitterButtonIcon, icon: String.fontAwesomeIcon(name: .twitter))
		setButtonIcon(button: facebookButtonIcon, icon: String.fontAwesomeIcon(name: .facebook))
		setButtonIcon(button: instagramButtonIcon, icon: String.fontAwesomeIcon(name: .instagram))
		
		// Styling
		Utils.insertGradientIntoTableView(viewController: self, tableView: tableView)
		tableView.separatorColor = UIColor.clear
		
		// Nav bar
		var attributes = [NSAttributedStringKey : Any]()
		attributes = [.font: UIFont.fontAwesome(ofSize: 21)]
		backButton.setTitleTextAttributes(attributes, for: .normal)
		backButton.setTitleTextAttributes(attributes, for: .selected)
		backButton.title = String.fontAwesomeIcon(name: .arrowLeft)
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	func setButtonIcon(button: UIButton, icon: String) {
		button.titleLabel?.font = UIFont.fontAwesome(ofSize: 22)
		button.setTitle(icon, for: .normal)
	}
	
	
	
	/* MARK: Table
	/////////////////////////////////////////// */
	override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
		(view as? UITableViewHeaderFooterView)?.textLabel?.text = (view as? UITableViewHeaderFooterView)?.textLabel?.text?.capitalized
		(view as? UITableViewHeaderFooterView)?.textLabel?.font = UIFont.GothamProMedium(size: 14.5)
		(view as? UITableViewHeaderFooterView)?.textLabel?.textColor = UIColor.white
	}
	
	override func tableView(_ tableView: UITableView, willDisplayFooterView view: UIView, forSection section: Int) {
		if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			(view as? UITableViewHeaderFooterView)?.textLabel?.text = "Version " + version + "\n© 2018 Tasky\n"
		}
		
		(view as? UITableViewHeaderFooterView)?.textLabel?.font = UIFont.GothamProMedium(size: 12.5)
		(view as? UITableViewHeaderFooterView)?.textLabel?.textColor = UIColor.white
		(view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
	}
	
	public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == 2 {
			return 70.0
		}
		return 0
	}
	
	
	
	/* MARK: Button Action
	/////////////////////////////////////////// */
	@IBAction func backButtonPressed() {
		Utils.presentView(self, viewName: Constants.Views.GOALS_NAV_CONTROLLER)
	}
	
	// Premium
	@IBAction func upgradeButtonPressed() {
		Utils.presentView(self, viewName: Constants.Views.THEMES_NAV_CONTROLLER)
	}
	
	@IBAction func changeThemeButtonPressed() {
		Utils.presentView(self, viewName: Constants.Views.THEMES_NAV_CONTROLLER)
	}
	
	
	// App
	@IBAction func learnableiOSAppButtonPressed() {
		Utils.openURL(url: Constants.Common.LINK_LEARNABLE_IOS_STORE)
	}
	
	@IBAction func reviewButtonPressed() {
		Utils.openURL(url: Constants.Common.LINK_APP_REVIEW)
	}
	
	@IBAction func sendFeedbackButtonPressed() {
		var possibleVersion = "Version "
		if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
			possibleVersion = possibleVersion + version
		}
		let systemVersion = UIDevice.current.systemName + " " + UIDevice.current.systemVersion
		let modelName = UIDevice.modelName
		
		let emailBody = Constants.Strings.SEND_FEEDBACK_BODY + possibleVersion + " \n " + systemVersion + " \n " + modelName
		
		let mailComposer = MFMailComposeViewController()
		mailComposer.mailComposeDelegate = self
		mailComposer.setToRecipients([Constants.Strings.EMAIL])
		mailComposer.setSubject(Constants.Strings.SEND_FEEDBACK_SUBJECT)
		mailComposer.setMessageBody(emailBody, isHTML: false)
		
		if MFMailComposeViewController.canSendMail() {
			present(mailComposer, animated: true)
		}
	}
	
	public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		controller.dismiss(animated: true, completion: nil)
	}
	
	
	// Share
	@IBAction func shareButtonPressed() {
		Utils.openShareView(viewController: self)
	}
	
	@IBAction func twitterButtonPressed() {
		Utils.openURL(url: Constants.Common.LINK_TWITTER)
	}
	
	@IBAction func facebookButtonPressed() {
		Utils.openURL(url: Constants.Common.LINK_FACEBOOK)
	}
	
	@IBAction func instagramButtonPressed() {
		Utils.openURL(url: Constants.Common.LINK_INSTAGRAM)
	}
}
