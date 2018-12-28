//
//  RequestLocal.swift
//  APIWithCoreData
//
//  Created by Atul on 28/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import Foundation

public func dataFromFile(_ filename: String) -> Data? {
    
    if let path = Bundle.main.path(forResource: filename, ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
            return data
        } catch {
            return nil
            // handle error
        }
    }
    return nil
}
