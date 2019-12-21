//
//  SecondViewController.swift
//  DRN1
//
//  Created by Russell Harrower on 24/11/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    
    override func viewDidAppear(_ animated: Bool) {
      self.tabBarController?.navigationItem.title = "About"
        
            //     let controller = AVPlayerViewController()
              //    controller.player = player
                  
                  // Modally present the player and call the player's play() method when complete.
            //      present(controller, animated: false) {
             //       player.play()
             //     }
       
        
    }

}

