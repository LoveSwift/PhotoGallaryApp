//
//  Photos.swift
//  Flicker_iOS_search
//
//  Created by Suryakant Sharma-Pro on 06/09/20.
//  Copyright © 2020 Github. All rights reserved.
//

import Foundation

struct Photos: Codable {
    let photos: PhotosClass
}

struct PhotosClass: Codable {
    let page, pages, perpage: Int
    let total: String
    let photo: [Photo]
}

struct Photo: Codable {
    let id, owner, secret, server: String
    let farm: Int
    let title: String
    let ispublic, isfriend, isfamily: Int
}
// https://farm1.static.flickr.com/578/23451156376_8983a8ebc7.jpg
extension Photo {
    func getImagePath() -> URL? {
        let path = "http://farm\(self.farm).static.flickr.com/\(self.server)/\(self.id)_\(self.secret).jpg"
        return URL(string: path)
    }
}

