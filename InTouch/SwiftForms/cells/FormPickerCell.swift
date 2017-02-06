//
//  FormPickerCell.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 22/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormPickerCell: FormValueCell, UIPickerViewDelegate, UIPickerViewDataSource {
    
    // MARK: Properties
    
    fileprivate let picker = UIPickerView()
    fileprivate let hiddenTextField = UITextField(frame: CGRect.zero)
    
    // MARK: FormBaseCell
    
    open override func configure() {
        super.configure()
        accessoryType = .none
        
        picker.delegate = self
        picker.dataSource = self
        hiddenTextField.inputView = picker
        
        contentView.addSubview(hiddenTextField)
    }
    
    open override func update() {
        super.update()
        
        titleLabel.text = rowDescriptor.title
        
        if let value = rowDescriptor.value {
            valueLabel.text = rowDescriptor.titleForOptionValue(value)
            if let options = rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray {
                let index = options.index(of: value)
                if index != NSNotFound {
                    picker.selectRow(index, inComponent: 0, animated: false)
                }
            }
        }
    }
    
    open override class func formViewController(_ formViewController: FormViewController, didSelectRow selectedRow: FormBaseCell) {
        
        if selectedRow.rowDescriptor.value == nil {
            if let row = selectedRow as? FormPickerCell {
                let options = selectedRow.rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray
                let optionValue = options?[0] as? NSObject
                selectedRow.rowDescriptor.value = optionValue
                row.valueLabel.text = selectedRow.rowDescriptor.titleForOptionValue(optionValue!)
                row.hiddenTextField.becomeFirstResponder()
                row.valueLabel.textColor = UIColor.white
            }
        } else {
			if let row = selectedRow as? FormPickerCell {
                guard let optionValue = selectedRow.rowDescriptor.value else { return }
                row.valueLabel.text = selectedRow.rowDescriptor.titleForOptionValue(optionValue)
                row.hiddenTextField.becomeFirstResponder()
                row.valueLabel.textColor = UIColor.white
            }
		}
    }
    
    // MARK: UIPickerViewDelegate
    
    open func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return rowDescriptor.titleForOptionAtIndex(row)
    }
    
    open func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let options = rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray
        let optionValue = options?[row] as? NSObject
        rowDescriptor.value = optionValue
        valueLabel.text = rowDescriptor.titleForOptionValue(optionValue!)
    }
    
    // MARK: UIPickerViewDataSource
    
    open func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    open func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if let options = rowDescriptor.configuration[FormRowDescriptor.Configuration.Options] as? NSArray {
            return options.count
        }
        return 0
    }
}
