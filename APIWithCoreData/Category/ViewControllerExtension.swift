//
//  ViewControllerExtension.swift
//  APIWithCoreData
//
//  Created by Atul on 30/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import Foundation
import UIKit
import CoreData

let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

extension UIViewController {
    
    func saveCategoryData(with json:[[String: Any]]) -> Bool {
        
        for data in json {
            
            //Categories
            let cat = Categories(context: context)
            cat.id = (data["id"]! as? Int32)!
            cat.name = data["name"]! as? String
            if (data["child_categories"]! as AnyObject).count > 0 {
                cat.child = data["child_categories"]! as? NSObject
            }
            
            //Products
            let products = data["products"]! as! [[String: Any]]
            
            for product in products {
                let pro = Products(context: context)
                pro.id = (product["id"]! as? Int32)!
                pro.name = product["name"]! as? String
                
                //Variants
                let variants = product["variants"]! as! [[String: Any]]
                
                for variant in variants {
                    let vari = Variants(context: context)
                    vari.id = (variant["id"]! as? Int32)!
                    vari.color = variant["color"]! as? String
                    if let size = variant["size"]! as? Int32 {
                        vari.size = size
                    }
                    vari.price = (variant["price"]! as? Int32)!
                    pro.addToVariants(vari)
                }
                cat.addToProducts(pro)
            }
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed saving")
            return false
        }
        
    }
    
    func saveRankingData(with json:[[String: Any]]) -> Bool {
        let rank = Rankings(context: context)
        for data in json {
            
            //Rankings
            switch  data[kRanking] as! String {
            case kMostViewed:
                let arr = data[kProducts] as! [[String: Int]]
                let sortedArray = (arr as NSArray).sortedArray(using: [NSSortDescriptor(key: kViewCount, ascending: false)]) as! [[String: Int]]
                let value:[Int] = sortedArray.map{$0[kId]!}
                rank.mostviewed = value as NSObject
                
            case kMostOrdered:
                let arr = data[kProducts] as! [[String: Int]]
                let sortedArray = (arr as NSArray).sortedArray(using: [NSSortDescriptor(key: kOrderCount, ascending: false)]) as! [[String: Int]]
                let value:[Int] = sortedArray.map{$0[kId]!}
                rank.mostordered = value as NSObject
                
            case kMostShared:
                let arr = data[kProducts] as! [[String: Int]]
                let sortedArray = (arr as NSArray).sortedArray(using: [NSSortDescriptor(key: kSharedCount, ascending: false)]) as! [[String: Int]]
                let value:[Int] = sortedArray.map{$0[kId]!}
                rank.mostsahred = value as NSObject
                
            default:
                print("No Ranking")
            }
        }
        
        do {
            try context.save()
            return true
        } catch {
            print("Failed saving")
            return false
        }
        
    }
    
    func fetchCatDataFromDB() -> [Categories] {
        do {
            return try context.fetch(Categories.fetchRequest())
        } catch {
            print("Fetching Failed")
            return []
        }
    }
    
    func fetchRankDataFromDB() -> [Rankings] {
        do {
            return try context.fetch(Rankings.fetchRequest())
        } catch {
            print("Fetching Failed")
            return []
        }
    }
    
    func deleteAllRecords() {
        let fetchRequest1 = NSFetchRequest<NSFetchRequestResult>(entityName: "Categories")
        
        // Create Batch Delete Request
        let batchDeleteRequest1 = NSBatchDeleteRequest(fetchRequest: fetchRequest1)
        
        do {
            try context.execute(batchDeleteRequest1)
            try context.save()
        } catch {
            print("Failed Deleting Categories")
        }
        
        let fetchRequest2 = NSFetchRequest<NSFetchRequestResult>(entityName: "Products")
        
        // Create Batch Delete Request
        let batchDeleteRequest2 = NSBatchDeleteRequest(fetchRequest: fetchRequest2)
        
        do {
            try context.execute(batchDeleteRequest2)
            try context.save()
        } catch {
            print("Failed Deleting Products")
        }
        
        let fetchRequest3 = NSFetchRequest<NSFetchRequestResult>(entityName: "Variants")
        
        // Create Batch Delete Request
        let batchDeleteRequest3 = NSBatchDeleteRequest(fetchRequest: fetchRequest3)
        
        do {
            try context.execute(batchDeleteRequest3)
            try context.save()
        } catch {
            print("Failed Deleting Variants")
        }
    }
}
