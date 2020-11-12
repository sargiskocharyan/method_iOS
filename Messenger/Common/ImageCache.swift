//
//  ImageCache.swift
//  Messenger
//
//  Created by Employee1 on 6/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation

class Avatar {
    var url: String
    var image: UIImage
    init(url: String, image: UIImage) {
        self.url = url
        self.image = image
    }
}
class ImageCache {
    static let shared = ImageCache()
    let cache = NSCache<AnyObject, Avatar>()
    private init() {}
    
    func setImage(image: UIImage, url: String, id: String) { //6->2
        cache.setObject(Avatar(url: url, image: image), forKey: id as AnyObject)
    }
    
    func removeForKey(id: String) {
        cache.removeObject(forKey: id as AnyObject)
    }
    
    func getImage(url: String, id: String, isChannel: Bool, completion: @escaping (UIImage) -> ()) {
       if let avatar = cache.object(forKey: id as AnyObject) {
            if avatar.url == url {
                completion(avatar.image)
                return
            } else {
                self.removeForKey(id: id)
                guard let imageURL = URL(string: url) else {
                   completion(isChannel ? UIImage(named: "channelPlaceholder")! : UIImage(named: "noPhoto")!)
                    return }
                self.downloadImage(from: imageURL) { (image) in
                    if image == nil {
                        completion(isChannel ? UIImage(named: "channelPlaceholder")! : UIImage(named: "noPhoto")!)
                        return
                    } else {
                        self.setImage(image: image!, url: url, id: id)
                        completion(image!)
                        return
                    }
                }
            }
        } else {
            guard let imageURL = URL(string: url) else {
                completion(isChannel ? UIImage(named: "channelPlaceholder")! : UIImage(named: "noPhoto")!)
                return }
            downloadImage(from: imageURL) { (image) in
                if image == nil {
                    completion(isChannel ? UIImage(named: "channelPlaceholder")! : UIImage(named: "noPhoto")!)
                    return
                } else {
                    self.setImage(image: image!, url: url, id: id)
                    completion(image!)
                    return
                }
            }
        }
    }
    
    func downloadImage(from url: URL, completion: @escaping (UIImage?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let data = data, error == nil,
                let image = UIImage(data: data)
                else {
                    completion(nil)
                    return }
            completion(image)
        }.resume()
    }
    
    func getThumbnail(videoUrl: String, messageId: String, completion: @escaping (UIImage) -> ()) {
        if let thumbnail = cache.object(forKey: messageId as AnyObject) {
            completion(thumbnail.image)
            return
        } else {
            guard URL(string: videoUrl) != nil else {
                completion(UIImage(named: "channelPlaceholder")!)
                return }
            let filename = videoUrl.components(separatedBy: "/").last
            HomeNetworkManager().downloadVideo(from: videoUrl, isNeedAllBytes: true) { (error, data) in
                if error != nil {
                    completion(UIImage(named: "channelPlaceholder")!)
                    return
                }
                let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
                let filePath = documentsDirectory.appendingPathComponent(filename ?? "")
                if FileManager.default.fileExists(atPath: filePath.path) {
                    try! FileManager.default.removeItem(at: filePath)
                }
                if let data = data {
                    do {
                        try data.write(to: filePath)
                        let asset = AVURLAsset(url: filePath, options: nil)
                        let imgGenerator = AVAssetImageGenerator(asset: asset)
                        imgGenerator.appliesPreferredTrackTransform = true
                        do {
                            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                            let thumbnail = UIImage(cgImage: cgImage)
                            self.setImage(image: thumbnail, url: videoUrl, id: messageId)
                            completion(thumbnail)
                            return
                        }
                        catch {
                            completion(UIImage(named: "channelPlaceholder")!)
                            return
                        }
                    } catch {
                        print(error.localizedDescription)
                        completion(UIImage(named: "channelPlaceholder")!)
                    }
                }
            }
        }
    }
}
