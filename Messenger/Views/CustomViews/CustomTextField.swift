//
//  CustomTextField.swift
//  Messenger
//
//  Created by Employee1 on 5/26/20.
//  Copyright © 2020 Employee1. All rights reserved.
//

import UIKit

protocol CustomTextFieldDelegate: class {
    func texfFieldDidChange(placeholder: String)
}

class CustomTextField: UIView {
    
    var errorText = ""
    var successText = ""
    let textField = UITextField()
    let topLabel = UILabel()
    let errorLabel = UILabel()
    let border = UIView()
    let height = CGFloat(1.0)
    weak var delagate: CustomTextFieldDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        textField.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: textField, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
               self.addConstraint(NSLayoutConstraint(item: textField, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
               self.addConstraint(NSLayoutConstraint(item: textField, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 35))
               self.addConstraint(NSLayoutConstraint(item: textField, attribute: .top, relatedBy: .equal, toItem: self, attribute: .top, multiplier: 1, constant: 10))
               self.addSubview(self.textField)
        border.translatesAutoresizingMaskIntoConstraints = false
        self.addConstraint(NSLayoutConstraint(item: border, attribute: .leading, relatedBy: .equal, toItem: self, attribute: .leading, multiplier: 1, constant: 0))
               self.addConstraint(NSLayoutConstraint(item: border, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0))
               self.addConstraint(NSLayoutConstraint(item: border, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1, constant: 1))
               self.addConstraint(NSLayoutConstraint(item: border, attribute: .top, relatedBy: .equal, toItem: textField, attribute: .bottom, multiplier: 1, constant: -7))
               self.addSubview(self.border)
        DispatchQueue.main.async {
            self.configureViews()
            self.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        }
    }
    
    func configureViews() {
        self.topLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 15)
        self.errorLabel.frame = CGRect(x: 0, y: 48, width: self.frame.width, height: 15)
        self.topLabel.textColor = .darkGray
        self.border.backgroundColor = .lightGray
        self.topLabel.font = self.topLabel.font.withSize(13.0)
        self.errorLabel.font = self.errorLabel.font.withSize(13.0)
        self.border.tag = 1
        self.addSubview(self.topLabel)
        self.addSubview(self.errorLabel)
    }
    
    @objc func textFieldDidChange(textField: UITextField){
        self.delagate?.texfFieldDidChange(placeholder: placeholder)
        if textField.text != "" {
            self.topLabel.text = textField.placeholder?.localized()
        } else {
            self.topLabel.text = ""
        }
    }
    
    func isValidNameOrLastnameOrUsername(text: String, count: Int) -> Bool {
        if text.count > count - 1 {
            return false
        }
        return true
    }
    
    func handleRotate() {
        self.configureViews()
    }
    
    @IBInspectable var placeholder: String {
        get {
            return self.textField.placeholder!
        } set {
            self.textField.placeholder = newValue.localized()
        }
    }
    
    @IBInspectable var errorMessage: String {
        get {
            return self.errorText.localized()
        } set {
            self.errorText = newValue.localized()
        }
    }
    
    @IBInspectable var successMessage: String {
        get {
            return self.successText
        } set {
            self.successText = newValue.localized()
        }
    }
    
    
    @IBInspectable var borderWidth: Double {
        get {
            return Double(self.layer.borderWidth)
        }
        set {
            self.layer.masksToBounds = true
            self.layer.borderWidth = CGFloat(newValue)
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        get {
            return UIColor(cgColor: self.layer.borderColor!)
        }
        set {
            self.layer.borderColor = newValue?.cgColor
        }
    }
}
