//
//  NewsViewController.swift
//  DRN1
//
//  Created by Russell Harrower on 26/11/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import UIKit
import Intents
import Foundation


struct NewsData: Decodable{
    let news: [articalData]
}

struct articalData: Decodable{
    let title: String
    let image: String
    let content: String
}

class NewsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!

    
    var news: [News] = []
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
        let intent = PlayDRN1Intent()
        intent.playdrn1 = "DRN1"

        let interaction = INInteraction(intent: intent, response: nil)
        interaction.donate { (error) in
            print(error ?? "error")
        }
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
    
       self.tabBarController?.navigationItem.title = "News"
         
         self.newsfetch { [weak self] news in
                    guard let news = news else { return }
                    self?.news = news
            DispatchQueue.main.async {
                    self?.tableView.reloadData()
            }
            }
         
     }
    
    
    func newsfetch(_ completionHandler:  @escaping ([News]?)->Void){
        let jsonURLString = "https://api.drn1.com.au/api-access/news"
        guard let feedurl = URL(string: jsonURLString) else {  return }

        URLSession.shared.dataTask(with: feedurl){ (data,response,err)
            in
            guard let news = data else { return }
            do {
                let newsdata = try JSONDecoder().decode(NewsData.self, from: news)
                var tempNews: [News] = []
                newsdata.news.forEach(){
                    tempNews.append(News(title: $0.title, image: $0.image, content: $0.content))
                }
                completionHandler(tempNews)
            } catch let jsonErr {
                print("error json ", jsonErr)
                completionHandler(nil)
            }
        }.resume()
       
    }
    
    
   
    
  
 

}


extension NewsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let newsa = news[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell") as! NewsCell
        cell.setNews(news: newsa)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "shownewsarticle", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as?  NewsArticleViewController{
            destination.article = news[(tableView.indexPathForSelectedRow?.row)!]
            tableView.deselectRow(at: tableView.indexPathForSelectedRow!, animated: false)
        }

    }
    
   
}
