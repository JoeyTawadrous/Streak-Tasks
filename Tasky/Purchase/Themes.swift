import Foundation
import UIKit
import CoreData
import SwiftyStoreKit


class Themes: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var backButton: UIBarButtonItem!
	@IBOutlet var restoreButton: UIBarButtonItem!
    
	
	
    /* MARK: Initialising
    /////////////////////////////////////////// */
    override func viewWillAppear(_ animated: Bool) {
        Utils.insertGradientIntoView(viewController: self)
		Utils.createFontAwesomeBarButton(button: restoreButton, icon: .sync, style: .solid)
		Utils.createFontAwesomeBarButton(button: backButton, icon: .arrowLeft, style: .solid)
        tableView.separatorStyle = UITableViewCell.SeparatorStyle.none
    }
    
    
    
    /* MARK: Button Actions
    /////////////////////////////////////////// */
	@IBAction func backButtonPressed() {
		Utils.presentView(self, viewName: Constants.Views.SETTINGS_NAV_CONTROLLER)
	}
	
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
		Purchase.restorePurchases(view: self, showDialog: true)
    }
	
	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: "cell")
//        if cell == nil {
//            cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: "cell")
//        }
        let cell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
		
		let themes = Constants.Purchases.Colors.keys
		let theme = Array(themes)[indexPath.row]
		
		cell.textLabel?.text = theme.capitalizeFirst()
		cell.textLabel?.textColor = UIColor.white
		cell.textLabel?.font = UIFont.GothamProMedium(size: 20.0)
		
		cell.selectionStyle = .none
		
		Utils.insertGradientIntoCell(view: cell, color1: Constants.Purchases.Colors[theme]![0], color2: Constants.Purchases.Colors[theme]![1])
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		
		let themes = Constants.Purchases.Colors.keys
		let theme = Array(themes)[indexPath.row]
		
		var currentTheme = Constants.Purchases.WHITE_THEME
		if Utils.contains(key: Constants.Defaults.CURRENT_THEME) {
			currentTheme = Utils.string(key: Constants.Defaults.CURRENT_THEME)
		}
		
		if theme == currentTheme {
			Dialogs.showOkButtonDialog(view: self, message: currentTheme + " is Currently Set." + "Please select another theme to set as default.")
		}
		else if Utils.bool(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION) || Utils.bool(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION) || Utils.bool(key: Constants.Defaults.USER_HAS_UNLOCKED_APP) {
			Utils.set(key: Constants.Defaults.CURRENT_THEME, value: theme)
			Utils.insertGradientIntoView(viewController: self)
			Dialogs.showOkButtonDialog(view: self, message: Constants.Strings.PURCHASE_SUCCESS)
		}
		else {
			if theme != Constants.Purchases.WHITE_THEME {
				if Utils.contains(key: Constants.Defaults.PURCHASED_THEMES) {
					let purchasedThemes = Utils.object(key: Constants.Defaults.PURCHASED_THEMES) as? [String]
					if !(purchasedThemes?.contains(theme))! {
						SwiftyStoreKit.purchaseProduct(Constants.Purchases.THEME_ID_PREFIX + theme, atomically: true) { result in
							Purchase.handlePurchaseResult(result, view: self, purchaseItem: theme)
						}
					}
				}
				else {
					SwiftyStoreKit.purchaseProduct(Constants.Purchases.THEME_ID_PREFIX + theme, atomically: true) { result in
						Purchase.handlePurchaseResult(result, view: self, purchaseItem: theme)
					}
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 68.0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Constants.Purchases.Colors.count
	}
}
