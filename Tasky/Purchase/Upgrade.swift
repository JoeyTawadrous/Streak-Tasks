import paper_onboarding
import SwiftyStoreKit


class Upgrade: UIViewController {
	
	@IBOutlet var onboarding: PaperOnboarding!
	let BUTTON_HEIGHT: CGFloat = 55
	let BUTTON_WIDTH: CGFloat = 90
	let BUTTON_POSITION_FROM_TOP: CGFloat = 140
	
	
	
	/* MARK: Initialising
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		createCloseButton()
		createTitleLabel()
		createMonthlySubcriptionButton()
		createYearlySubcriptionButton()
		createUnlockButton()
		createTermsLabel()
	}
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Interface Elements: Buttons
	/////////////////////////////////////////// */
	func createMonthlySubcriptionButton() {
		let button = createUpgradeButton(title: Constants.Strings.UPGRADE_SCREENS_MONTHLY_SUBSCRIBE_BUTTON_TITLE, x: (view.frame.size.width - BUTTON_WIDTH)/2 - 100, y: view.center.y + BUTTON_POSITION_FROM_TOP)
		button.addTarget(self, action: #selector(subscribeMonthlyButtonPressed), for: .touchUpInside)
		self.view.addSubview(button)
	}
	
	func createYearlySubcriptionButton() {
		let button = createUpgradeButton(title: Constants.Strings.UPGRADE_SCREENS_YEARLY_SUBSCRIBE_BUTTON_TITLE, x: (view.frame.size.width - BUTTON_WIDTH)/2, y: view.center.y + BUTTON_POSITION_FROM_TOP)
		button.addTarget(self, action: #selector(subscribeYearlyButtonPressed), for: .touchUpInside)
		self.view.addSubview(button)
	}
	
	func createUnlockButton() {
		let button = createUpgradeButton(title: Constants.Strings.UPGRADE_SCREENS_UNLOCK_BUTTON_TITLE, x: (view.frame.size.width - BUTTON_WIDTH)/2 + 100, y: view.center.y + BUTTON_POSITION_FROM_TOP)
		button.addTarget(self, action: #selector(unlockButtonPressed), for: .touchUpInside)
		self.view.addSubview(button)
	}
	
	func createUpgradeButton(title: String, x: CGFloat, y: CGFloat) -> UIButton {
		let button: UIButton = UIButton(frame: CGRect(x: x, y: y, width: BUTTON_WIDTH, height: BUTTON_HEIGHT))
		button.backgroundColor = UIColor.white
		button.setTitle(title, for: .normal)
		button.titleLabel?.font =  UIFont.GothamProMedium(size: 16)
		button.titleLabel?.lineBreakMode = .byWordWrapping
		button.titleLabel?.textAlignment = .center
		button.setTitleColor(UIColor(hex: Constants.Colors.PRIMARY_TEXT_GRAY), for: .normal)
		button.layer.cornerRadius = 4
		return button
	}
	
	
	
	/* MARK: Interface Elements: Labels
	/////////////////////////////////////////// */
	func createCloseButton() {
		let button: UIButton = UIButton(frame: CGRect(x: view.frame.size.width - 60, y: 15, width: 40, height: 40))
		button.titleLabel?.font = UIFont.fontAwesome(ofSize: 27, style: .solid)
		button.setTitle(String.fontAwesomeIcon(name: .times), for: .normal)
		button.addTarget(self, action: #selector(closeButtonPressed), for: .touchUpInside)
		self.view.addSubview(button)
	}
	
	func createTitleLabel() {
		let label: UILabel = UILabel(frame: CGRect(x: (self.view.frame.size.width - 250)/2, y: 40, width: 250, height: 30))
		label.text = Constants.Strings.UPGRADE_SCREEN_TITLE
		label.font = UIFont.GothamProMedium(size: 20)
		label.textColor = UIColor.white
		label.textAlignment = .center
		self.view.addSubview(label)
	}
	
	func createTermsLabel() {
		let label: UILabel = UILabel(frame: CGRect(x: (self.view.frame.size.width - 350)/2, y: view.center.y + CGFloat(170), width: 350, height: 120))
		label.text = Constants.Strings.UPGRADE_SCREENS_INFO
		label.font = UIFont.systemFont(ofSize: 10.0)
		label.textColor = UIColor.white
		label.textAlignment = .center
		label.numberOfLines = 6
		self.view.addSubview(label)
	}
	
	
	
	/* MARK: Button Actions
	/////////////////////////////////////////// */
	@objc func closeButtonPressed() {
		Utils.presentView(self, viewName: Constants.Views.SETTINGS_NAV_CONTROLLER)
	}
	
	@objc func subscribeMonthlyButtonPressed() {
		SwiftyStoreKit.purchaseProduct(Constants.Purchases.SUBSCRIPTION_MONTHLY_KEY, atomically: true) { result in
			Purchase.handlePurchaseResult(result, view: self, purchaseItem: Constants.Purchases.SUBSCRIPTION_MONTHLY_KEY)
		}
	}
	
	@objc func subscribeYearlyButtonPressed() {
		SwiftyStoreKit.purchaseProduct(Constants.Purchases.SUBSCRIPTION_YEARLY_KEY, atomically: true) { result in
			Purchase.handlePurchaseResult(result, view: self, purchaseItem: Constants.Purchases.SUBSCRIPTION_YEARLY_KEY)
		}
	}
	
	@objc func unlockButtonPressed() {
		SwiftyStoreKit.purchaseProduct(Constants.Purchases.UNLOCK_KEY, atomically: true) { result in
			Purchase.handlePurchaseResult(result, view: self, purchaseItem: Constants.Purchases.UNLOCK_KEY)
		}
	}
}

extension Upgrade: PaperOnboardingDelegate {
	func onboardingWillTransitonToIndex(_ index: Int) { }
	func onboardingDidTransitonToIndex(_ index: Int) { }
	func onboardingConfigurationItem(_ item: OnboardingContentViewItem, index: Int) { }
}

extension Upgrade: PaperOnboardingDataSource {
	func onboardingItem(at index: Int) -> OnboardingItemInfo {
		let titleFont = UIFont.GothamProBold(size: 30.0) ?? UIFont.boldSystemFont(ofSize: 36.0)
		let descriptionFont = UIFont.GothamProRegular(size: CGFloat(15)) ?? UIFont.systemFont(ofSize: CGFloat(15))
		
		return [
			OnboardingItemInfo(informationImage: UIImage(named: "trophy")!,
							   title: Constants.Strings.UPGRADE_SCREEN_ONE_TITLE,
							   description: Constants.Strings.UPGRADE_SCREEN_ONE_TEXT,
							   pageIcon: UIImage(named: "transparent")!,
							   color: UIColor(hex: Constants.Colors.BLUE),
							   titleColor: UIColor.white,
							   descriptionColor: UIColor.white,
							   titleFont: titleFont,
							   descriptionFont: descriptionFont),
			
			OnboardingItemInfo(informationImage: UIImage(named: "creative")!,
							   title: Constants.Strings.UPGRADE_SCREEN_TWO_TITLE,
							   description: Constants.Strings.UPGRADE_SCREEN_TWO_TEXT,
							   pageIcon: UIImage(named: "transparent")!,
							   color: UIColor(hex: Constants.Colors.GREEN),
							   titleColor: UIColor.white,
							   descriptionColor: UIColor.white,
							   titleFont: titleFont,
							   descriptionFont: descriptionFont),
			
			OnboardingItemInfo(informationImage: UIImage(named: "diamond")!,
							   title: Constants.Strings.UPGRADE_SCREEN_THREE_TITLE,
							   description: Constants.Strings.UPGRADE_SCREEN_THREE_TEXT,
							   pageIcon: UIImage(named: "transparent")!,
							   color: UIColor(hex: Constants.Colors.PURPLE),
							   titleColor: UIColor.white,
							   descriptionColor: UIColor.white,
							   titleFont: titleFont,
							   descriptionFont: descriptionFont)
			][index]
	}
	
	func onboardingItemsCount() -> Int {
		return 3
	}
}
