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
        let category = UNNotificationCategory(identifier: "new_rich_message", actions: [], intentIdentifiers: [], options: [])
        UNUserNotificationCenter.current().setNotificationCategories([category])
        if let bestAttemptContent = bestAttemptContent {
            let key: AnyHashable = "aps"
            if let aps = bestAttemptContent.userInfo[key] as? [String: Any]{
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
                // 3
                guard
                    let self = self,
                    let image = image,
                    let fileURL = self.saveImageAttachment(
                        image: image,
                        forIdentifier: "attachment.png")
                    // 4
                    else {
                        contentHandler(bestAttemptContent)
                        return
                }
                
                // 5
                let imageAttachment = try? UNNotificationAttachment(
                    identifier: "image",
                    url: fileURL,
                    options: nil)
                
                // 6
                if let imageAttachment = imageAttachment {
                    bestAttemptContent.attachments = [imageAttachment]
                }
                
                // 7
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
      // 1
      let tempDirectory = URL(fileURLWithPath: NSTemporaryDirectory())
      // 2
      let directoryPath = tempDirectory.appendingPathComponent(
        ProcessInfo.processInfo.globallyUniqueString,
        isDirectory: true)

      do {
        // 3
        try FileManager.default.createDirectory(
          at: directoryPath,
          withIntermediateDirectories: true,
          attributes: nil)

        // 4
        let fileURL = directoryPath.appendingPathComponent(identifier)

        // 5
        guard let imageData = image.pngData() else {
          return nil
        }

        // 6
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
      // 1
      guard let url = URL(string: urlString) else {
        completion(nil)
        return
      }

      // 2
      downloadImage(forURL: url) { result in
        // 3
        guard let image = try? result.get() else {
          completion(nil)
          return
        }

        // 4
        completion(image)
      }
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


