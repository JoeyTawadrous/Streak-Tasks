import UIKit


open class RoundedButton: UIButton {
	override open func layoutSubviews() {
		super.layoutSubviews()
		
		self.layer.cornerRadius = 5
	}
}
