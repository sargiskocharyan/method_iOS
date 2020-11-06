//
//  VideoCache.swift
//  Messenger
//
//  Created by Employee3 on 11/6/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation

class VideoCache {
    static let shared = VideoCache()
    let cache = NSCache<AnyObject, Avatar>()
    private init() {}
    
    func getVideo(videoUrl: String, completion: @escaping (URL?) -> ()) {
        if let filename = videoUrl.components(separatedBy: "/").last {
            let fileURL = try! FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(filename, isDirectory: false)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                completion(fileURL)
                return
            } else {
                downloadVideo(from: videoUrl) { (error, data) in
                    if error != nil {
                        completion(nil)
                        return
                    }
                    do {
                        try data?.write(to: fileURL)
                        completion(fileURL)
                        return
                    } catch {
                        print(error.localizedDescription)
                        completion(nil)
                        return
                    }
                }
            }
        }
    }
    
    func downloadVideo(from url: String, completion: @escaping (NetworkResponse?, Data?) -> ()) {
        var request = URLRequest(url: URL(string: url)!)
        request.httpMethod = "GET"
        request.timeoutInterval = 10
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue(SharedConfigs.shared.signedUser?.token, forHTTPHeaderField: "Authorization")
        let session = URLSession.shared
        session.dataTask(with: request) { (data, response, error) in
            guard (response as? HTTPURLResponse) != nil else {
                completion(NetworkResponse.failed, nil)
                return }
            if error != nil {
                print(error!.localizedDescription)
                completion(NetworkResponse.failed, nil)
            } else {
                guard let responseData = data else {
                    completion(NetworkResponse.noData, nil)
                    return
                }
                completion(nil, responseData)
                return
            }
        }.resume()
        
    }
}

