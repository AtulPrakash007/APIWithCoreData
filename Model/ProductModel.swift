//
//  ProductModel.swift
//  APIWithCoreData
//
//  Created by Atul on 28/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import Foundation

struct Variants {
    var id: String?
    var name: String?
    var size: String?
    var price: String?
}

struct Products {
    var id: String?
    var name: String?
    var variants: [Variants]
}

struct ChildCategories {
    var id: String?
}

struct Categories {
    var id: String?
    var name: String?
    var products: [Products]
    var childCategories: [ChildCategories]
}

class Category {
    var id: String?
    var name: String?
    var products = [Products]()
    var childCategories = [ChildCategories]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["categories"] as? [String: Any] {
                
                print(body)
//                self.fullName = body["fullName"] as? String
//                self.pictureUrl = body["pictureUrl"] as? String
//                self.about = body["about"] as? String
//                self.email = body["email"] as? String
//
//                if let friends = body["friends"] as? [[String: Any]] {
//                    self.friends = friends.map { Friend(json: $0) }
//                }
//
//                if let profileAttributes = body["profileAttributes"] as? [[String: Any]] {
//                    self.profileAttributes = profileAttributes.map { Attribute(json: $0) }
//                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
    }
}
