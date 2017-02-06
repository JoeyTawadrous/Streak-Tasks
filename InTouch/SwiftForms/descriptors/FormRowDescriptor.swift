//
//  FormRowDescriptor.swift
//  SwiftForms
//
//  Created by Miguel Angel Ortuno on 20/08/14.
//  Copyright (c) 2014 Miguel Angel Ortuño. All rights reserved.
//

import UIKit

public enum FormRowType {
    case unknown
    case label
    case text
    case url
    case number
    case numbersAndPunctuation
    case decimal
    case name
    case phone
    case namePhone
    case email
    case twitter
    case asciiCapable
    case password
    case button
    case booleanSwitch
    case booleanCheck
    case segmentedControl
    case picker
    case date
    case time
    case dateAndTime
    case stepper
    case slider
    case multipleSelector
    case multilineText
}

public typealias DidSelectClosure = (Void) -> Void
public typealias UpdateClosure = (FormRowDescriptor) -> Void
public typealias TitleFormatterClosure = (NSObject) -> String!
public typealias VisualConstraintsClosure = (FormBaseCell) -> NSArray

open class FormRowDescriptor {

    // MARK: Types

    public struct Configuration {
        public static let Required = "FormRowDescriptorConfigurationRequired"

        public static let CellClass = "FormRowDescriptorConfigurationCellClass"
        public static let CheckmarkAccessoryView = "FormRowDescriptorConfigurationCheckmarkAccessoryView"
        public static let CellConfiguration = "FormRowDescriptorConfigurationCellConfiguration"

        public static let Placeholder = "FormRowDescriptorConfigurationPlaceholder"

        public static let WillUpdateClosure = "FormRowDescriptorConfigurationWillUpdateClosure"
        public static let DidUpdateClosure = "FormRowDescriptorConfigurationDidUpdateClosure"

        public static let MaximumValue = "FormRowDescriptorConfigurationMaximumValue"
        public static let MinimumValue = "FormRowDescriptorConfigurationMinimumValue"
        public static let Steps = "FormRowDescriptorConfigurationSteps"

        public static let Continuous = "FormRowDescriptorConfigurationContinuous"

        public static let DidSelectClosure = "FormRowDescriptorConfigurationDidSelectClosure"

        public static let VisualConstraintsClosure = "FormRowDescriptorConfigurationVisualConstraintsClosure"

        public static let Options = "FormRowDescriptorConfigurationOptions"

        public static let TitleFormatterClosure = "FormRowDescriptorConfigurationTitleFormatterClosure"

        public static let SelectorControllerClass = "FormRowDescriptorConfigurationSelectorControllerClass"

        public static let AllowsMultipleSelection = "FormRowDescriptorConfigurationAllowsMultipleSelection"

        public static let ShowsInputToolbar = "FormRowDescriptorConfigurationShowsInputToolbar"

        public static let DateFormatter = "FormRowDescriptorConfigurationDateFormatter"
    }

    // MARK: Properties

    open let tag: String
    open let title: String?
    open let rowType: FormRowType

    open var value: NSObject? {
        willSet {
            guard let willUpdateBlock = self.configuration[Configuration.WillUpdateClosure] as? UpdateClosure else { return }
            willUpdateBlock(self)
        }
        didSet {
            guard let didUpdateBlock = self.configuration[Configuration.DidUpdateClosure] as? UpdateClosure else { return }
            didUpdateBlock(self)
        }
    }

    open var configuration: [String : Any] = [:]

    // MARK: Init

    public init(tag: String, rowType: FormRowType, title: String, placeholder: String? = nil) {
        self.tag = tag
        self.rowType = rowType
        self.title = title

        if placeholder != nil {
            configuration[FormRowDescriptor.Configuration.Placeholder] = placeholder!
        }

        configuration[Configuration.Required] = true
        configuration[Configuration.AllowsMultipleSelection] = false
        configuration[Configuration.ShowsInputToolbar] = false
    }

    // MARK: Public interface

    open func titleForOptionAtIndex(_ index: Int) -> String? {
        if let options = configuration[FormRowDescriptor.Configuration.Options] as? NSArray {
            return titleForOptionValue(options[index] as! NSObject)
        }
        return nil
    }

    open func titleForOptionValue(_ optionValue: NSObject) -> String {
        if let titleFormatter = configuration[FormRowDescriptor.Configuration.TitleFormatterClosure] as? TitleFormatterClosure {
            return titleFormatter(optionValue)
        }
        return "\(optionValue)"
    }
}
