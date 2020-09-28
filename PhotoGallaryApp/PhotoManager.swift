//
//  PhotoManager.swift
//  Flicker_iOS_search
//
//  Created by Suryakant Sharma-Pro on 06/09/20.
//  Copyright © 2020 Github. All rights reserved.
//

import Foundation
// https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736&%20format=json&nojsoncallback=1&safe_search=1&text=apple&page=1

struct PhotoManager {
    
   private var dataTask: URLSessionDataTask?
   private let flickrKey = "3e7cc266ae2b0e0d78e279ce8e361736"
    
   private func getURLPath(_ pageCount: Int, and text: String) -> URL? {
        guard let urlPath = URL(string: "https://api.flickr.com/services/rest/?method=flickr.photos.search&api_key=\(flickrKey)&format=json&nojsoncallback=1&safe_search=1&text=\(text)&page=\(pageCount)") else {
            return nil
        }
        return urlPath
    }
    
    internal mutating func fetchPhotos(session: URLSession = URLSession.shared, text: String, pageCount: Int, callBack: @escaping((Result<Photos, Error>) -> Void)) {
        
        //TODO: Add Space with URL encoding
        // Removing here spaces
        let keyword = text.removeSpace
        guard keyword.count != 0 else { return }
        
        guard let urlPath = getURLPath(pageCount, and: keyword) else {
            return
        }
        
        let urlRequest = URLRequest(url: urlPath,
                                    cachePolicy: .returnCacheDataElseLoad,
                                    timeoutInterval: 60)
        
        
        // Cancel earlier data task before start new one
        self.dataTask?.cancel()
        self.dataTask = session.dataTask(with: urlRequest) { data, response, error in
            guard let data = data, error == nil else {
                print("error: \(String(describing: error?.localizedDescription))")
                callBack(.failure(error!))
                return
            }
            do {
                let photos = try JSONDecoder().decode(Photos.self, from: data)
                callBack(.success(photos))
            } catch {
                print("error:\(error.localizedDescription)")
                callBack(.failure(error))
            }
        }
        dataTask?.resume()
    }
}


