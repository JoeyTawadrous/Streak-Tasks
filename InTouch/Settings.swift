import UIKit
import Social
import MessageUI

class Settings: UITableViewController, UITextFieldDelegate, MFMailComposeViewControllerDelegate {

	
	/* MARK: Initialising
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		self.navigationController?.navigationBar.backgroundColor = Utils.getMainColor()
	}
	

	
	/* MARK: Button Action
	/////////////////////////////////////////// */
	@IBAction func shareToFacebookButtonPressed(_ sender: UIButton) {
		Utils.post(toService: SLServiceTypeFacebook, view: self)
	}
	
	@IBAction func shareToTwitterButtonPressed(_ sender: UIButton) {
		Utils.post(toService: SLServiceTypeTwitter, view: self)
	}
	
	@IBAction func shareButtonPressed(_ sender: UIButton) {
		Utils.share(sender: sender, viewController: self)
	}
	
	@IBAction func sendFeedbackButtonPressed(_ sender: UIButton) {
		let mailComposer = MFMailComposeViewController()
		mailComposer.mailComposeDelegate = self
		mailComposer.setToRecipients(["joeytawadrous@gmail.com"])
		mailComposer.setSubject(Constants.Common.APPNAME + " feedback.")
		mailComposer.setMessageBody("I love the app! Keep up the great work!", isHTML: false)
		
		if MFMailComposeViewController.canSendMail() {
			self.present(mailComposer, animated: true, completion: nil)
		} else {
			Utils.presentOkButtonAlert(self, message: "Your device could not send e-mail.  Please check e-mail configuration and try again.")
		}
	}
	
	
	func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
		// Dismiss the mail compose view controller.
		controller.dismiss(animated: true, completion: nil)
	}
}
