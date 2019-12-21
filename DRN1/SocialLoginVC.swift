//
//  SocialLoginVC.swift
//  DRN1
//
//  Created by Russell Harrower on 18/12/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import UIKit
import AuthenticationServices
import Kingfisher
import FacebookCore
import FacebookLogin


class SocialLoginViewController: UIViewController,LoginButtonDelegate {
 
    
    let button = UIButton()
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let accessToken = AccessToken.current {
         print("Here is the data you requested \(accessToken)")
        }
        
        setupView()
        
    }
    
    
    func setupView(){
        let appleButton = ASAuthorizationAppleIDButton()
        appleButton.translatesAutoresizingMaskIntoConstraints = false
        appleButton.addTarget(self, action: #selector(didTapAppleButton), for: .touchUpInside)
        
        let facebookButton = FBLoginButton(permissions: [ .publicProfile ])
        facebookButton.translatesAutoresizingMaskIntoConstraints = false
        facebookButton.delegate = self
        
        let skipButton = UIButton(frame: CGRect(x: 100, y: 100, width: 100, height: 48))
        skipButton.backgroundColor = .white
        skipButton.setTitleColor(.black, for: .normal)
        skipButton.setTitle("Skip Login", for: .normal)
        skipButton.addTarget(self, action: #selector(skipAction), for: .touchUpInside)
        skipButton.translatesAutoresizingMaskIntoConstraints = false
        
        
        view.addSubview(appleButton)
        view.addSubview(facebookButton)
        view.addSubview(skipButton)
        NSLayoutConstraint.activate([
            appleButton.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            appleButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            appleButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            facebookButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30),
            facebookButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            facebookButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30),
            skipButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 62),
            skipButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            skipButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])

    }
    
    @objc func skipAction(sender: UIButton!) {
        _ = navigationController?.popToRootViewController(animated: true)
    }
    
    //FACEBOOK CODE
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
       if((AccessToken.current) != nil){
          GraphRequest(graphPath: "me", parameters: ["fields": "id, name, first_name, last_name, picture.type(normal), email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    //SET LOGIN DATA
                    defaultsKeys.socialLogin = "1"
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
                    self.dismiss(animated: false, completion: nil)
                }
            })
        }
      
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
      print("Did logout via LoginButton")
    }
    //END FACEBOOK LOGIN
    
    
    //APPLE SIGNIN
    @objc func didTapAppleButton(){
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        
        controller.performRequests()
        
    }
    //END APPLE SIGNIN
    
    
   /* override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        _ = navigationController?.popToRootViewController(animated: true)
        //self.dismiss(animated: false, completion: nil)
        if let userVC = segue.destination as? UserVC, let user =
            sender as? User{
            userVC.user = user
        }
    }*/
    
}
extension SocialLoginViewController: ASAuthorizationControllerDelegate{
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        switch authorization.credential {
        case let credentials as ASAuthorizationAppleIDCredential:
           let user = User(credentials: credentials)
           print(user.id)
           let defaults = UserDefaults.standard
           defaults.set(user.id, forKey: defaultsKeys.socialLoginuid)
         
            _ = navigationController?.popToRootViewController(animated: true)
           //self.dismiss(animated: false, completion: nil)
           //performSegue(withIdentifier: "segue", sender: user)
            
            
        default: break
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("something went wrong", error)
    }
}

extension SocialLoginViewController: ASAuthorizationControllerPresentationContextProviding{
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return view.window!
    }
}




class UserVC: UIViewController {
    var user: User?
    
    @IBOutlet var detailsLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        detailsLabel.text = user?.debugDescription ?? ""
    }
}

