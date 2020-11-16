//
//  ChannelMessagesViewModel.swift
//  Messenger
//
//  Created by Employee1 on 9/29/20.
//  Copyright © 2020 Dynamic LLC. All rights reserved.
//

import Foundation
import AVFoundation

class ChannelMessagesViewModel {
    
    func getChannelMessages(id: String, dateUntil: String?, completion: @escaping (ChannelMessages?, NetworkResponse?)->()) {
        HomeNetworkManager().getChannelMessages(id: id, dateUntil: dateUntil) { (messages, error) in
            completion(messages, error)
        }
    }

    func subscribeToChannel(id: String, completion: @escaping (SubscribedResponse?, NetworkResponse?)->())  {
        HomeNetworkManager().subscribe(id: id) { (subresponse, error) in
            completion(subresponse, error)
        }
    }
    
    func getChatMessages(id: String, dateUntil: String?, completion: @escaping (Messages?, NetworkResponse?)->()) {
           HomeNetworkManager().getChatMessages(id: id, dateUntil: dateUntil) { (messages, error) in
               completion(messages, error)
           }
       }
    
    func deleteChannelMessages(id: String, ids: [String], completion: @escaping (NetworkResponse?)->())  {
        HomeNetworkManager().deleteChannelMessages(id: id, ids: ids) { (error) in
            completion(error)
        }
    }
    
    func leaveChannel(id: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().leaveChannel(id: id) { (error) in
            completion(error)
        }
    }
    
    func deleteChannelMessageBySender(ids: [String], completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().deleteChannelMessageBySender(ids: ids) { (error) in
            completion(error)
        }
    }
    
    func editChannelMessageBySender(id: String, text: String, completion: @escaping (NetworkResponse?)->()) {
        HomeNetworkManager().editChannelMessageBySender(id: id, text: text) { (error) in
            completion(error)
        }
    }
    
    func encodeVideo(at videoURL: URL, completionHandler: ((URL?, Error?) -> Void)?)  {
        let avAsset = AVURLAsset(url: videoURL, options: nil)
        //Create Export session
        guard let exportSession = AVAssetExportSession(asset: avAsset, presetName: AVAssetExportPresetPassthrough) else {
            completionHandler?(nil, nil)
            return
        }
        let filename = videoURL.absoluteString.components(separatedBy: "/").last
        //Creating temp path to save the converted video
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsDirectory.appendingPathComponent(filename ?? "rendered_video.mp4")
        //Check if the file already exists then remove the previous file
        if FileManager.default.fileExists(atPath: filePath.path) {
            do {
                try FileManager.default.removeItem(at: filePath)
            } catch {
                completionHandler?(nil, error)
            }
        }
        exportSession.outputURL = filePath
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        let start = CMTimeMakeWithSeconds(0.0, preferredTimescale: 0)
        let range = CMTimeRangeMake(start: start, duration: avAsset.duration)
        exportSession.timeRange = range
        exportSession.exportAsynchronously(completionHandler: {() -> Void in
            switch exportSession.status {
            case .failed:
                print(exportSession.error ?? "NO ERROR")
                completionHandler?(nil, exportSession.error)
            case .cancelled:
                completionHandler?(nil, nil)
            case .completed:
                completionHandler?(exportSession.outputURL, nil)
            default: break
            }
        })
    }
}
