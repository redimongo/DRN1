//
//  FirstViewController.swift
//  DRN1
//
//  Created by Russell Harrower on 24/11/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import UIKit
import Intents
import AVKit
import Kingfisher
import FacebookLogin
import AuthenticationServices
import Network

extension UIImageView {
      func setImage(with urlString: String){
          guard let url = URL.init(string: urlString) else {
              return
          }
          let resource = ImageResource(downloadURL: url, cacheKey: urlString)
          var kf = self.kf
          kf.indicatorType = .activity
          self.kf.setImage(with: resource)
      }
  }

struct defaultsKeys {
    static let musicplayer_connected = "0"
    static var socialLogin = "0"
    static let socialLoginuid = ""
}

struct Nowplayng: Decodable{
    let data: [Data]
}

struct Data: Decodable{
    let track: Trackinfo
}
struct Trackinfo: Decodable {
    let title: String
    let artist: String
    let imageurl: String
}

class FirstViewController: UIViewController {

      var user = [String]()
      let button = UIButton()
      var timer = Timer()
      var rplayed = false;
      var playButton = true;
      let defaults = UserDefaults.standard
      let monitor = NWPathMonitor()
        let queue = DispatchQueue(label: "Monitor")
      @IBOutlet weak var artist: UILabel!
      @IBOutlet weak var song: UILabel!
      @IBOutlet weak var imageurl: UIImageView!
    
      override func viewDidLoad() {
      
        let audioSession = AVAudioSession.sharedInstance()
      
        do {
        
            try audioSession.setCategory(AVAudioSession.Category.playback)
      
        } catch {
            print("error with AVAudioSessions")
      
        }
        monitor.pathUpdateHandler = { path in
            if path.status == .satisfied {
                MusicPlayer.shared.startBackgroundMusic()
            } else {
                self.unreachable()
            }
         
        }
        self.artist.textAlignment = .center
        self.song.textAlignment = .center
        nowplaying()
        scheduledTimerWithTimeInterval()
        
        monitor.start(queue: queue)
        // Image needs to be added to project.
                      let buttonIcon = UIImage(systemName: "person.circle")
                       
                      let rightBarButton = UIBarButtonItem(title: "Person", style: UIBarButtonItem.Style.done, target: self, action: #selector(FirstViewController.checkLogin(_:)))
                       rightBarButton.image = buttonIcon
                       
                        self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
                     
        
        // Do any additional setup after loading the view.
        
        
        
          
      }
    func unreachable(){
    DispatchQueue.main.sync {
        let nalertController = UIAlertController(title: "Network Unreachable", message: "You seem to be in an area that has no WIFI or Mobile coverage. please check your network.", preferredStyle: .alert)
                       let action1 = UIAlertAction(title: "Retry", style: .default) { (action:UIAlertAction) in
                        self.monitor.start(queue: self.queue)
                       }

                       let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                          
                       }
                       
                       nalertController.addAction(action1)
                       nalertController.addAction(action2)
                       self.present(nalertController, animated: true, completion: nil)
        }
    }
    
    override func viewDidLayoutSubviews(){
        self.getFBUserData()
    }
    
   
    
    func scheduledTimerWithTimeInterval(){
        // Scheduling timer to Call the function "updateCounting" with the interval of 1 seconds
        timer = Timer.scheduledTimer(timeInterval: 30, target: self, selector: #selector(self.nowplaying), userInfo: nil, repeats: true)
    }
      
     
     @objc func nowplaying(){
          let jsonURLString = "https://api.drn1.com.au/station/playing"
          guard let feedurl = URL(string: jsonURLString) else { return }
                  
          URLSession.shared.dataTask(with: feedurl) { (data,response,err)
                  in

          guard let data = data else { return }
                      
          do{
          let nowplaying = try JSONDecoder().decode(Nowplayng.self, from: data)
                          
          nowplaying.data.forEach {
                             
            DispatchQueue.main.async {
                self.artist.text = nowplaying.data.first?.track.artist
                self.song.text = nowplaying.data.first?.track.title
            }
                        
                         
            if var strUrl = nowplaying.data.first?.track.imageurl {
                   strUrl = strUrl.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!
 
               DispatchQueue.main.sync {
                let processor = DownsamplingImageProcessor(size: self.imageurl.bounds.size)
                    |> RoundCornerImageProcessor(cornerRadius: 20)
                self.imageurl.kf.indicatorType = .activity
                self.imageurl.kf.setImage(
                    with: URL(string: strUrl),
                    placeholder: UIImage(named: "placeholderImage"),
                    options: [
                        .processor(processor),
                        .scaleFactor(UIScreen.main.scale),
                        .transition(.fade(1)),
                        .cacheSerializer(FormatIndicatedCacheSerializer.png),
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
                }
//                        self.imageurl.kf.setImage(with: URL(string: strUrl), placeholder: nil)
                        //MusicPlayer.shared.nowplaying(artist:  $0.track.artist, song: $0.track.title, cover:strUrl)
                        MusicPlayer.shared.getArtBoard(artist: $0.track.artist, song: $0.track.title, cover:strUrl)
                }
                
            
                             
        }
                          
                       
                          
        }catch let jsonErr{
                print("error json ", jsonErr)
        }
                      
        
       }.resume()
      }
     
      
      override func viewDidAppear(_ animated: Bool) {
        let defaults = UserDefaults.standard
        if let stringOne = defaults.string(forKey: defaultsKeys.socialLoginuid) {
            print(stringOne) // Some String Value
            self.tabBarController?.navigationItem.rightBarButtonItem = nil
        }
        print(defaults.string(forKey: defaultsKeys.socialLogin) as Any)
        self.tabBarController?.navigationItem.title = "DRN1"
       
           //self.tabBarController?.navigationItem.rightBarButtonItem.backgroundColor = UIColor(patternImage: UIImage(systemName: "ng")
        //self.tabBarController?.navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: "person.circle", target: self, action: nil)


    }
   
   @objc func checkLogin(_ sender:UIBarButtonItem!){
    //SocialLogin.shared.checkLogin();
    
    /*let viewController:UIViewController = UIStoryboard(name: "SocialLogin", bundle: nil).instantiateViewController(withIdentifier: "socialLogin") as UIViewController
    self.present(viewController, animated: false, completion: nil)
   */
    performSegue(withIdentifier: "Test", sender: self)
    
    /*let fbLoginManager : LoginManager = LoginManager()
                  fbLoginManager.logOut()

                  fbLoginManager.logIn(permissions:["email"], from: self, handler: { (result, error) -> Void in
                        if ((error) != nil)
                        {
                            // Process error
                            //  print(error)
                        }
                        else if (result?.isCancelled)!
                        {
                            // Handle cancellations
                            // print(error)
                        }
                        else
                        {
                            self.getFBUserData()
                          /*let fbloginresult : LoginResult = result!
                            if(fbloginresult.grantedPermissions.contains("email"))
                            {
                                self.getFBUserData()
                                // fbLoginManager.logOut()
                            }*/
                        }
                    })*/
    }
   
    @objc func signOut(_ sender:UIBarButtonItem!){
        let alertController = UIAlertController(title: "Alert", message: "Are you sure you wish to signout?", preferredStyle: .alert)
        let action1 = UIAlertAction(title: "Sign Out", style: .default) { (action:UIAlertAction) in
           let fbLoginManager : LoginManager = LoginManager()
            fbLoginManager.logOut()

            //RESET USER LOGIN BUTTON
           let buttonIcon = UIImage(systemName: "person.circle")
                  
           let rightBarButton = UIBarButtonItem(title: "Person", style: UIBarButtonItem.Style.done, target: self, action: #selector(FirstViewController.checkLogin(_:)))
           rightBarButton.image = buttonIcon
                  
           self.tabBarController?.navigationItem.rightBarButtonItem = rightBarButton
            //END
            
        }

        let action2 = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
            print("You've pressed cancel");
        }
        
        alertController.addAction(action1)
        alertController.addAction(action2)
        self.present(alertController, animated: true, completion: nil)
        
        
        
    }
    
    func getFBUserData(){
          if((AccessToken.current) != nil){
          GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(normal), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //SET LOGIN DATA
                    self.defaults.set("1", forKey: defaultsKeys.socialLogin)
                    //END DATA
                 
                    print((result! as AnyObject))
                    let fbID = ((result! as AnyObject).value(forKey: "id") as? String) ?? ""
                    let facebookProfileUrl = "http://graph.facebook.com/\(fbID)/picture?type=large"
                    print(facebookProfileUrl)
                    
                    //GRAB IMAGE AND TURN TO BUTTON
                    let fburl = URL(string: facebookProfileUrl)
                    // Image needs to be added to project.
                     
                    self.button.frame = CGRect(x: 0, y: 0, width: 31, height: 31) //set the frame
                    let fbs = CGSize(width: 31, height: 31)
                    let processor = DownsamplingImageProcessor(size: fbs)
                    |> RoundCornerImageProcessor(cornerRadius: 20)
                      let modifier = AnyImageModifier { return $0.withRenderingMode(.alwaysOriginal) }
                    self.button.kf.setImage(with: fburl,for: .normal, options: [.processor(processor),.imageModifier(modifier),.cacheSerializer(FormatIndicatedCacheSerializer.png)])
                    self.button.addTarget(self, action:  #selector(FirstViewController.signOut(_:)), for: .touchUpInside)
                     let barButton = UIBarButtonItem()
                    barButton.customView = self.button
                     self.tabBarController?.navigationItem.rightBarButtonItem = barButton
                    //END FACEBOOK PROFILE IMAGE
                    
                    
                    //  print(((result! as AnyObject).value(forKey: "id") as? String)!)

                   // self.strEmail = ((result! as AnyObject).value(forKey: "email") as? String) ?? ""
                   // self.strID = ((result! as AnyObject).value(forKey: "id") as? String) ?? ""
                   // self.strName = ((result! as AnyObject).value(forKey: "name") as? String) ?? ""

                  //  self.TextFBEmail.text = self.strEmail

                }
            })
        }
    }

    
      @IBAction func playVideo(_ sender: Any) {
         if(playButton == false){
              playButton = true;
        //  (sender as! UIButton).setTitle("Pause", for: [])
            (sender as! UIButton).setBackgroundImage(UIImage(systemName: "pause.circle"), for: UIControl.State.normal)
              MusicPlayer.shared.startBackgroundMusic()
              
          }else
          {
              playButton = false;
       //   (sender as! UIButton).setTitle("Play", for: [])
            
            (sender as! UIButton).setBackgroundImage(UIImage(systemName: "play.circle"), for: UIControl.State.normal)
            MusicPlayer.shared.stopBackgroundMusic()
            //self.player.pause()
          }
         
      }


}

