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
        if let filename = videoUrl.components(separatedBy: "/").last?.components(separatedBy: "?").first {
            let fileURL = try! FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathComponent(filename, isDirectory: false)
            if FileManager.default.fileExists(atPath: fileURL.path) {
                completion(fileURL)
                return
            } else {
                HomeNetworkManager().downloadVideo(from: videoUrl, isNeedAllBytes: true) { (error, data) in
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
}

