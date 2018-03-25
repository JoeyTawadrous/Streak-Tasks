import Foundation
import UIKit
import CoreData
import StoreKit

class Purchases: UIViewController, SKPaymentTransactionObserver, SKProductsRequestDelegate {
    
	@IBOutlet var scrollView: UIScrollView!
	@IBOutlet var restoreButton: UIBarButtonItem!
	
    let productIdentifiers = Set(["com.joeyt.tasky.iap.theme.colorful", "com.joeyt.tasky.iap.theme.rainbow", "com.joeyt.tasky.iap.theme.style", "com.joeyt.tasky.iap.theme.wave", "com.joeyt.tasky.iap.theme.girly", "com.joeyt.tasky.iap.theme.manly", "com.joeyt.tasky.iap.theme.tidal", "com.joeyt.tasky.iap.theme.slide"])
    var products = Array<SKProduct>()
    
    var down = CGFloat(-30)
    var downAdjust = CGFloat(0)
    
	
	
    /* MARK: Initialising
    /////////////////////////////////////////// */
    override func viewDidLoad() {
        super.viewDidLoad()
		
		// Style
//		view.backgroundColor = Utils.getNextTableColour(0, reverse: false)
		restoreButton.image = Utils.imageResize(UIImage(named: "refresh")!, sizeChange: CGSize(width: 22, height: 22)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
		
        // IAP's
        UserDefaults.standard.set(false, forKey: Constants.IAP.TRANSACTION_IN_PROGRESS)
        SKPaymentQueue.default().add(self)
        requestProductData()
		
        // Theme image and button for the royal theme
        addImageButton(view, scrollView: scrollView, down: downAdjust, image: Constants.IAP.ROYAL_THEME)
        addButton(view, scrollView: scrollView, down: downAdjust, title: Constants.IAP.ROYAL_THEME)
    }
    
    
    
    /* MARK: Button Actions
    /////////////////////////////////////////// */
    @IBAction func themePressed(_ sender: UIButton) {
        
        // if the user is not already making a purchase
        if UserDefaults.standard.bool(forKey: Constants.IAP.TRANSACTION_IN_PROGRESS) == false {
            
            let currentTheme = UserDefaults.standard.string(forKey: Constants.IAP.CURRENT_THEME)
            
            // If the sender is the current theme
            if sender.titleLabel?.text == currentTheme {
				Utils.presentOkButtonAlert(self, message: currentTheme! + " is Currently Set." + "Please select another theme to set as default.")
            }
            else {
                let purchasedProducts = UserDefaults.standard.object(forKey: Constants.IAP.PURCHASED_PRODUCTS) as? [String] ?? [String]()
                
                // If the sender is not the royal theme and it has not been purchased before
                if sender.titleLabel?.text != Constants.IAP.ROYAL_THEME && !purchasedProducts.contains((sender.titleLabel?.text)!) {
                    
                    // Find the product the user wants to purchase
                    for product: SKProduct in products {
                        if product.localizedTitle == sender.titleLabel?.text {
                            UserDefaults.standard.set(true, forKey: Constants.IAP.TRANSACTION_IN_PROGRESS)
                            SKPaymentQueue.default().add(SKPayment(product: product))
                        }
                    }
                }
                else {
                    UserDefaults.standard.set(sender.titleLabel?.text, forKey: Constants.IAP.CURRENT_THEME)
                    
                    // Refresh theme
//                    view.backgroundColor = Utils.getNextTableColour(0, reverse: false)
					
					Utils.presentOkButtonAlert(self, message: (sender.titleLabel?.text)! + " has been set.")
                }
            }
        }
    }
    
    @IBAction func restoreButtonPressed(_ sender: UIButton) {
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
	
	
	
	/* MARK: Core Functionality
	/////////////////////////////////////////// */
	func addImageButton(_ view: UIView, scrollView: UIScrollView, down: CGFloat, image: String) {
		let imageButton = UIButton(type: UIButtonType.custom)
		let center = (view.frame.size.width - view.frame.size.width / 1.3) / 2;
		
		imageButton.frame = CGRect(x: center, y: down, width: view.frame.size.width / 1.3, height: view.frame.size.width / 1.3) // 414
		imageButton.setImage(UIImage(named: image), for: UIControlState())
		imageButton.addTarget(self, action: #selector(themePressed), for: .touchUpInside)
		imageButton.setTitle(image, for: UIControlState())
		
		scrollView.addSubview(imageButton)
		
		// Spacing
		downAdjust = imageButton.frame.origin.y + view.frame.size.width / 1.2
	}
	
	func addButton(_ view: UIView, scrollView: UIScrollView, down: CGFloat, title: String) {
		let button = RoundedButton(type: UIButtonType.custom)
		let center = (view.frame.size.width - view.frame.size.width / 2) / 2;
		
		button.frame = CGRect(x: center, y: down, width: view.frame.size.width / 2.2, height: 40) // 414
		button.addTarget(self, action: #selector(themePressed), for: .touchUpInside)
		
		button.setTitle(title, for: UIControlState())
		
		scrollView.addSubview(button)
		
		// Spacing
		downAdjust = button.frame.origin.y + 90
		
		// Set scroll view height to just below button
		scrollView.contentSize.height = button.frame.origin.y + 90
	}
	
	func drawThemeButtons() {
		for product: SKProduct in products {
			addImageButton(view, scrollView: scrollView, down: downAdjust, image: product.localizedTitle)
			addButton(view, scrollView: scrollView, down: downAdjust, title: product.localizedTitle)
		}
	}
	
	
	
    /* MARK: IAP's
    /////////////////////////////////////////// */
    func requestProductData() {
        if SKPaymentQueue.canMakePayments() {
            let request = SKProductsRequest(productIdentifiers: productIdentifiers)
            request.delegate = self
            request.start()
        }
        else {
            let alert = UIAlertController(title: "In-App Purchases Not Enabled", message: "Please enable In App Purchase in Settings", preferredStyle: UIAlertControllerStyle.alert)
            
            alert.addAction(UIAlertAction(title: "Settings", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
                let url: URL? = URL(string: UIApplicationOpenSettingsURLString)
                if url != nil {
                    UIApplication.shared.openURL(url!)
                }
            }))
            
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: { alertAction in
                alert.dismiss(animated: true, completion: nil)
            }))
            
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        var products = response.products
        
        if (products.count != 0) {
            for i in 0 ..< products.count {
                self.products.append(products[i])
            }
            
            drawThemeButtons()
        } else {
            print("No products found")
        }
    }
    
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
        checkAndApplyPurchasedTheme(transaction.payment.productIdentifier)
		Utils.presentOkButtonAlert(self, message: "Your new theme has been succesfully purchased and set. Enjoy :)")
    }
    
    func paymentQueueRestoreCompletedTransactionsFinished(_ queue: SKPaymentQueue) { // Restore past transactions
        for transaction:SKPaymentTransaction in queue.transactions {
            checkAndApplyPurchasedTheme(transaction.payment.productIdentifier)
        }
		
		Utils.presentOkButtonAlert(self, message: "Restored purchase(s) successfully.")
    }
    
    func checkAndApplyPurchasedTheme(_ productIdentifier: String) {
        if productIdentifier == "com.joeyt.tasky.iap.theme.colorful" {
            UserDefaults.standard.set(Constants.IAP.COLORFUL_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.COLORFUL_THEME)
        }
        else if productIdentifier == "com.joeyt.tasky.iap.theme.girly" {
            UserDefaults.standard.set(Constants.IAP.GIRLY_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.GIRLY_THEME)
        }
        else if productIdentifier == "com.joeyt.tasky.iap.theme.manly" {
            UserDefaults.standard.set(Constants.IAP.MANLY_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.MANLY_THEME)
        }
        else if productIdentifier == "com.joeyt.tasky.iap.theme.rainbow" {
            UserDefaults.standard.set(Constants.IAP.RAINBOW_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.RAINBOW_THEME)
        }
        else if productIdentifier == "com.joeyt.tasky.iap.theme.slide" {
            UserDefaults.standard.set(Constants.IAP.SLIDE_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.SLIDE_THEME)
        }
        else if productIdentifier == "com.joeyt.tasky.iap.theme.style" {
            UserDefaults.standard.set(Constants.IAP.STYLE_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.STYLE_THEME)
        }
        else if productIdentifier == "com.joeyt.tasky.iap.theme.tidal" {
            UserDefaults.standard.set(Constants.IAP.TIDAL_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.TIDAL_THEME)
        }
        else if productIdentifier == "com.joeyt.tasky.iap.theme.wave" {
            UserDefaults.standard.set(Constants.IAP.WAVE_THEME, forKey: Constants.IAP.CURRENT_THEME)
            updatePurchasedThemesArray(Constants.IAP.WAVE_THEME)
        }
        
        // Refresh theme
//        view.backgroundColor = Utils.getNextTableColour(0, reverse: false)
    }
    
    func updatePurchasedThemesArray(_ theme: String) {
        var purchasedProducts = UserDefaults.standard.object(forKey: Constants.IAP.PURCHASED_PRODUCTS) as? [String] ?? [String]()
        purchasedProducts.append(theme)
		
        UserDefaults.standard.set(purchasedProducts, forKey: Constants.IAP.PURCHASED_PRODUCTS)
    }
}
