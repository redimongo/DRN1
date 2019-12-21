//
//  NewsCell.swift
//  DRN1
//
//  Created by Russell Harrower on 26/11/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import UIKit
import Kingfisher


class NewsCell: UITableViewCell {
   
   
    @IBOutlet weak var newsTitleLable: UILabel!
    @IBOutlet weak var newsImages: UIImageView!
    
    func setNews(news:News){
        print(news.image)
        //newsImages.text = news.image
       // let scale = UIScreen.main.scale
       // let resizingProcessor = ResizingImageProcessor(referenceSize: CGSize(width: 100.0 * scale, height: 50.0 * scale))
        let url = URL(string: news.image)
        newsImages.kf.indicatorType = .activity
        let processor = RoundCornerImageProcessor(cornerRadius: 0)
                    |> ResizingImageProcessor(referenceSize: CGSize(width: 100.0 * UIScreen.main.scale, height: 50.0 * UIScreen.main.scale))
        newsImages.kf.setImage(
            with: url,
            placeholder: UIImage(named: "placeholderImage"),
            options: [
                .processor(processor),
                .scaleFactor(UIScreen.main.scale),
                .transition(.fade(1)),
                .cacheOriginalImage
            ])
        {
            result in
            switch result {
            case .success(let value):
                print("Task done for: \(value.source.url?.absoluteString ?? "")")
            case .failure(let error):
                print("Job failed: \(error.localizedDescription)")
            }
        }
        /*newsImages.kf.setImage(with: url,
                              options: [.processor(resizingProcessor)],
                              completionHandler: { [ weak self] image, error, cacheType, imageURL in
                                  self?.newsImages.layer.shadowOpacity = 0
                              }
        )*/
        
        
        
       // newsImages.kf.setImage(with: URL(string: news.image), placeholder: nil)
        newsImages.layer.zPosition = 0;
        newsTitleLable.text = news.title
    }
}
