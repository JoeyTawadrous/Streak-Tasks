//
//  FormViewController.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuño on 20/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormViewController : UITableViewController {

    private static var __once: () = {
            Static.defaultCellClasses[FormRowType.text] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.label] = FormLabelCell.self
            Static.defaultCellClasses[FormRowType.number] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.numbersAndPunctuation] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.decimal] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.name] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.phone] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.url] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.twitter] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.namePhone] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.email] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.asciiCapable] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.password] = FormTextFieldCell.self
            Static.defaultCellClasses[FormRowType.button] = FormButtonCell.self
            Static.defaultCellClasses[FormRowType.booleanSwitch] = FormSwitchCell.self
            Static.defaultCellClasses[FormRowType.booleanCheck] = FormCheckCell.self
            Static.defaultCellClasses[FormRowType.segmentedControl] = FormSegmentedControlCell.self
            Static.defaultCellClasses[FormRowType.picker] = FormPickerCell.self
            Static.defaultCellClasses[FormRowType.date] = FormDateCell.self
            Static.defaultCellClasses[FormRowType.time] = FormDateCell.self
            Static.defaultCellClasses[FormRowType.dateAndTime] = FormDateCell.self
            Static.defaultCellClasses[FormRowType.stepper] = FormStepperCell.self
            Static.defaultCellClasses[FormRowType.slider] = FormSliderCell.self
            Static.defaultCellClasses[FormRowType.multipleSelector] = FormSelectorCell.self
            Static.defaultCellClasses[FormRowType.multilineText] = FormTextViewCell.self
        }()

    // MARK: Types
    
    fileprivate struct Static {
        static var onceDefaultCellClass: Int = 0
        static var defaultCellClasses: [FormRowType : FormBaseCell.Type] = [:]
    }
    
    // MARK: Properties
    
    open var form: FormDescriptor!
    
    // MARK: Init
    
    public convenience init() {
        self.init(style: .grouped)
    }
    
    public convenience init(form: FormDescriptor) {
        self.init()
        self.form = form
    }
    
    public override init(style: UITableViewStyle) {
        super.init(style: style)
    }
    
    public override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        baseInit()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        baseInit()
    }
    
    fileprivate func baseInit() {
    }
    
    // MARK: View life cycle

    open override func viewDidLoad() {
        super.viewDidLoad()
        assert(form != nil, "self.form property MUST be assigned!")
        navigationItem.title = form.title
    }
    
    // MARK: Public interface
    
    open func valueForTag(_ tag: String) -> NSObject! {
        for section in form.sections {
            for row in section.rows {
                if row.tag == tag {
                    return row.value
                }
            }
        }
        return nil
    }
    
    open func setValue(_ value: NSObject, forTag tag: String) {
        
        for (sectionIndex, section) in form.sections.enumerated() {
            for (rowIndex, row) in section.rows.enumerated() {
                if row.tag == tag {
                    form.sections[sectionIndex].rows[rowIndex].value = value
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: rowIndex, section: sectionIndex)) as? FormBaseCell {
                        cell.update()
                    }
                    return
                }
            }
        }
    }
    
    // MARK: UITableViewDataSource
    
    open override func numberOfSections(in tableView: UITableView) -> Int {
        return form.sections.count
    }
    
    open override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return form.sections[section].rows.count
    }
    
    open override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none // JOEY!
        let rowDescriptor = formRowDescriptorAtIndexPath(indexPath)
        
        let formBaseCellClass = formBaseCellClassFromRowDescriptor(rowDescriptor)
        
        let reuseIdentifier = NSStringFromClass(formBaseCellClass!)
        
        var cell: FormBaseCell? = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? FormBaseCell
        if cell == nil {
            
            cell = formBaseCellClass?.init(style: .default, reuseIdentifier: reuseIdentifier)
            cell?.formViewController = self
            cell?.configure()
        }
        
        cell?.rowDescriptor = rowDescriptor
        
        // apply cell custom design
        if let cellConfiguration = rowDescriptor.configuration[FormRowDescriptor.Configuration.CellConfiguration] as? NSDictionary {
            for (keyPath, value) in cellConfiguration {
                cell?.setValue(value, forKeyPath: keyPath as! String)
            }
        }
        return cell!
    }
    
    open override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return form.sections[section].headerTitle
    }
    
    open override func tableView(_ tableView: UITableView, titleForFooterInSection section: Int) -> String? {
        return form.sections[section].footerTitle
    }
    
    // MARK: UITableViewDelegate
    
    open override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {

        let rowDescriptor = formRowDescriptorAtIndexPath(indexPath)
        
        if let formBaseCellClass = formBaseCellClassFromRowDescriptor(rowDescriptor) {
            return formBaseCellClass.formRowCellHeight()
        }
        return super.tableView(tableView, heightForRowAt: indexPath)
    }
    
    open override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        let rowDescriptor = formRowDescriptorAtIndexPath(indexPath)
        
        if let selectedRow = tableView.cellForRow(at: indexPath) as? FormBaseCell {
            if let formBaseCellClass = formBaseCellClassFromRowDescriptor(rowDescriptor) {
                formBaseCellClass.formViewController(self, didSelectRow: selectedRow)
            }
        }
        
        if let didSelectClosure = rowDescriptor.configuration[FormRowDescriptor.Configuration.DidSelectClosure] as? DidSelectClosure {
            didSelectClosure()
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    fileprivate class func defaultCellClassForRowType(_ rowType: FormRowType) -> FormBaseCell.Type {
        _ = FormViewController.__once
        return Static.defaultCellClasses[rowType]!
    }
    
    fileprivate func formRowDescriptorAtIndexPath(_ indexPath: IndexPath!) -> FormRowDescriptor {
        let section = form.sections[indexPath.section]
        let rowDescriptor = section.rows[indexPath.row]
        return rowDescriptor
    }
    
    fileprivate func formBaseCellClassFromRowDescriptor(_ rowDescriptor: FormRowDescriptor) -> FormBaseCell.Type! {
        
        var formBaseCellClass: FormBaseCell.Type!
        
        if let cellClass: AnyClass = rowDescriptor.configuration[FormRowDescriptor.Configuration.CellClass] as? AnyClass {
            formBaseCellClass = cellClass as? FormBaseCell.Type
        }
        else {
            formBaseCellClass = FormViewController.defaultCellClassForRowType(rowDescriptor.rowType)
        }
        
        assert(formBaseCellClass != nil, "FormRowDescriptor.Configuration.CellClass must be a FormBaseCell derived class value.")
        
        return formBaseCellClass
    }
}
