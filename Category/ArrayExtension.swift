//
//  ArrayExtension.swift
//  APIWithCoreData
//
//  Created by Atul on 29/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import Foundation

extension Array where Element: Equatable {
    
    func reorder(by preferredOrder: [Element]) -> [Element] {
        
        return self.sorted { (a, b) -> Bool in
            guard let first = preferredOrder.index(of: a) else {
                return false
            }
            
            guard let second = preferredOrder.index(of: b) else {
                return true
            }
            
            return first < second
        }
    }
}
