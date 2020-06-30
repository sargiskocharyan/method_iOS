//
//  ImageCache.swift
//  Messenger
//
//  Created by Employee1 on 6/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
import UIKit

class ImageCache {
    static let shared = ImageCache()
    let cache = NSCache<AnyObject, UIImage>()
    private init() {}
    
    func setImage(image: UIImage, url: String) {
        cache.setObject(image, forKey: url as AnyObject)
    }
    
    func getImage(url: String, completion: @escaping (UIImage) -> ()) {
        if let image = cache.object(forKey: url as AnyObject) {
            completion(image)
        } else {
            guard let imageURL = URL(string: url) else {
                print(URL(string: url))
                completion(UIImage(named: "noPhoto")!)
                return }
            downloadImage(from: imageURL) { (image) in
                if image == nil {
                    completion(UIImage(named: "noPhoto")!)
                } else {
                    self.setImage(image: image!, url: url)
                    completion(image!)
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

    
}
