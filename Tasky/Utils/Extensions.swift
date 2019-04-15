import UIKit


extension NSMutableAttributedString {
	public func setAsLink(textToFind:String, linkURL:String) {
		let foundRange = self.mutableString.range(of: textToFind)
		if foundRange.location != NSNotFound {
            self.addAttribute(NSAttributedString.Key.link, value: linkURL, range: foundRange)
//			self.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor(hex: Constants.Colors.PRIMARY_TEXT_GRAY) , range: foundRange)
		}
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


extension UIDevice {
	static let modelName: String = {
		var systemInfo = utsname()
		uname(&systemInfo)
		let machineMirror = Mirror(reflecting: systemInfo.machine)
		let identifier = machineMirror.children.reduce("") { identifier, element in
			guard let value = element.value as? Int8, value != 0 else { return identifier }
			return identifier + String(UnicodeScalar(UInt8(value)))
		}
		
		func mapToDevice(identifier: String) -> String { // swiftlint:disable:this cyclomatic_complexity
			#if os(iOS)
			switch identifier {
			case "iPod5,1":                                 return "iPod Touch 5"
			case "iPod7,1":                                 return "iPod Touch 6"
			case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
			case "iPhone4,1":                               return "iPhone 4s"
			case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
			case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
			case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
			case "iPhone7,2":                               return "iPhone 6"
			case "iPhone7,1":                               return "iPhone 6 Plus"
			case "iPhone8,1":                               return "iPhone 6s"
			case "iPhone8,2":                               return "iPhone 6s Plus"
			case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
			case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
			case "iPhone8,4":                               return "iPhone SE"
			case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
			case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
			case "iPhone10,3", "iPhone10,6":                return "iPhone X"
			case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
			case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
			case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
			case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
			case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
			case "iPad6,11", "iPad6,12":                    return "iPad 5"
			case "iPad7,5", "iPad7,6":                      return "iPad 6"
			case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
			case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
			case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
			case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
			case "iPad6,3", "iPad6,4":                      return "iPad Pro 9.7 Inch"
			case "iPad6,7", "iPad6,8":                      return "iPad Pro 12.9 Inch"
			case "iPad7,1", "iPad7,2":                      return "iPad Pro 12.9 Inch 2. Generation"
			case "iPad7,3", "iPad7,4":                      return "iPad Pro 10.5 Inch"
			case "AppleTV5,3":                              return "Apple TV"
			case "AppleTV6,2":                              return "Apple TV 4K"
			case "AudioAccessory1,1":                       return "HomePod"
			case "i386", "x86_64":                          return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "iOS"))"
			default:                                        return identifier
			}
			#elseif os(tvOS)
			switch identifier {
			case "AppleTV5,3": return "Apple TV 4"
			case "AppleTV6,2": return "Apple TV 4K"
			case "i386", "x86_64": return "Simulator \(mapToDevice(identifier: ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "tvOS"))"
			default: return identifier
			}
			#endif
		}
		
		return mapToDevice(identifier: identifier)
	}()
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


extension UIImage {
	func maskWithColor(color: UIColor) -> UIImage? {
		let maskImage = cgImage!
		
		let width = size.width
		let height = size.height
		let bounds = CGRect(x: 0, y: 0, width: width, height: height)
		
		let colorSpace = CGColorSpaceCreateDeviceRGB()
		let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
		let context = CGContext(data: nil, width: Int(width), height: Int(height), bitsPerComponent: 8, bytesPerRow: 0, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)!
		
		context.clip(to: bounds, mask: maskImage)
		context.setFillColor(color.cgColor)
		context.fill(bounds)
		
		if let cgImage = context.makeImage() {
			let coloredImage = UIImage(cgImage: cgImage)
			return coloredImage
		} else {
			return nil
		}
	}
}


extension String {
	func capitalizeFirst() -> String {
		let firstIndex = self.index(startIndex, offsetBy: 1)
		return self.substring(to: firstIndex).capitalized + self.substring(from: firstIndex).lowercased()
	}
}
