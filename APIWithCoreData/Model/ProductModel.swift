//
//  ProductModel.swift
//  APIWithCoreData
//
//  Created by Atul on 28/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import Foundation

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
    
    init(json: [String: Any]) {
        self.id = json["id"] as? Int
        self.name = json["name"] as? String
        
        if let variants = json["variants"] as? [[String: Any]] {
            self.variants = variants.map { Variant(json: $0) }
        }
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
