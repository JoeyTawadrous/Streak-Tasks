import UIKit
import CoreData
import Social

class Utils {
	
	
	/* MARK: Dates
	/////////////////////////////////////////// */
	class func getDayOfWeek(_ date:String) -> String? {
		let formatter  = DateFormatter()
		formatter.dateFormat = Constants.LocalData.DATE_FORMAT
		
		if let todayDate = formatter.date(from: date) {
			let myCalendar = Calendar(identifier: Calendar.Identifier.gregorian)
			let myComponents = (myCalendar as NSCalendar).components(.weekday, from: todayDate)
			let weekDay = myComponents.weekday!
			
			switch weekDay {
			case 1 :
				return "Saturday"
			case 2 :
				return "Sunday"
			case 3 :
				return "Monday"
			case 4 :
				return "Tuesday"
			case 5 :
				return "Wednesday"
			case 6 :
				return "Thursday"
			case 7 :
				return "Friday"
			default :
				print("Error fetching days")
				return "Day"
			}
		} else {
			return nil
		}
	}
	
	
	
	/* MARK: Images
	/////////////////////////////////////////// */
	class func imageResize (_ image:UIImage, sizeChange:CGSize) -> UIImage{
		let hasAlpha = true
		let scale: CGFloat = 0.0 // Use scale factor of main screen
		
		UIGraphicsBeginImageContextWithOptions(sizeChange, !hasAlpha, scale)
		image.draw(in: CGRect(origin: CGPoint.zero, size: sizeChange))
		
		let scaledImage = UIGraphicsGetImageFromCurrentImageContext()
		return scaledImage!
	}
	
	
	
	/* MARK: Reminders
	/////////////////////////////////////////// */
	class func scheduleReminder(_ catchUp: NSManagedObject) {
		let notification = UILocalNotification() // create a new reminder notification
		notification.alertBody = "Don't forget: \(catchUp.value(forKey: Constants.CoreData.REASON) as! NSString)"
		notification.alertAction = "Open"
		notification.fireDate = Date().addingTimeInterval(30 * 60) // 30 minutes from current time
		notification.soundName = UILocalNotificationDefaultSoundName
		notification.userInfo = ["UUID": catchUp.value(forKey: Constants.CoreData.UUID)!]
		notification.category = Constants.LocalNotifications.ACTION_CATEGORY_IDENTIFIER
		
		UIApplication.shared.scheduleLocalNotification(notification)
	}
    
    
	
	/* MARK: Colors
	/////////////////////////////////////////// */
    class func getMainColor() -> UIColor {
        return UIColor(hex: "#2C3E50")
    }
    
    class func getNextTableColour(_ number: Int, reverse: DarwinBoolean) -> UIColor {
        var number = number
        
        var theme1 = [String]() // rainbow
        theme1.append("#e53c52")
        theme1.append("#e9543f")
        theme1.append("#f8c543")
        theme1.append("#90ce55")
        theme1.append("#50c89d")
        
        var theme2 = [String]()
        theme2.append("#311e3e") // slide
        theme2.append("#512645")
        theme2.append("#87314e")
        theme2.append("#df405a")
        theme2.append("#F08A5D")
        
        var theme3 = [String]() // tidal
        theme3.append("#513B56")
        theme3.append("#525174")
        theme3.append("#348AA7")
        theme3.append("#5DD39E")
        theme3.append("#BCE784")
        
        var theme5 = [String]() // wave
        theme5.append("#5D4370")
        theme5.append("#605398")
        theme5.append("#4A7EB7")
        theme5.append("#4FA3D2")
        theme5.append("#43CBC7")
        
        var theme6 = [String]() // girly
        theme6.append("#9C89B8")
        theme6.append("#F0A6CA")
        theme6.append("#EFC3E6")
        theme6.append("#B8BEDD")
        theme6.append("#CEE7E6")
        
        var theme7 = [String]() // manly
        theme7.append("#0B2545")
        theme7.append("#3D315B")
        theme7.append("#444B6E")
        theme7.append("#708B75")
        theme7.append("#9AB87A")
        
        var theme8 = [String]() // royal
        theme8.append("#8D3B72")
        theme8.append("#BD4F6C")
        theme8.append("#D7816A")
        theme8.append("#F0CF65")
        theme8.append("#93B5C6")
        
        var theme9 = [String]() // colorful
        theme9.append("#3A86FF")
        theme9.append("#8338EC")
        theme9.append("#FF006E")
        theme9.append("#FB5607")
        theme9.append("#FFBE0B")
        
        var theme10 = [String]() // style
        theme10.append("#e56eb2")
        theme10.append("#9b7be7")
        theme10.append("#4c87e7")
        theme10.append("#42b3e3")
        theme10.append("#50c89d")
        
        
        var colors = theme8
        let currentTheme = UserDefaults.standard.string(forKey: Constants.IAP.CURRENT_THEME)
        
        if currentTheme == Constants.IAP.COLORFUL_THEME {
            colors = theme9
        }
        else if currentTheme == Constants.IAP.GIRLY_THEME {
            colors = theme6
        }
        else if currentTheme == Constants.IAP.MANLY_THEME {
            colors = theme7
        }
        else if currentTheme == Constants.IAP.RAINBOW_THEME {
            colors = theme1
        }
        else if currentTheme == Constants.IAP.ROYAL_THEME {
            colors = theme8
        }
        else if currentTheme == Constants.IAP.SLIDE_THEME {
            colors = theme2
        }
        else if currentTheme == Constants.IAP.STYLE_THEME {
            colors = theme10
        }
        else if currentTheme == Constants.IAP.TIDAL_THEME {
            colors = theme3
        }
        else if currentTheme == Constants.IAP.WAVE_THEME {
            colors = theme5
        }
        
        
        if reverse.boolValue {
            colors = colors.reversed()
        }
        
        while number >= colors.count {
            number = number - colors.count
        }
        
        
		var color = UIColor(hex: "ffffff")
		
        if number == 0 {
            color = UIColor(hex: colors[0])
        }
        else if number == 1 {
            color = UIColor(hex: colors[1])
        }
        else if number == 2 {
            color = UIColor(hex: colors[2])
        }
        else if number == 3 {
            color = UIColor(hex: colors[3])
        }
        else if number == 4 {
            color = UIColor(hex: colors[4])
        }
        
        
        return color;
    }
    
    class func getRandomImageString() -> String {
        var imageArray:[String] = []
        
        for i in 1...54 {
            let image = String(i) + ".png"
            imageArray.append(image)
        }
        
        let randomImageIndex = Int(arc4random_uniform(UInt32(imageArray.count)))
        return imageArray[randomImageIndex]
    }
	
	class func insertGradientIntoView(viewController: UIViewController) {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame.size = viewController.view.frame.size
		gradientLayer.colors = [UIColor(hex: Colors.ROYAL_THEME_COLOR_1).cgColor, UIColor(hex: Colors.ROYAL_THEME_COLOR_2).cgColor]
		viewController.view.layer.insertSublayer(gradientLayer, at: 0)
	}
	
	class func insertGradientIntoTableView(viewController: UIViewController, tableView: UITableView) {
		let gradientLayer = CAGradientLayer()
		gradientLayer.frame.size = viewController.view.frame.size
		gradientLayer.colors = [UIColor(hex: Colors.ROYAL_THEME_COLOR_1).cgColor, UIColor(hex: Colors.ROYAL_THEME_COLOR_2).cgColor]
		let bgView = UIView.init(frame: tableView.frame)
		bgView.layer.insertSublayer(gradientLayer, at: 0)
		tableView.backgroundView = bgView
	}
	
	
	
	/* MARK: Core Data
	/////////////////////////////////////////// */
	class func createObject(_ type: String) -> NSManagedObject {
		let entity = NSEntityDescription.entity(forEntityName: type, in: fetchManagedObjectContext())
		let object = NSManagedObject(entity: entity!, insertInto:fetchManagedObjectContext())
		return object;
	}
	
	class func saveObject() {
		do {
			try fetchManagedObjectContext().save()
		}
		catch {
			print("Could not save \(error)")
		}
	}
	
	class func fetchCoreDataObject(_ key: String, predicate: String) -> [AnyObject] {
		var fetchedResults = [AnyObject]()
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: key)
		
		if predicate != "" {
			fetchRequest.predicate = NSPredicate(format:"name == %@", predicate)
		}
		
		do {
			fetchedResults = try managedContext.fetch(fetchRequest)
		} catch {
			print(error)
		}
		
		return fetchedResults
	}
	
	class func fetchManagedObjectContext() -> NSManagedObjectContext {
		let appDelegate = UIApplication.shared.delegate as! AppDelegate
		let managedContext = appDelegate.managedObjectContext!
		return managedContext
	}
	
	
	
	// MARK: Social
	/////////////////////////////////////////// */
	class func post(toService service: String, view: UIViewController) {
		if(SLComposeViewController.isAvailable(forServiceType: service)) {
			let socialController = SLComposeViewController(forServiceType: service)
			
			socialController?.setInitialText(Constants.String.SHARE)
			
			view.present(socialController!, animated: true, completion: nil)
		}
		else {
			Utils.presentOkButtonAlert(view, message: "Please ensure you are logged into Facebook / Twitter in your devices settings before you try to post.")
		}
	}
	
	class func share(sender: UIButton, viewController: UIViewController) {
		let share = Constants.String.SHARE
		let link : NSURL = NSURL(string: Constants.Common.APP_STORE_URL)!
		let logo: UIImage = UIImage(named: "logo")!
		
		let activityViewController : UIActivityViewController = UIActivityViewController(activityItems: [share, link, logo], applicationActivities: nil)
		
		// This lines is for the popover you need to show in iPad
		activityViewController.popoverPresentationController?.sourceView = sender
		
		// This line remove the arrow of the popover to show in iPad
		activityViewController.popoverPresentationController?.permittedArrowDirections = UIPopoverArrowDirection()
		activityViewController.popoverPresentationController?.sourceRect = CGRect(x: 150, y: 150, width: 0, height: 0)
		
		// Anything you want to exclude
		activityViewController.excludedActivityTypes = [
			UIActivityType.postToWeibo,
			UIActivityType.print,
			UIActivityType.assignToContact,
			UIActivityType.saveToCameraRoll,
			UIActivityType.addToReadingList,
			UIActivityType.postToFlickr,
			UIActivityType.postToVimeo,
			UIActivityType.postToTencentWeibo
		]
		
		viewController.present(activityViewController, animated: true, completion: nil)
	}
	
	
	// MARK: Visual
	/////////////////////////////////////////// */
	class func getViewController(_ viewName: String) -> UIViewController {
		let storyboard = UIStoryboard(name: "Main", bundle: nil)
		let vc = storyboard.instantiateViewController(withIdentifier: viewName) as UIViewController
		return vc
	}
	
	class func presentView(_ view: UIViewController, viewName: String) {
		view.present(getViewController(viewName), animated: true, completion: nil)
	}
	
	class func pushView(_ view: UIViewController, viewName: String) {
		view.navigationController?.pushViewController(getViewController(viewName), animated: true)
	}
	
	class func presentOkButtonAlert(_ view: UIViewController, message: String) {
		let alert = UIAlertController(title: "Info", message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in }))
		
		view.present(alert, animated: true, completion: nil)
	}
}
