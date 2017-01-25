//
//  Extensions.swift
//  It's Lit
//
//  Created by Chandan Brown on 7/24/16.
//  Copyright © 2016 Gaming Recess. All rights reserved.
//

import UIKit


func addConstraintsWithFormat(_ format: String, views: UIView...) {
    var viewsDictionary = [String: UIView]()
    for (index, view) in views.enumerated() {
        let key = "v\(index)"
        view.translatesAutoresizingMaskIntoConstraints = false
        viewsDictionary[key] = view
    }
    
    class CustomImageView: UIImageView {
        
        var imageUrlString: String?
        
        func loadImageUsingUrlString(_ urlString: String) {
            
            imageUrlString = urlString
            let url = URL(string: urlString)
            image = nil
            
            URLSession.shared.dataTask(with: url!, completionHandler: { (data, respones, error) in
                
                if error != nil {
                    print(error as Any)
                    return
                }
                
                DispatchQueue.main.async(execute: {
                    
                    let imageToCache = UIImage(data: data!)
                    if self.imageUrlString == urlString {
                        self.image = imageToCache
                    }
                    
                })
                
            }).resume()
        }
        
    }
    
}
