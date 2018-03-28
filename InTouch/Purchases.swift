import Foundation
import UIKit
import CoreData
import StoreKit


class Purchases: UIViewController, UITableViewDataSource, UITableViewDelegate, SKPaymentTransactionObserver {
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var restoreButton: UIBarButtonItem!

    var products = Array<SKProduct>()
    
	
	
    /* MARK: Initialising
    /////////////////////////////////////////// */
    override func viewWillAppear(_ animated: Bool) {
        Utils.insertGradientIntoView(viewController: self)
		tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		
		// Nav bar
		var attributes = [NSAttributedStringKey : Any]()
		attributes = [.font: UIFont.fontAwesome(ofSize: 21)]
		restoreButton.setTitleTextAttributes(attributes, for: .normal)
		restoreButton.setTitleTextAttributes(attributes, for: .selected)
		restoreButton.title = String.fontAwesomeIcon(name: .refresh)
		
        // IAP's
        UserDefaults.standard.set(false, forKey: Constants.IAP.TRANSACTION_IN_PROGRESS)
        SKPaymentQueue.default().add(self)
    }
    
    
    
    /* MARK: Button Actions
    /////////////////////////////////////////// */
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
	
	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
	internal func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: Constants.Common.CELL)
		if cell == nil {
			cell = UITableViewCell(style: UITableViewCellStyle.subtitle, reuseIdentifier: Constants.Common.CELL)
		}
		
		// UNLOCK ALL + payments
		
		let themes = Constants.IAP.Colors.keys
		let theme = Array(themes)[indexPath.row]
		
		cell.textLabel?.text = theme.capitalizeFirst()
		cell.textLabel?.textColor = UIColor.white
		cell.textLabel?.font = UIFont.systemFont(ofSize: 20.0)
		
		cell.selectionStyle = .none
		
		Utils.insertGradientIntoCell(view: cell, color1: Constants.IAP.Colors[theme]![0], color2: Constants.IAP.Colors[theme]![1])
		
		return cell
	}
	
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: false)
		
		let themes = Constants.IAP.Colors.keys
		let theme = Array(themes)[indexPath.row]
		
		// if the user is not already making a purchase
		if UserDefaults.standard.bool(forKey: Constants.IAP.TRANSACTION_IN_PROGRESS) == false {
			let currentTheme = UserDefaults.standard.string(forKey: Constants.IAP.CURRENT_THEME)

			// If the sender is the current theme
			if theme == currentTheme {
				Utils.presentOkButtonAlert(self, message: currentTheme! + " is Currently Set." + "Please select another theme to set as default.")
			}
			else {
				let purchasedProducts = UserDefaults.standard.object(forKey: Constants.IAP.PURCHASED_PRODUCTS) as? [String] ?? [String]()

				// If the sender is not the royal theme and it has not been purchased before
				if theme != Constants.IAP.MALIBU_THEME && !purchasedProducts.contains((theme)) {
					// Find the product the user wants to purchase
					for product: SKProduct in products {
						if product.localizedTitle == theme {
							UserDefaults.standard.set(true, forKey: Constants.IAP.TRANSACTION_IN_PROGRESS)
							SKPaymentQueue.default().add(SKPayment(product: product))
						}
					}
				}
				else {
					UserDefaults.standard.set(theme, forKey: Constants.IAP.CURRENT_THEME)
					Utils.insertGradientIntoView(viewController: self)
				}
			}
		}
	}
	
	func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
		return 68.0
	}
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return Constants.IAP.Colors.count
	}
	

	
	
    /* MARK: IAP's
    /////////////////////////////////////////// */
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        for transaction in transactions {
            switch transaction.transactionState {
                case SKPaymentTransactionState.purchased:
                    print("Transaction Approved")
                    print("Product Identifier: \(transaction.payment.productIdentifier)")
                    deliverProduct(transaction)
                    SKPaymentQueue.default().finishTransaction(transaction)
                    UserDefaults.standard.set(false, forKey: Constants.IAP.TRANSACTION_IN_PROGRESS)
                    
                case SKPaymentTransactionState.failed:
                    print("Transaction Failed")
                    SKPaymentQueue.default().finishTransaction(transaction)
                    UserDefaults.standard.set(false, forKey: Constants.IAP.TRANSACTION_IN_PROGRESS)
                
                default:
                    break
            }
        }
    }
    
    func deliverProduct(_ transaction:SKPaymentTransaction) {
        applyTheme(transaction.payment.productIdentifier)
		Utils.presentOkButtonAlert(self, message: "Your new theme has been succesfully purchased and set. Enjoy :)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) { // Restore past transactions
        for transaction:SKPaymentTransaction in queue.transactions {
            applyTheme(transaction.payment.productIdentifier)
        }
		
		Utils.presentOkButtonAlert(self, message: "Restored purchase(s) successfully.")
    }
    
    func applyTheme(_ productIdentifier: String) {
		let parts = productIdentifier.components(separatedBy: ".")
		updatePurchasedThemes(parts[parts.count])
		Utils.insertGradientIntoView(viewController: self)
    }
    
    func updatePurchasedThemes(_ theme: String) {
        var purchasedProducts = UserDefaults.standard.object(forKey: Constants.IAP.PURCHASED_PRODUCTS) as? [String] ?? [String]()
        purchasedProducts.append(theme)
		
		UserDefaults.standard.set(theme, forKey: Constants.IAP.CURRENT_THEME)
        UserDefaults.standard.set(purchasedProducts, forKey: Constants.IAP.PURCHASED_PRODUCTS)
    }
}
