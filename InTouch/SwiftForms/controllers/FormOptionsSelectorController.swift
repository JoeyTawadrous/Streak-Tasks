//
//  FormOptionsSelectorController.swift
//  SwiftForms
//
//  Created by Miguel Ángel Ortuño Ortuño on 23/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormOptionsSelectorController: UITableViewController, FormSelector {

    // MARK: FormSelector
    
    open var formCell: FormBaseCell!
    
    // MARK: Init
    
    public init() {
        super.init(style: .grouped)
    }

    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.title = formCell.rowDescriptor.title
    }
    
    // MARK: UITableViewDataSource

    open override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let options = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray {
            return options.count
        }
        return 0
    }
    
    open override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let reuseIdentifier = NSStringFromClass(type(of: self))
        
        var cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
        if cell == nil {
            cell = UITableViewCell(style: .default, reuseIdentifier: reuseIdentifier)
        }
        
        let options = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as! NSArray
        let optionValue = options[indexPath.row] as! NSObject
        
        cell!.textLabel!.text = formCell.rowDescriptor.titleForOptionValue(optionValue)
        
        if let selectedOptions = formCell.rowDescriptor.value as? [NSObject] {
            if (selectedOptions.index(of: optionValue as NSObject) != nil) {
                
                if let checkMarkAccessoryView = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.CheckmarkAccessoryView] as? UIView {
                    cell!.accessoryView = checkMarkAccessoryView
                }
                else {
                    cell!.accessoryType = .checkmark
                }
            }
            else {
                cell!.accessoryType = .none
            }
        }
        else if let selectedOption = formCell.rowDescriptor.value {
            if optionValue == selectedOption {
                cell!.accessoryType = .checkmark
            }
            else {
                cell!.accessoryType = .none
            }
        }
        return cell!
    }
    
    // MARK: UITableViewDelegate
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let cell = tableView.cellForRow(at: indexPath)
        
        var allowsMultipleSelection = false
        if let allowsMultipleSelectionValue = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.AllowsMultipleSelection] as? Bool {
            allowsMultipleSelection = allowsMultipleSelectionValue
        }
        
        let options = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as! NSArray
        let optionValue = options[indexPath.row] as! NSObject
        
        if allowsMultipleSelection {
            
            if formCell.rowDescriptor.value == nil {
                formCell.rowDescriptor.value = NSMutableArray()
            }
                        
            if let selectedOptions = formCell.rowDescriptor.value as? NSMutableArray {
                
                if selectedOptions.contains(optionValue) {
                    selectedOptions.remove(optionValue)
                    cell?.accessoryType = .none
                }
                else {
                    selectedOptions.add(optionValue)
                    
                    if let checkmarkAccessoryView = formCell.rowDescriptor.configuration[FormRowDescriptor.Configuration.CheckmarkAccessoryView] as? UIView {
                        cell?.accessoryView = checkmarkAccessoryView
                    }
                    else {
                        cell?.accessoryType = .checkmark
                    }
                }
                
                if selectedOptions.count > 0 {
                    formCell.rowDescriptor.value = selectedOptions
                }
                else {
                    formCell.rowDescriptor.value = nil
                }
            }
        }
        else {
            formCell.rowDescriptor.value = NSMutableArray(object: optionValue)
        }
        
        formCell.update()
        
        if allowsMultipleSelection {
            tableView.deselectRow(at: indexPath, animated: true)
        }
        else {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
