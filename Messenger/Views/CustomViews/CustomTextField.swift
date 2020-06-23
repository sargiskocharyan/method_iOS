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
        DispatchQueue.main.async {
            self.configureViews()
            self.textField.addTarget(self, action: #selector(self.textFieldDidChange(textField:)), for: .editingChanged)
        }
    }
    
    func configureViews() {
        self.topLabel.frame = CGRect(x: 0, y: 0, width: self.frame.width, height: 10)
        self.textField.frame = CGRect(x: 0, y: 10, width: self.frame.width, height: 35)
        self.errorLabel.frame = CGRect(x: 0, y: 48, width: self.frame.width, height: 10)
        self.topLabel.textColor = .darkGray
        self.border.backgroundColor = .lightGray
        self.topLabel.font = self.topLabel.font.withSize(13.0)
        self.errorLabel.font = self.errorLabel.font.withSize(13.0)
        self.border.frame = CGRect(x: 0, y: self.topLabel.frame.height + self.textField.frame.height-7, width: self.frame.width, height: self.height)
        self.addSubview(self.border)
        self.border.tag = 1
        self.addSubview(self.textField)
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
        viewWithTag(1)?.removeFromSuperview()
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
