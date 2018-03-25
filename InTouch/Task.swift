import CoreData
import UIKit

class Task: UIViewController {
    
    @IBOutlet var titleButton: UIBarButtonItem?
    @IBOutlet var reasonLabel: UILabel?
    @IBOutlet var personThumbnail: UIImageView?
    @IBOutlet var dateLabel: UILabel?
    @IBOutlet var timeLabel: UILabel?
    @IBOutlet var typeLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
    @IBOutlet var markDoneButton: UIButton?
    
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		Utils.insertGradientIntoView(viewController: self)
	}
	
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
		
		// Styling
		let borderWidth = CGFloat(3.5)
		
		
		// Init
        let defaults = UserDefaults.standard
        var people = Utils.fetchCoreDataObject(Constants.CoreData.PERSON, predicate: "")
        people = people.reversed()
		
        let selectedPerson = defaults.string(forKey: Constants.LocalData.SELECTED_PERSON)!
        let selectedPersonIndex = defaults.integer(forKey: Constants.LocalData.SELECTED_PERSON_INDEX)
        let selectedCatchUpIndex = defaults.integer(forKey: Constants.LocalData.SELECTED_CATCHUP_INDEX)
        var catchUps = Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: selectedPerson)
        catchUps = catchUps.reversed()
        
        
        // Reason label
        reasonLabel?.text = catchUps[selectedCatchUpIndex].value(forKey: Constants.CoreData.REASON) as! String?
        reasonLabel!.layer.borderWidth = borderWidth
        reasonLabel!.layer.borderColor = UIColor.white.cgColor
		reasonLabel!.backgroundColor = Utils.getNextTableColour(selectedCatchUpIndex + 1, reverse: false)
        
        
        // Person thumbnail
        let thumbnailFile = people[selectedPersonIndex].value(forKey: Constants.CoreData.THUMBNAIL) as! String?
        personThumbnail!.image = UIImage(named: thumbnailFile!)
        personThumbnail!.image! = Utils.imageResize(personThumbnail!.image!, sizeChange: CGSize(width: 45, height: 45)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        personThumbnail!.tintColor = UIColor.white
        personThumbnail!.layer.borderWidth = borderWidth;
		personThumbnail!.layer.borderColor = UIColor.white.cgColor
		personThumbnail!.backgroundColor = Utils.getNextTableColour(selectedCatchUpIndex + 2, reverse: false)
		
        
        // Date label
        let when = catchUps[selectedCatchUpIndex].value(forKey: Constants.CoreData.WHEN) as! Date?
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = Constants.LocalData.DATE_FORMAT
        let formattedWhen = dateFormatter.string(from: when!)
        let whenArray = formattedWhen.characters.split{$0 == ","}.map(String.init)
        dateLabel?.text = Utils.getDayOfWeek(formattedWhen)! + ", " + whenArray[1]
        dateLabel!.layer.borderWidth = borderWidth;
		dateLabel!.layer.borderColor = UIColor.white.cgColor
		dateLabel!.backgroundColor = Utils.getNextTableColour(selectedCatchUpIndex + 3, reverse: false)
		
        
        // Time label
        timeLabel?.text = whenArray[0]
        timeLabel!.layer.borderWidth = borderWidth;
		timeLabel!.layer.borderColor = UIColor.white.cgColor
		timeLabel!.backgroundColor = Utils.getNextTableColour(selectedCatchUpIndex + 4, reverse: false)
		
        
        // Type label
        let type = catchUps[selectedCatchUpIndex].value(forKey: Constants.CoreData.TYPE) as! String?
        typeLabel?.text = type!.uppercased()
        typeLabel!.layer.borderWidth = borderWidth;
		typeLabel!.layer.borderColor = UIColor.white.cgColor
		typeLabel!.backgroundColor = Utils.getNextTableColour(selectedCatchUpIndex + 3, reverse: false)
		
        
        // Type thumbnail
		thumbnailImageView!.image = UIImage(named: type!)
        thumbnailImageView!.image! = Utils.imageResize(thumbnailImageView!.image!, sizeChange: CGSize(width: 40, height: 40)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        thumbnailImageView!.tintColor = UIColor.white
        thumbnailImageView!.layer.borderWidth = borderWidth;
		thumbnailImageView!.layer.borderColor = UIColor.white.cgColor
		thumbnailImageView!.backgroundColor = Utils.getNextTableColour(selectedCatchUpIndex + 7, reverse: false)
		
        
        // Title bar button
        titleButton?.title = Utils.getDayOfWeek(formattedWhen)! + ", " + whenArray[1] + " @ " + whenArray[0]
		
		
        // Complete button
        markDoneButton!.layer.cornerRadius = 3
        markDoneButton!.setTitleColor(UIColor.white, for: UIControlState())
		markDoneButton!.backgroundColor = Utils.getNextTableColour(selectedCatchUpIndex + 6, reverse: false)
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
	
	/* MARK: Button Actions
	/////////////////////////////////////////// */
    @IBAction func markDoneButtonTapped(_ sender : UIButton!) {
        sender.isEnabled = false
		
        let defaults = UserDefaults.standard
        let selectedPerson = defaults.string(forKey: Constants.LocalData.SELECTED_PERSON)!
        let selectedCatchUpIndex = defaults.integer(forKey: Constants.LocalData.SELECTED_CATCHUP_INDEX)
        var catchUps = Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: selectedPerson)
        let catchUp = catchUps[selectedCatchUpIndex] as! NSManagedObject
        Tasks.deleteCatchUp(catchUp)
		
        navigationController?.popViewController(animated: true)
    }
}
