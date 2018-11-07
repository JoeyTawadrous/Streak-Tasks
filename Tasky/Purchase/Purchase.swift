import SwiftyStoreKit
import UIKit


class Purchase {

	class func handlePurchaseResult(_ result: PurchaseResult, view: UIViewController, purchaseItem: String) {
		switch result {
			case .success(_):
				
				if purchaseItem == Constants.Purchases.SUBSCRIPTION_MONTHLY_KEY {
					Utils.set(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION, value: true)
				}
				else if purchaseItem == Constants.Purchases.SUBSCRIPTION_YEARLY_KEY {
					Utils.set(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION, value: true)
				}
				else if purchaseItem == Constants.Purchases.UNLOCK_KEY {
					Utils.set(key: Constants.Defaults.USER_HAS_UNLOCKED_APP, value: true)
				}
				else {
					Purchase.updatePurchasedThemes(purchaseItem)
					Utils.set(key: Constants.Defaults.CURRENT_THEME, value: purchaseItem)
					Utils.insertGradientIntoView(viewController: view)
					Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_SUCCESS)
				}
			
			
			case .error(let error):
				switch error.code {
					case .storeProductNotAvailable:
						Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_NOT_AVAILABLE)
					
					case .paymentInvalid:
						Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_IDENTIFIER_INVALID)
					
					case .paymentCancelled:
						Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_CANCELLED)
					
					case .paymentNotAllowed:
						Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_NOT_ALLOWED)
					
					case .clientInvalid:
						Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_NOT_ALLOWED)
					
					default:
						Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_LOGIN)
				}
		}
	}

	
	class func completeTransactions() {
		SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
			for purchase in purchases {
				switch purchase.transaction.transactionState {
					case .purchased, .restored:
						if purchase.needsFinishTransaction {
							SwiftyStoreKit.finishTransaction(purchase.transaction)
						}
					case .failed, .purchasing, .deferred:
						break
				}
			}
		}
	}
	
	
	class func restorePurchases(view: UIViewController, showDialog: Bool) {
		SwiftyStoreKit.restorePurchases(atomically: true) { results in
			if results.restoreFailedPurchases.count > 0 {
				if showDialog { Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_RESTORE_ERROR) }
			}
			else if results.restoredPurchases.count > 0 {
				
				for purchase in results.restoredPurchases {
					let downloads = purchase.transaction.downloads
					
					if !downloads.isEmpty {
						SwiftyStoreKit.start(downloads)
					}
					else if purchase.needsFinishTransaction {
						
						for purchasedItem in purchase.transaction.downloads {
							
							if purchasedItem.contentIdentifier == Constants.Purchases.SUBSCRIPTION_MONTHLY_KEY {
								Utils.set(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION, value: true)
							}
							else if purchasedItem.contentIdentifier == Constants.Purchases.SUBSCRIPTION_YEARLY_KEY {
								Utils.set(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION, value: true)
							}
							else if purchasedItem.contentIdentifier == Constants.Purchases.UNLOCK_KEY {
								Utils.set(key: Constants.Defaults.USER_HAS_UNLOCKED_APP, value: true)
							}
							else {
								Purchase.updatePurchasedThemes(purchasedItem.contentIdentifier)
								Utils.set(key: Constants.Defaults.CURRENT_THEME, value: purchasedItem.contentIdentifier)
								if showDialog { Utils.insertGradientIntoView(viewController: view) }
								if showDialog { Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_SUCCESS) }
							}
						}
						
						SwiftyStoreKit.finishTransaction(purchase.transaction)
					}
				}
				
				if showDialog { Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_RESTORE_SUCCESS) }
			}
			else {
				if showDialog { Dialogs.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_RESTORE_NOTHING) }
			}
		}
	}
	
	
	class func supportStorePurchase() {
		SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
			return true
		}
	}
	
	
	class func updatePurchasedThemes(_ theme: String) {
		var purchasedProducts = Utils.object(key: Constants.Defaults.PURCHASED_THEMES) as? [String] ?? [String]()
		purchasedProducts.append(theme)
		Utils.set(key: Constants.Defaults.PURCHASED_THEMES, value: purchasedProducts)
	}
	
	
	class func verifyReceipt() {
		let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.Purchases.SHARED_SECRET)
		SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
			switch result {
			case .success(let receipt):
				
				if Utils.bool(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION) {
					let monthlySubscriptionResult = SwiftyStoreKit.verifySubscription (
						ofType: .autoRenewable,
						productId: Constants.Purchases.SUBSCRIPTION_MONTHLY_KEY,
						inReceipt: receipt
					)
					switch monthlySubscriptionResult {
					case .purchased(_):
						Utils.set(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION, value: true)
						
					case .expired(_):
						Utils.set(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION, value: false)
						
					case .notPurchased:
						break
					}
				}
				
				
				if Utils.bool(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION) {
					let yearlySubscriptionResult = SwiftyStoreKit.verifySubscription (
						ofType: .autoRenewable,
						productId: Constants.Purchases.SUBSCRIPTION_MONTHLY_KEY,
						inReceipt: receipt
					)
					switch yearlySubscriptionResult {
					case .purchased(_):
						Utils.set(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION, value: true)
						
					case .expired(_):
						Utils.set(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION, value: false)
						
					case .notPurchased:
						break
					}
				}
				
			case .error(_):
				Utils.set(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION, value: false)
				Utils.set(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION, value: false)
			}
		}
	}
	
	
	class func verifyReceiptCheck() {
		// Only (possibly) show sign into itunes dialog when user has already purchased
		if Utils.bool(key: Constants.Defaults.USER_HAS_MONTHLY_SUBSCRIPTION) || Utils.bool(key: Constants.Defaults.USER_HAS_YEARLY_SUBSCRIPTION) {
			Purchase.verifyReceipt()
		}
	}
}
