import UIKit
import KYCircularProgress


class Achievements: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
	
	@IBOutlet var collectionView: UICollectionView!
	@IBOutlet var topView: UIView?
	@IBOutlet var backButton: UIBarButtonItem!
	@IBOutlet var infoButton: UIBarButtonItem!
    @IBOutlet weak var collectionViewTopSpace: NSLayoutConstraint!
    
    
	// Points
	private var levelsLabel: UILabel?
	private var pointsLabel: UILabel?
	private var circularPointsView: KYCircularProgress!
	private var circularPointsValue: Double = 0.0
	private var circlePoints: Double = 0.0
	
	
	
	/* MARK: Initialising
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		// Refresh here once so the user is not waiting (as they would be in viewDidAppear)
        
        if UIDevice.current.userInterfaceIdiom == .pad{
            self.collectionViewTopSpace.constant = 100
        }
        
        
		collectionView.reloadData()
		Utils.createFontAwesomeBarButton(button: backButton, icon: .arrowLeft, style: .solid)
		Utils.createFontAwesomeBarButton(button: infoButton, icon: .info, style: .solid)
	}
	
	override func viewDidAppear(_ animated: Bool) {
		// User may have achieved something since last visit!
		collectionView.reloadData()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		// Styling
		Utils.insertGradientIntoView(viewController: self)
	}
	
	override func viewWillLayoutSubviews() {
		// Remove all previous views from topView
		// Needed for orientation changes
		for subview in topView!.subviews {
			subview.removeFromSuperview()
		}
		
		// Reset progress values (needed for orientation changes)
		circularPointsValue = 0.0
		
		initPointsView()
	}
	
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Actions
	/////////////////////////////////////////// */
	@IBAction func backButtonPressed() {
		Utils.presentView(self, viewName: Constants.Views.GOALS_NAV_CONTROLLER)
	}
	
	@IBAction func infoButtonPressed() {
		Dialogs.showInfoDialog(title: Constants.Strings.ACHIEVEMENTS_INFO_DIALOG_TITLE, subTitle: Constants.Strings.ACHIEVEMENTS_INFO_DIALOG_SUBTITLE)
	}
	
	
	
	/* MARK: Points Functionality
	/////////////////////////////////////////// */
	func initPointsView() {
		let xValue:CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 55 : 90
		circularPointsView = createProgressCircle(x: (UIScreen.main.bounds.width / 2) - xValue, color: "f6d365")
		
		topView?.addSubview(circularPointsView)
		
		levelsLabel = createProgressLabel(center: circularPointsView.center)
		topView?.addSubview(levelsLabel!)
		
		pointsLabel = createProgressLabel(center: CGPoint(x: circularPointsView.center.x, y: circularPointsView.bounds.height + 19))
		topView?.addSubview(pointsLabel!)
		
		if Utils.bool(key: "FASTLANE_SNAPSHOT") {
			levelsLabel?.text = "Level 5"
			pointsLabel?.text = "Total Points: 78"
			circlePoints = 80.0
		}
		else {
			calculatePointsAndLevel()
		}
		
		// Set points circle load speed relative to total points
		if(circlePoints < 0.3) {
			Timer.scheduledTimer(timeInterval: 0.010, target: self, selector: #selector(updatePoints), userInfo: nil, repeats: true)
		}
		else if(circlePoints > 0.3 && circlePoints < 0.7) {
			Timer.scheduledTimer(timeInterval: 0.005, target: self, selector: #selector(updatePoints), userInfo: nil, repeats: true)
		}
		else {
			Timer.scheduledTimer(timeInterval: 0.0025, target: self, selector: #selector(updatePoints), userInfo: nil, repeats: true)
		}
	}
	
	func calculatePointsAndLevel() {
		let points = Utils.int(key: Constants.Defaults.APP_DATA_TOTAL_POINTS)
		levelsLabel?.text = Constants.Strings.LEVEL + String(ProgressManager.getLevel(points: points))
		pointsLabel?.text = Constants.Strings.POINTS_CIRCULAR_VIEW_DESCRIPTION_LABEL + String(points)
		circlePoints = ProgressManager.getLevelProgress(points: points)
	}
	
	@objc private func updatePoints() {
		if(circularPointsValue <= circlePoints) {
			circularPointsValue = circularPointsValue + 0.001
			circularPointsView.progress = circularPointsValue
		}
	}
	
	
	
	/* MARK: Points UI
	/////////////////////////////////////////// */
	func createProgressLabel(center: CGPoint) -> UILabel {
		let label = UILabel(frame: CGRect(x: 0, y: 0, width: 140, height: 20))
		label.center = center
		label.textColor = UIColor(hex: "fff")
		label.textAlignment = .center
		label.font = UIFont.GothamProMedium(size: 15.0)
		return label
	}
	
	func createProgressCircle(x: CGFloat, color: String) -> KYCircularProgress {
		let heightWidth:CGFloat = UIDevice.current.userInterfaceIdiom == .phone ? 110 : 180
		let progressView = KYCircularProgress(frame: CGRect(x: x, y: 5, width: heightWidth, height: heightWidth), showGuide: true)
		return Utils.createProgressView(progressView: progressView, color: color, guideColor: "fff")
	}
	
	
	
	/* MARK: Collection View
	/////////////////////////////////////////// */
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return Constants.Achievements.ACHIEVEMENTS_ALL.count
	}
	
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "achievementCollectionViewCell", for: indexPath) as! AchievementCollectionViewCell
		
		let achievement = Constants.Achievements.ACHIEVEMENTS_ALL[indexPath.row] as [String]
		let image = UIImage(named: achievement[2])
		
		cell.titleLabel.text = achievement[3]
		
		if Utils.bool(key: "FASTLANE_SNAPSHOT") {
			cell.iconImageView.image = image
			Utils.createHexagonImageView(imageView: cell.containerImageView, lineWidth: 5, lineColor: UIColor(hex: "fff"))
		}
		else {
			if !ProgressManager.isAchievementReached(name: achievement[0]) {
				let color =  UIColor(hex: "fff")
				cell.iconImageView.image = image?.maskWithColor(color: color)
				cell.titleLabel.textColor = color
				Utils.createHexagonImageView(imageView: cell.containerImageView, lineWidth: 5, lineColor: color)
			}
			else {
				cell.iconImageView.image = image
				cell.titleLabel.textColor = UIColor(hex: "fff")
				Utils.createHexagonImageView(imageView: cell.containerImageView, lineWidth: 5, lineColor: UIColor(hex: "fff"))
			}
		}
		
		return cell
	}
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let achievement = Constants.Achievements.ACHIEVEMENTS_ALL[indexPath.row] as [String]
		let achievementReached = ProgressManager.isAchievementReached(name: achievement[0])
		Dialogs.showAchievementDialog(view: self, reached: achievementReached, achievement: achievement)
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
		let width = UIDevice.current.userInterfaceIdiom == .phone ? collectionView.bounds.width / 3.0 : collectionView.bounds.width / 5.0
		return CGSize(width: width, height: width + 20)
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
		return UIEdgeInsets.zero
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
	
	
	func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
		return 0
	}
}



class AchievementCollectionViewCell: UICollectionViewCell {
	@IBOutlet var containerImageView: UIImageView!
	@IBOutlet var iconImageView: UIImageView!
	@IBOutlet var titleLabel: UILabel!
}
