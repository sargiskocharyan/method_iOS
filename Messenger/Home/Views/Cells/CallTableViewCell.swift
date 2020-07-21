//
//  CallTableViewCell.swift
//  Messenger
//
//  Created by Employee1 on 7/13/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import CoreData

protocol CallTableViewDelegate: class {
    func callSelected(id: String)
}


class CallTableViewCell: UITableViewCell {

    @IBOutlet weak var callIcon: UIImageView!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var infoButton: UIButton!
    weak var delegate: CallTableViewDelegate?
    var calleId: String?
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }
    
    @IBAction func infoButtonAction(_ sender: UIButton) {
        delegate?.callSelected(id: calleId!)
    }
    override func awakeFromNib() {
           super.awakeFromNib()
           userImageView.contentMode = .scaleAspectFill
           userImageView.layer.cornerRadius = 23
           userImageView.clipsToBounds = true
       }

    func dateToString(date: Date) -> String {
        let parsedDate = date
        let calendar = Calendar.current
        let day = calendar.component(.day, from: parsedDate)
        let month = calendar.component(.month, from: parsedDate)
        let time = Date()
        let currentDay = calendar.component(.day, from: time as Date)
        if currentDay != day {
            return ("\(day).0\(month)")
        }
        let hour = calendar.component(.hour, from: parsedDate)
        let minutes = calendar.component(.minute, from: parsedDate)
        return ("\(hour):\(minutes)")
    }
    
    func configureCell(call: NSManagedObject) {
        self.nameLabel.text = call.value(forKey: "name") as! String
        ImageCache.shared.getImage(url: call.value(forKey: "image") as! String, id: call.value(forKey: "id") as! String) { (image) in
            DispatchQueue.main.async {
                self.userImageView.image = image
            }
        }
         self.timeLabel.text = dateToString(date: call.value(forKey: "time") as! Date)
        if call.value(forKey: "isHandleCall") as? Bool != true {
            self.callIcon.image = UIImage.init(systemName: "phone.fill.arrow.up.right")
        } else {
            self.callIcon.image = UIImage.init(systemName: "phone.fill.arrow.down.left")
        }
    }
}
