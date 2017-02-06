//
//  FormDescriptor.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 20/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

open class FormDescriptor {

    // MARK: Properties
    
    open let title: String
    open var sections: [FormSectionDescriptor] = []
    
    // MARK: Init
    
    public init(title: String) {
        self.title = title
    }
    
    // MARK: Public
    
    open func addSection(_ section: FormSectionDescriptor) {
        sections.append(section)
    }
    
    open func removeSectionAtIndex(_ index: Int) throws {
        guard index >= 0 && index < sections.count - 1 else { throw FormErrorType.sectionOutOfIndex }
        sections.remove(at: index)
    }
    
    open func formValues() -> [String : AnyObject] {
        
        var formValues: [String : AnyObject] = [:]

        for section in sections {
            for row in section.rows {
                if row.rowType != .button {
                    if row.value != nil {
                        formValues[row.tag] = row.value!
                    }
                    else {
                        formValues[row.tag] = NSNull()
                    }
                }
            }
        }
        return formValues
    }
    
    open func validateForm() -> FormRowDescriptor? {
        for section in sections {
            for row in section.rows {
                if let required = row.configuration[FormRowDescriptor.Configuration.Required] as? Bool {
                    if required && row.value == nil {
                        return row
                    }
                }
            }
        }
        return nil
    }
}
