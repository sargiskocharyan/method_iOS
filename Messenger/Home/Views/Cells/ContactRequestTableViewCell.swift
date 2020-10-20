//
//  ContactRequestTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 9/16/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit

protocol ContactRequestTableViewCellDelegate: class {
    func requestRemoved(number: Int)
    func showAlert(error: NetworkResponse)
}

class ContactRequestTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var rejectButton: UIButton!
    @IBOutlet weak var userImageView: UIImageView!
    var user: User?
    var request: Request?
    var number: Int?
    weak var delegate: ContactRequestTableViewCellDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = 35
        userImageView.clipsToBounds = true
        confirmButton.layer.cornerRadius = 5
        rejectButton.layer.cornerRadius = 5
        confirmButton.clipsToBounds = true
        rejectButton.clipsToBounds = true
    }

    @IBAction func rejectRequestButtonAction(_ sender: UIButton) {
        AppDelegate.shared.viewModel.confirmRequest(id: (user?._id)!, confirm: false) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.showAlert(error: error!)
                }
            } else {
                SharedConfigs.shared.contactRequests = SharedConfigs.shared.contactRequests.filter({ (req) -> Bool in
                    return req._id != self.request?._id
                })
                DispatchQueue.main.async {
                    self.delegate?.requestRemoved(number: self.number! )
                }
                
            }
        }
    }
    
    @IBAction func confirmRequestButtonAction(_ sender: UIButton) {
        AppDelegate.shared.viewModel.confirmRequest(id: (user?._id)!, confirm: true) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    self.delegate?.showAlert(error: error!)
                }
            } else {
                SharedConfigs.shared.contactRequests = SharedConfigs.shared.contactRequests.filter({ (req) -> Bool in
                    return req._id != self.request?._id
                })
                DispatchQueue.main.async {
                    self.delegate?.requestRemoved(number: self.number!)
                }
            }
        }
    }
    
    
    func configure(user: User, request: Request, number: Int) {
        self.user = user
        self.number = number
        self.request = request
        if user.name != nil && user.lastname != nil {
            nameLabel.text = user.name! + " " + user.lastname!
        } else {
            nameLabel.text = user.username
        }
        ImageCache.shared.getImage(url: user.avatarURL ?? "", id: user._id!, isChannel: false) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
    }
}
