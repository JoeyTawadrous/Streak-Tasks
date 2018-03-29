import SwiftyStoreKit
import UIKit

class Purchase {
	
	class func verifyReceipt() {
		let appleValidator = AppleReceiptValidator(service: .production, sharedSecret: Constants.Purchases.SHARED_SECRET)
		SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
			switch result {
				case .success(let receipt):
					
					let purchaseResult = SwiftyStoreKit.verifyPurchase (
						productId: Constants.Purchases.UNLOCK_KEY,
						inReceipt: receipt
					)
					
					switch purchaseResult {
						case .purchased(let receiptItem):
							UserDefaults.standard.set(true, forKey: Constants.Defaults.USER_HAS_UNLOCKED_APP)
						case .notPurchased:
							UserDefaults.standard.set(false, forKey: Constants.Defaults.USER_HAS_UNLOCKED_APP)
					}
				
				case .error(let error):
					print("Receipt verification failed: \(error)")
			}
		}
	}
	
	
	class func handlePurchaseResult(_ result: PurchaseResult, view: UIViewController, purchasedItem: String) {
		switch result {
		case .success(let productId):
			print("Purchase Success: \(productId)")
			UserDefaults.standard.set(true, forKey: purchasedItem)
			
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
				UserDefaults.standard.set(true, forKey: Constants.Defaults.USER_HAS_SUBSCRIPTION)
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
