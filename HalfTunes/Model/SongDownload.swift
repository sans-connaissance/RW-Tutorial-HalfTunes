//
//  SongDownload.swift
//  HalfTunes
//
//  Created by David Malicke on 6/26/21.
//  Copyright © 2021 raywenderlich. All rights reserved.
//

import Foundation

class SongDownload: NSObject, ObservableObject  {
    
    var downloadTask: URLSessionDownloadTask?
    var downloadURL: URL?
    
    @Published var downloadLocation: URL?
    
    lazy var urlSession: URLSession = {
        let configuration = URLSessionConfiguration.default
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    func fetchSongAtURL(_ item: URL) {
        downloadURL = item
        downloadTask = urlSession.downloadTask(with: item)
        downloadTask?.resume()
    }
    
}

extension SongDownload: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if let error = error {
            print(error.localizedDescription)
            
        }
        
    }
    
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        
        let fileManager = FileManager.default
        guard
            let documentsPath = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first,
              let lastPathComponent = downloadURL?.lastPathComponent else {
            fatalError()
        }
        let destinationUrl = documentsPath.appendingPathComponent(lastPathComponent)
        do {
            if fileManager.fileExists(atPath: destinationUrl.path) {
                try fileManager.removeItem(at: destinationUrl)
            }
            try fileManager.copyItem(at: location, to: destinationUrl)
            DispatchQueue.main.async {
                self.downloadLocation = destinationUrl
            }
        } catch {
            print(error)
        }
        
    }
    
}
