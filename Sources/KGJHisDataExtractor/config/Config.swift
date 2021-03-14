//
//  File.swift
//  
//
//  Created by zhenghuiwin on 2021/3/12.
//

import Foundation

struct Config: Codable {
    let sharePath: SharePath
    
    static func load(from path: String) throws -> Config {
        let d = try Data(contentsOf: URL(fileURLWithPath: path))
        
//        if let s = String(data: d, encoding: String.Encoding.utf8) {
//            print("[sharpPath file: \(s)]")
//        }
        
        let decoder = JSONDecoder()
        let config = try decoder.decode(Config.self, from: d)
        
        return config
    }
}
