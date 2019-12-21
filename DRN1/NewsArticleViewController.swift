//
//  NewsArticleViewController.swift
//  DRN1
//
//  Created by Russell Harrower on 29/11/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import UIKit
import Kingfisher
import Foundation



class NewsArticleViewController: UIViewController {

    @IBOutlet weak var articleTitle: UILabel!
    @IBOutlet weak var aimage: UIImageView!
    @IBOutlet weak var content: UITextView!
   
    @IBAction func exit(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    var article: News?

  
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //tabBarController.navigationItem.title = viewController.navigationItem.title;
        self.tabBarController?.navigationItem.title = "News"
        articleTitle.text = article?.title
    
       
        // set attributed text on a UILabel
        content.attributedText = article?.content.htmlToAttributedString()
        
        let url = URL(string: article!.image)
     aimage.kf.indicatorType = .activity
        aimage.kf.setImage(with: url
                           //options: [.processor(resizingProcessor)],
                          // completionHandler: { [ weak self] image, error, cacheType, imageURL in
                          //     self?.aimage.layer.shadowOpacity = 0
                          // }
     )
     
    
    }
   

}

extension String {
    func htmlToAttributedString(fontSize: Float = 20) -> NSAttributedString? {
        let style = "<style>body {font-size:\(fontSize)px; }</style>"
        guard let data = (self + style).data(using: .utf8) else {
            return nil
        }
        return try? NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
    }
}
