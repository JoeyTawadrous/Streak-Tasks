//
//  FormDateCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 22/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormDateCell: FormValueCell {

    // MARK: Properties
    
    fileprivate let datePicker = UIDatePicker()
    fileprivate let hiddenTextField = UITextField(frame: CGRect.zero)
    fileprivate let defaultDateFormatter = DateFormatter()
    
    // MARK: FormBaseCell
    
    open override func configure() {
        super.configure()
        contentView.addSubview(hiddenTextField)
        hiddenTextField.inputView = datePicker
        datePicker.datePickerMode = .date
        datePicker.addTarget(self, action: #selector(FormDateCell.valueChanged(_:)), for: .valueChanged)
    }
    
    open override func update() {
        super.update()
        
        if let showsInputToolbar = rowDescriptor.configuration[FormRowDescriptor.Configuration.ShowsInputToolbar] as? Bool {
            if showsInputToolbar && hiddenTextField.inputAccessoryView == nil {
                hiddenTextField.inputAccessoryView = inputAccesoryView()
            }
        }
        
        titleLabel.text = rowDescriptor.title
        titleLabel.textColor = UIColor.white
        
        switch rowDescriptor.rowType {
        case .date:
            datePicker.datePickerMode = .date
            defaultDateFormatter.dateStyle = .long
            defaultDateFormatter.timeStyle = .none
        case .time:
            datePicker.datePickerMode = .time
            defaultDateFormatter.dateStyle = .none
            defaultDateFormatter.timeStyle = .short
        default:
            datePicker.datePickerMode = .dateAndTime
            defaultDateFormatter.dateStyle = .long
            defaultDateFormatter.timeStyle = .short
        }
        
        if rowDescriptor.value != nil {
            let date = rowDescriptor.value as? Date
            datePicker.date = date!
            valueLabel.text = self.getDateFormatter().string(from: date!)
        }
    }
    
    open override class func formViewController(_ formViewController: FormViewController, didSelectRow selectedRow: FormBaseCell) {
        
        let row: FormDateCell! = selectedRow as? FormDateCell
        
        if row.rowDescriptor.value == nil {
            let date = Date()
            row.rowDescriptor.value = date as NSObject?
            row.valueLabel.text = row.getDateFormatter().string(from: date)
            row.update()
        }
        
        row.hiddenTextField.becomeFirstResponder()
    }
    
    open override func firstResponderElement() -> UIResponder? {
        return hiddenTextField
    }
    
    open override class func formRowCanBecomeFirstResponder() -> Bool {
        return true
    }
    
    // MARK: Actions
    
    internal func valueChanged(_ sender: UIDatePicker) {
        rowDescriptor.value = sender.date as NSObject?
        valueLabel.text = getDateFormatter().string(from: sender.date)
        update()
    }
    
    // MARK: Private interface
    
    fileprivate func getDateFormatter() -> DateFormatter {
        
        if let dateFormatter = self.rowDescriptor.configuration[FormRowDescriptor.Configuration.DateFormatter] as? DateFormatter {
            return dateFormatter
        }
        return defaultDateFormatter
    }
}
