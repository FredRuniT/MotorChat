//
//  CacheExtension.swift
//  MotorChat
//
//  Created by Stephan Dowless on 2/23/17.
//  Copyright © 2017 Stephan Dowless. All rights reserved.
//

import UIKit
import Firebase

let imageCache: NSCache<NSString, UIImage> = NSCache()

extension UIImageView {
    
    func loadImagesUsingCacheWith(urlString: String) {
        
        self.image = nil
        
        //check cache for image first
        if let cachedImage = imageCache.object(forKey: urlString as NSString) {
            self.image = cachedImage
            return
        } else {
            let ref = FIRStorage.storage().reference(forURL: urlString)
            ref.data(withMaxSize: 2 * 1024 * 1024, completion: { (data, error) in
                if error != nil {
                    print("STEPHAN: Unable to download image from Firebase storage")
                } else {
                    if let img = UIImage(data: data!) {
                        self.image = img
                        imageCache.setObject(img, forKey: urlString as NSString)
                    }
                }
            })
        }
    }
}
