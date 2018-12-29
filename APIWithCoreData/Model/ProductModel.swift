//
//  ProductModel.swift
//  APIWithCoreData
//
//  Created by Atul on 28/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import Foundation

struct Variants {
    var id: Int?
    var name: String?
    var size: Int?
    var price: Int?
}

struct Products {
    var id: Int?
    var name: String?
    var variants: [Variants]
    var like_count: Int?
    var view_count: Int?
    var shared_count: Int?
}

struct ChildCategories {
    var id: String?
}

struct Categories {
    var id: Int?
    var name: String?
    var products: [Products]
    var childCategories: [Int]
}

class MapData {
    var items = [Category]()
    
    init?(data: Data) {
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                if let body = json["categories"] as? [[String: Any]] {
                    print(body)
                    self.items = body.map { Category(json: $0) }
                }
            }
        } catch {
            print("Error deserializing JSON: \(error)")
            return nil
        }
    }
    
}

class Category {
    var id: Int?
    var name: String?
    var products = [Product]()
    var childCategories = [Int]()
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int
        self.name = json["name"] as? String
        
        if let products = json["products"] as? [[String: Any]] {
            self.products = products.map { Product(json: $0) }
        }
        
        if let child = json["child_categories"] as? [Int] {
            self.childCategories = child
        }
        
    }
    
}

class Product {
    var id: Int?
    var name: String?
    var variants = [Variant]()
    var like_count: Int?
    var view_count: Int?
    var shared_count: Int?
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int
        self.name = json["name"] as? String
        
        if let variants = json["variants"] as? [[String: Any]] {
            self.variants = variants.map { Variant(json: $0) }
        }
        self.like_count = 0
        self.view_count = 0
        self.shared_count = 0
    }
}

class Variant {
    var id: Int?
    var color: String?
    var size: Int?
    var price: Int?
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int
        self.color = json["color"] as? String
        self.size = json["size"] as? Int
        self.price = json["price"] as? Int
    }
}

class Ranking {
    var id: Int?
    var count: Int?
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int
        self.count = json["color"] as? Int
    }
}
