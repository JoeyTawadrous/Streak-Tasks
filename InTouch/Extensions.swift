import UIKit


open class RoundedButton: UIButton {
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.cornerRadius = 5
		self.backgroundColor = Utils.getMainColor()
	}
}


extension UIColor {
	convenience init(hexString: String) {
		let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
		var int = UInt32()
		Scanner(string: hex).scanHexInt32(&int)
		let a, r, g, b: UInt32
		switch hex.characters.count {
		case 3: // RGB (12-bit)
			(a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
		case 6: // RGB (24-bit)
			(a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
		case 8: // ARGB (32-bit)
			(a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
		default:
			(a, r, g, b) = (1, 1, 1, 0)
		}
		self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
	}
}


extension UIFont {	
	class func GothamProBold(size: CGFloat) -> UIFont? {
		return UIFont(name: "GothamPro-Bold", size: size)
	}
	
	class func GothamProBlack(size: CGFloat) -> UIFont? {
		return UIFont(name: "GothamPro-Black", size: size)
	}
}


extension UIApplication {
	var statusBarView: UIView? {
		return value(forKey: "statusBar") as? UIView
	}
}
