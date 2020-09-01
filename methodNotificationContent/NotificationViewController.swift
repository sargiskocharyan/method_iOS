//
//  NotificationViewController.swift
//  methodNotificationContent
//
//  Created by Sargis Kocharyan on 8/13/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UIKit
import UserNotifications
import UserNotificationsUI

class NotificationViewController: UIViewController, UNNotificationContentExtension {
    
    enum DownloadError: Error {
           case emptyData
           case invalidImage
       }

    @IBOutlet var label: UILabel?
    @IBOutlet weak var bodyLabel: UILabel!
    @IBOutlet weak var imageView: UIImageView!
    var defaults: UserDefaults?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         defaults = UserDefaults(suiteName: "group.am.dynamic.method")
    }
   
    @IBAction func rejectRequestAction(_ sender: UIButton) {
        print("dfjgfg")
       
//        defaults.addObserver(self, forKeyPath: "Last", options: [.initial], context: nil)
        defaults!.set(true, forKey: "Last")
        defaults!.synchronize()
    }
    
    @IBAction func confirmRequestAction(_ sender: UIButton) {
        NotificationCenter.default.post(name: NSNotification.Name.init("confirm"), object: nil, userInfo: ["confirm": true])
    }
    
    func didReceive(_ notification: UNNotification) {
        self.label?.text = notification.request.content.body
        
        let content = notification.request.content
        
        self.label?.text = content.title
        self.bodyLabel.text = content.body
        let bestAttemptContent = (notification.request.content.mutableCopy() as? UNMutableNotificationContent)
        guard let imageURLString =
            bestAttemptContent!.userInfo["imageURL"] as? String else {
          
          return
        }
        if let url = URL(string: imageURLString) {
            self.downloadImage(forURL: url) { result in
                // 3
                guard let image = try? result.get() else {
                    return
                }
                DispatchQueue.main.async {
                    self.imageView.image = image
                }
            }
        }
        
    }

    func downloadImage(forURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(DownloadError.emptyData))
                return
            }
            
            guard let image = UIImage(data: data) else {
                completion(.failure(DownloadError.invalidImage))
                return
            }
            
            completion(.success(image))
        }
        
        task.resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
}
extension UserDefaults {
    @objc dynamic var greetingsCount: Int {
        return integer(forKey: "greetingsCount")
    }
}
