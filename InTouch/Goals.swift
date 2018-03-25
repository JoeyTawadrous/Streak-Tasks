import UIKit
import CoreData
import SCLAlertView
import FontAwesome_swift

class Goals: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    struct ClassConstants {
        static let ADD_PERSON_TITLE = "Add A New Goal"
        static let ADD_PERSON_MESSAGE = "that you will achieve...";
        static let ADD_PERSON_NAME = "Enter Goal Name";
	}
	
	@IBOutlet var tableView: UITableView!
	@IBOutlet var addButton: UIBarButtonItem!
	@IBOutlet var menuButton: UIBarButtonItem!
	
    var people = [AnyObject]()
	
	
	
	/* MARK: Init
	/////////////////////////////////////////// */
	override func viewDidLoad() {
		Utils.insertGradientIntoView(viewController: self)
		Utils.insertGradientIntoTableView(viewController: self, tableView: tableView)
	}
	
    override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		
		people = Utils.fetchCoreDataObject(Constants.CoreData.PERSON, predicate: "")
		people = people.reversed() // newest first
		tableView.reloadData()
		
		// Styling
		tableView.separatorStyle = UITableViewCellSeparatorStyle.none
		
		// Nav bar
		var attributes = [NSAttributedStringKey : Any]()
		attributes = [.font: UIFont.fontAwesome(ofSize: 21)]
		addButton.setTitleTextAttributes(attributes, for: .normal)
		addButton.setTitleTextAttributes(attributes, for: .selected)
		addButton.title = String.fontAwesomeIcon(name: .plus)
		menuButton.setTitleTextAttributes(attributes, for: .normal)
		menuButton.setTitleTextAttributes(attributes, for: .selected)
		menuButton.title = String.fontAwesomeIcon(name: .bars)
    }
	
	override var prefersStatusBarHidden: Bool {
		return true
	}
	
	
    
	/* MARK: Button Actions
	/////////////////////////////////////////// */
    @IBAction func addPerson(_ sender: AnyObject) {
        let alert = SCLAlertView()
        let textField = alert.addTextField(ClassConstants.ADD_PERSON_NAME)
        alert.addButton(Constants.Common.SUBMIT) {
            if !textField.text!.isEmpty {
                self.savePerson(textField.text!, thumbnail: Utils.getRandomImageString())
                self.tableView.reloadData()
            }
        }
        alert.showEdit(ClassConstants.ADD_PERSON_TITLE, subTitle:ClassConstants.ADD_PERSON_MESSAGE)
	}
	
	@IBAction func menuButtonPressed(_ sender: AnyObject) {
		let storyBoard : UIStoryboard = UIStoryboard(name: Constants.Common.MAIN_STORYBOARD, bundle:nil)
		let settingsView = storyBoard.instantiateViewController(withIdentifier: Constants.Classes.SETTINGS) as! Settings
		self.show(settingsView as UIViewController, sender: settingsView)
	}
	
	
	
	/* MARK: Core Functionality
	/////////////////////////////////////////// */
	func savePerson(_ name: String, thumbnail: String) {
		let person = Utils.createObject(Constants.CoreData.PERSON)
		
		person.setValue(name, forKey: Constants.CoreData.NAME)
		person.setValue(thumbnail, forKey: Constants.CoreData.THUMBNAIL)
		Utils.saveObject()
		
		people.insert(person, at: 0)
		
		tableView.backgroundColor = Utils.getNextTableColour(people.count, reverse: false)
	}
	
	
	
	/* MARK: Table Functionality
	/////////////////////////////////////////// */
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: PeopleTableViewCell! = tableView.dequeueReusableCell(withIdentifier: Constants.Common.CELL) as? PeopleTableViewCell
        if cell == nil {
            cell = PeopleTableViewCell(style: UITableViewCellStyle.value1, reuseIdentifier: Constants.Common.CELL)
        }
        let person = people[indexPath.row]
		
		
		// Style
		cell!.selectionStyle = .none
		
        
        let name = person.value(forKey: Constants.CoreData.NAME) as! String?
        cell.personLabel!.text = name
        
        
        let catchUps = Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: name!)
        let catchUpsCount: Int = catchUps.count
        cell.catchUpCountLabel!.text = String(catchUpsCount)
        
        
        let thumbnail = person.value(forKey: Constants.CoreData.THUMBNAIL) as! String?
        cell.thumbnailImageView!.image = UIImage(named: thumbnail!)
        cell.thumbnailImageView!.image = cell.thumbnailImageView!.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.thumbnailImageView!.tintColor = UIColor.white
        
        cell.outerCircleImageView!.image = UIImage(named: "circle.png")
        cell.outerCircleImageView!.image = cell.outerCircleImageView!.image!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        cell.outerCircleImageView!.tintColor = UIColor.white
		
        cell.updateConstraints()

        return cell
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if(editingStyle == UITableViewCellEditingStyle.delete) {
            
            // Delete catchUps associated with this person
            let catchUps = Utils.fetchCoreDataObject(Constants.CoreData.CATCHUP, predicate: "")
            let person = people[indexPath.row]
            let selectedPerson = person.value(forKey: Constants.CoreData.NAME) as! String?
            
            for catchUp in catchUps {
                if (selectedPerson == catchUp.name) {
                    Tasks.deleteCatchUp(catchUp as! NSManagedObject)
                }
            }
            
            
            // Now delete person
            let personToDelete = people[indexPath.row]
            
            let managedObjectContect = Utils.fetchManagedObjectContext()
            managedObjectContect.delete(personToDelete as! NSManagedObject)
            
            do {
                try managedObjectContect.save()
            } catch {
                print(error)
            }
            
            people = Utils.fetchCoreDataObject(Constants.CoreData.PERSON, predicate: "")
            people = people.reversed() // newest first
            
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.backgroundColor = Utils.getNextTableColour(people.count, reverse: false)
        }
        
        tableView.reloadData()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get selected person's name
        let cell = tableView.cellForRow(at: indexPath) as! PeopleTableViewCell
        let selectedPerson = cell.personLabel!.text
        
        // Set person's name in NSUserDefaults (so we can attach catch ups to it later)
        let defaults = UserDefaults.standard
        defaults.set(selectedPerson, forKey: Constants.LocalData.SELECTED_PERSON)
        defaults.set(indexPath.row, forKey: Constants.LocalData.SELECTED_PERSON_INDEX)
        
        // Show CatchUps view
        let storyBoard : UIStoryboard = UIStoryboard(name: Constants.Common.MAIN_STORYBOARD, bundle:nil)
        let catchUpsView = storyBoard.instantiateViewController(withIdentifier: Constants.Classes.CATCH_UPS) as! Tasks
        self.show(catchUpsView as UIViewController, sender: catchUpsView)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 74.0
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		if people.count == 0 {
			let emptyView = UIView(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width, height:self.view.bounds.size.height))
			
			let emptyImageView = UIImageView(frame: CGRect(x:0, y:0, width:150, height:150))
			emptyImageView.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.30)
			let emptyImage = Utils.imageResize(UIImage(named: "Custom")!, sizeChange: CGSize(width: 150, height: 150)).withRenderingMode(UIImageRenderingMode.alwaysTemplate)
			emptyImageView.image = emptyImage
			emptyImageView.tintColor = UIColor.white
			emptyView.addSubview(emptyImageView)
			
			let emptyLabel = UILabel(frame: CGRect(x:0, y:0, width:self.view.bounds.size.width - 100, height:self.view.bounds.size.height))
			emptyLabel.center = CGPoint(x:self.view.frame.width / 2, y: self.view.bounds.size.height * 0.53)
			emptyLabel.text = "Do you like cooking? Perhaps you're more fitness oriented? Or maybe you'd like more family time? Create a goal now!"
			emptyLabel.font = UIFont.GothamProRegular(size: 15.0)
			emptyLabel.textAlignment = NSTextAlignment.center
			emptyLabel.textColor = UIColor.white
			emptyLabel.numberOfLines = 5
			emptyView.addSubview(emptyLabel)
			
			self.tableView.backgroundView = emptyView
			
			return 0
		}
		else {
			return people.count
		}
    }
}


class PeopleTableViewCell : UITableViewCell {
    @IBOutlet var personLabel: UILabel?
    @IBOutlet var catchUpCountLabel: UILabel?
    @IBOutlet var thumbnailImageView: UIImageView?
    @IBOutlet var outerCircleImageView: UIImageView?
}
