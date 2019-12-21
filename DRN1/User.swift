//
//  User.swift
//  DRN1
//
//  Created by Russell Harrower on 18/12/19.
//  Copyright © 2019 Russell Harrower. All rights reserved.
//

import Foundation
import AuthenticationServices

struct User{
    var uid: String
    let id: String
    let firstName: String
    let lastName: String
    let email: String
    
    init(credentials: ASAuthorizationAppleIDCredential) {
        self.uid = credentials.user
        self.id = credentials.user
        self.firstName = credentials.fullName?.givenName ?? ""
        self.lastName = credentials.fullName?.familyName ?? ""
        self.email = credentials.email ?? ""
    }
}

extension User: CustomDebugStringConvertible{
    var debugDescription: String{
        return """
                ID: \(id)
                First Name: \(firstName)
                Last Name: \(lastName)
                Email Address: \(email)
            """
    }
}
