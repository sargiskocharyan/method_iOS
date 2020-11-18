//
//  NotificationService.swift
//  methodNotificationService
//
//  Created by Sargis Kocharyan on 8/12/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import UserNotifications
import UIKit

class NotificationService: UNNotificationServiceExtension {
    
    enum DownloadError: Error {
        case emptyData
        case invalidImage
    }

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?
  
    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        self.contentHandler = contentHandler
       
        bestAttemptContent = (request.content.mutableCopy() as? UNMutableNotificationContent)
        if let bestAttemptContent = bestAttemptContent {
            if let aps = bestAttemptContent.userInfo["aps"] as? [String: Any] {
                let name = Notification.Name("didReceiveData")
                NotificationCenter.default.post(name: name, object: nil)
                if let alert = aps["alert"] as? [String: String]{
                    bestAttemptContent.title = alert["title"]!
                }
            }
            guard let imageURLString =
                bestAttemptContent.userInfo["imageURL"] as? String else {
                    contentHandler(bestAttemptContent)
                    return
            }
            getMediaAttachment(for: imageURLString) { [weak self] image in
                guard
                    let self = self,
                    let image = image,
                    let fileURL = self.saveImageAttachment(
                        image: image,
                        forIdentifier: "attachment.png")
                    
                    else {
                        contentHandler(bestAttemptContent)
                        return
                }
                
                let imageAttachment = try? UNNotificationAttachment(
                    identifier: "image",
                    url: fileURL,
                    options: nil)
                
                if let imageAttachment = imageAttachment {
                    bestAttemptContent.attachments = [imageAttachment]
                }
                contentHandler(bestAttemptContent)
            }
        }
    }
    
    override func serviceExtensionTimeWillExpire() {
        // Called just before the extension will be terminated by the system.
        // Use this as an opportunity to deliver your "best attempt" at modified content, otherwise the original push payload will be used.
        if let contentHandler = contentHandler, let bestAttemptContent =  bestAttemptContent {
            contentHandler(bestAttemptContent)
        }
    }

    private func saveImageAttachment(
      image: UIImage,
      forIdentifier identifier: String
    ) -> URL? {
      let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
      let directoryPath = tempDirectory.appendingPathComponent(
        ProcessInfo.processInfo.globallyUniqueString,
        isDirectory: true)

      do {
        try FileManager.default.createDirectory(
          at: directoryPath,
          withIntermediateDirectories: true,
          attributes: nil)
        let fileURL = directoryPath.appendingPathComponent(identifier)

        guard let imageData = image.pngData() else {
          return nil
        }

        try imageData.write(to: fileURL)
          return fileURL
        } catch {
          return nil
      }
        
    }
    
    private func getMediaAttachment(
      for urlString: String,
      completion: @escaping (UIImage?) -> Void
    ) {
      
      guard let url = URL(string: urlString) else {
        completion(nil)
        return
      }

      downloadImage(forURL: url) { result in
        guard let image = try? result.get() else {
          completion(nil)
          return
        }
       
        completion(image)
      }
        let firstAction = UNNotificationAction( identifier: "first", title: "Confirm", options: [])
               
        let secondAction = UNNotificationAction( identifier: "second", title: "Reject", options: [])
               
        let category = UNNotificationCategory( identifier: "contactRequest", actions: [firstAction, secondAction], intentIdentifiers: [], options: [.customDismissAction])
               
        UNUserNotificationCenter.current().setNotificationCategories([category])
        
    }
    
    public func downloadImage(forURL url: URL, completion: @escaping (Result<UIImage, Error>) -> Void) {
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
}


