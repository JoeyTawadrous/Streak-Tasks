import UIKit


open class RoundedButton: UIButton {
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.cornerRadius = 5
	}
}


extension UIColor {
	convenience init(hex: String) {
		let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
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
	class func GothamProBlack(size: CGFloat) -> UIFont? {
		return UIFont(name: "GothamPro-Black", size: size)
	}
	
	class func GothamProBold(size: CGFloat) -> UIFont? {
		return UIFont(name: "GothamPro-Bold", size: size)
	}
	
	class func GothamProMedium(size: CGFloat) -> UIFont? {
		return UIFont(name: "GothamPro-Medium", size: size)
	}
	
	class func GothamProRegular(size: CGFloat) -> UIFont? {
		return UIFont(name: "GothamPro-Regular", size: size)
	}
}


extension String {
	func capitalizeFirst() -> String {
		let firstIndex = self.index(startIndex, offsetBy: 1)
		return self.substring(to: firstIndex).capitalized + self.substring(from: firstIndex).lowercased()
	}
}


extension UIView {
	func setHeight(height: CGFloat) {
		var frame: CGRect = self.frame
		frame.size.height = height
		self.frame = frame
	}
	
	func setWidth(width: CGFloat) {
		var frame: CGRect = self.frame
		frame.size.width = width
		self.frame = frame
	}
	
	func addBorderTop(size: CGFloat, color: UIColor) {
		addBorderUtility(x: 0, y: 0, width: frame.width, height: size, color: color)
	}
	func addBorderBottom(size: CGFloat, color: UIColor) {
		addBorderUtility(x: 0, y: frame.height - size, width: frame.width, height: size, color: color)
	}
	func addBorderLeft(size: CGFloat, color: UIColor) {
		addBorderUtility(x: 0, y: 0, width: size, height: frame.height, color: color)
	}
	func addBorderRight(size: CGFloat, color: UIColor) {
		addBorderUtility(x: frame.width - size, y: 0, width: size, height: frame.height, color: color)
	}
	private func addBorderUtility(x: CGFloat, y: CGFloat, width: CGFloat, height: CGFloat, color: UIColor) {
		let border = CALayer()
		border.backgroundColor = color.cgColor
		border.frame = CGRect(x: x, y: y, width: width, height: height)
		layer.addSublayer(border)
	}
}
