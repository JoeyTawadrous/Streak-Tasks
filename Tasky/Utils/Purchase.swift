import SwiftyStoreKit
import UIKit


class Purchase {

	class func handlePurchaseResult(_ result: PurchaseResult, view: UIViewController, purchasedItem: String) {
		switch result {
		case .success(let productId):
			print("Purchase Success: \(productId)")
			
			Purchase.updatePurchasedThemes(purchasedItem)
			UserDefaults.standard.set(purchasedItem, forKey: Constants.Purchases.CURRENT_THEME)
			Utils.insertGradientIntoView(viewController: view)
			Utils.showOkButtonDialog(view: view, message: "Your new theme has been succesfully purchased and set. Enjoy :)")
			
		case .error(let error):
			print("Purchase Failed: \(error)")
			
			switch error.code {
				case .storeProductNotAvailable:
					Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_NOT_AVAILABLE)
				
				case .paymentInvalid:
					Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_IDENTIFIER_INVALID)
				
				case .paymentCancelled:
					Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_CANCELLED)
				
				case .paymentNotAllowed:
					Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_NOT_ALLOWED)
				
				case .clientInvalid:
					Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_NOT_ALLOWED)
				
				default:
					Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_ERROR_UNKNOWN)
			}
		}
	}
	
	
	class func completeTransactions() {
		SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
			for purchase in purchases {
				switch purchase.transaction.transactionState {
					case .purchased, .restored:
						if purchase.needsFinishTransaction {
							// Deliver content from server, then:
							SwiftyStoreKit.finishTransaction(purchase.transaction)
						}
					// TODO: Joey Unlock content
					case .failed, .purchasing, .deferred:
						break // do nothing
				}
			}
		}
	}
	
	
	class func restorePurchases(view: UIViewController) {
		SwiftyStoreKit.restorePurchases(atomically: true) { results in
			if results.restoreFailedPurchases.count > 0 {
				Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_RESTORE_ERROR)
			}
			else if results.restoredPurchases.count > 0 {
				for purchase in results.restoredPurchases {
					let downloads = purchase.transaction.downloads
					if !downloads.isEmpty {
						SwiftyStoreKit.start(downloads)
					}
					else if purchase.needsFinishTransaction {
						for purchasedItem in purchase.transaction.downloads {
							Purchase.updatePurchasedThemes(purchasedItem.contentIdentifier)
						}
						
						SwiftyStoreKit.finishTransaction(purchase.transaction)
					}
				}
				
				Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_RESTORE_SUCCESS)
			}
			else {
				Utils.showOkButtonDialog(view: view, message: Constants.Strings.PURCHASE_RESTORE_NOTHING)
			}
		}
	}
	
	
	class func supportStorePurchase() {
		SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
			return true
		}
	}
	
	class func updatePurchasedThemes(_ theme: String) {
		var purchasedProducts = UserDefaults.standard.object(forKey: Constants.Purchases.PURCHASED_PRODUCTS) as? [String] ?? [String]()
		purchasedProducts.append(theme)
		UserDefaults.standard.set(purchasedProducts, forKey: Constants.Purchases.PURCHASED_PRODUCTS)
	}
	
	
	//  TEST
	//	SwiftyStoreKit.retrieveProductsInfo(["com.joeyt.learnable.subscription"]) { result in
	//	if let product = result.retrievedProducts.first {
	//	let priceString = product.localizedPrice!
	//	print("Product: \(product.localizedDescription), price: \(priceString)")
	//	}
	//	else if let invalidProductId = result.invalidProductIDs.first {
	//	print("Invalid product identifier: \(invalidProductId)")
	//	}
	//	else {
	//	print("Error: \(result.error)")
	//	}
	//	}
}
