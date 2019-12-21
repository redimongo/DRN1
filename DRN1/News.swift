//
//  News.swift
//  DRN1
//
//  Created by Russell Harrower on 26/11/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import Foundation
//import UIKit

class News {
    
  //  var image: UIImage
    var title: String
    var image: String
    var content: String
    
    
    init(title: String, image: String, content: String) {
        self.image = image
        self.title = title
        self.content = content
    }
}
