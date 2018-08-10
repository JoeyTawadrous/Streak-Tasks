import UIKit
import Social
import MessageUI


class Settings: UITableViewController, UITextFieldDelegate {
	@IBOutlet weak var learnableiOSAppButtonIcon: UIButton!
	@IBOutlet weak var reviewButtonIcon: UIButton!
	@IBOutlet weak var sendFeedbackButtonIcon: UIButton!
	@IBOutlet weak var shareButtonIcon: UIButton!
	@IBOutlet weak var twitterButtonIcon: UIButton!
	@IBOutlet weak var facebookButtonIcon: UIButton!
	@IBOutlet weak var instagramButtonIcon: UIButton!
	
	
	/* MARK: Initialising
	/////////////////////////////////////////// */
	override func viewWillAppear(_ animated: Bool) {
		setButtonIcon(button: learnableiOSAppButtonIcon, icon: String.fontAwesomeIcon(name: .heart))
		setButtonIcon(button: reviewButtonIcon, icon: String.fontAwesomeIcon(name: .gamepad))
		setButtonIcon(button: sendFeedbackButtonIcon, icon: String.fontAwesomeIcon(name: .pencil))
		setButtonIcon(button: shareButtonIcon, icon: String.fontAwesomeIcon(name: .rocket))
		setButtonIcon(button: twitterButtonIcon, icon: String.fontAwesomeIcon(name: .twitter))
		setButtonIcon(button: facebookButtonIcon, icon: String.fontAwesomeIcon(name: .facebook))
		setButtonIcon(button: instagramButtonIcon, icon: String.fontAwesomeIcon(name: .instagram))
		
		// Styling
		Utils.insertGradientIntoTableView(viewController: self, tableView: tableView)
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
			(view as? UITableViewHeaderFooterView)?.textLabel?.text = "Version " + version + "\n© 2018 Sunrise Alarm\n"
		}
		
		(view as? UITableViewHeaderFooterView)?.textLabel?.font = UIFont.GothamProMedium(size: 12.5)
		(view as? UITableViewHeaderFooterView)?.textLabel?.textColor = UIColor.white
		(view as? UITableViewHeaderFooterView)?.textLabel?.textAlignment = .center
	}
	
	public override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
		if section == 1 {
			return 70.0
		}
		return 0
	}
	
	
	
	/* MARK: Button Action
	/////////////////////////////////////////// */
	// APP
	@IBAction func learnableiOSAppButtonPressed() {
		Utils.openURL(url: Constants.Common.LINK_LEARNABLE_IOS_STORE)
	}
	
	@IBAction func reviewButtonPressed() {
		Utils.openURL(url: Constants.Common.LINK_IOS_STORE)
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
		mailComposer.mailComposeDelegate = view as? MFMailComposeViewControllerDelegate
		mailComposer.setToRecipients([Constants.Strings.EMAIL])
		mailComposer.setSubject(Constants.Strings.SEND_FEEDBACK_SUBJECT)
		mailComposer.setMessageBody(emailBody, isHTML: false)
		
		if MFMailComposeViewController.canSendMail() {
			self.present(mailComposer, animated: true, completion: nil)
		}
	}
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Swift.Error?){
		controller.dismiss(animated: true) { () -> Void in }
	}
	
	
	// SHARE
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
