//
//  File.swift
//  
//
//  Created by zhenghuiwin on 2021/3/12.
//

import Foundation

public class DataExtractor {

    private static let configPath = "./conf/sharePath.json"
    
    private let timeUtils = TimeUtils()
    
    public init() {}
    
    
    
    
    public func extract() throws {
        let config = try Config.load(from: DataExtractor.configPath)
        
        let resourceKeys = Set<URLResourceKey>([.nameKey, .isDirectoryKey])
        let fileMgr = FileManager.default
        
        guard let emtor = fileMgr.enumerator(
                at: URL(fileURLWithPath: config.sharePath.source), // config.sharePath.source
                includingPropertiesForKeys: nil,
                options: .skipsHiddenFiles,
                errorHandler: nil)
        else {
            print("[ ERROR ]: emtor is nil")
            return
        }
        
        try timeUtils.buildTargetTimes()
        
        for case let e as URL in emtor {
            guard let resValues = try? e.resourceValues(forKeys: resourceKeys),
                  let isDir = resValues.isDirectory,
                  let name = resValues.name else {
                continue
            }
            
            if !isDir {
                guard timeUtils.isTargetFile(name: name) else {
                    continue
                }
                
                print("[ INFO ] Targert file name: \(name)")
                
                let newFilePath = try copy(file: e, from: config.sharePath.source, to: config.sharePath.dist)
                print("[ INFO ] [\(name)] has been copied to [\(newFilePath.path)]")
                
            }
        } // for case let e
    } // func extract
    
    private func copy(file: URL, from: String, to: String) throws -> URL {
        let newFilePath = newPath(for: file.path, from: from, to: to)
        let newFilePathUrl = URL(fileURLWithPath: newFilePath)
        
        let fm = FileManager.default
        guard !fm.fileExists(atPath: newFilePath) else {
            print("[ INFO ] The [\(file.path)] has already existed in: [\(newFilePath)]")
            return newFilePathUrl
        }
        
        
        let newDirForFile = newFilePathUrl.deletingLastPathComponent()
        try fm.createDirectory(at: newDirForFile, withIntermediateDirectories: true, attributes: nil)
        
        try fm.copyItem(at: file, to: newFilePathUrl)
        
        return newFilePathUrl
    }
    
    public func newPath(for filePath: String, from: String, to: String) -> String {
        let newPath = filePath.replacingOccurrences(of: from, with: to)
        return newPath
    }
}
