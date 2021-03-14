//
//  File.swift
//  
//
//  Created by zhenghuiwin on 2021/3/12.
//

import Foundation

public class DataExtractor {

    private static let configPath = "./conf/sharePath.json"
    
    public init() {}
    
    
    
    
    public func extract() throws {
        let config = try Config.load(from: DataExtractor.configPath)
        
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        let fileMgr = FileManager.default
        
        guard let emtor = fileMgr.enumerator(
                at: URL(fileURLWithPath: "./"), // config.sharePath.source
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles,
                errorHandler: nil)
        else {
            print("Error: emtor is nil")
            return
        }
        
        for case let e as URL in emtor {
            guard let resValues = try? e.resourceValues(forKeys: resourceKeys),
                  let isDir = resValues.isDirectory,
                  let name = resValues.name else {
                continue
            }
            
            if !isDir {
                print("[path: \(e.path)] [name: \(name)] [Parent path: \(e.deletingLastPathComponent().relativePath)]")
            }
//            if let u = e as? URL {
//
//            } // if let
        }
        
        
    }
}
