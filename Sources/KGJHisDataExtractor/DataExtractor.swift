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
        let soureUrl = URL(fileURLWithPath: config.sharePath.source)
        
        print("[ INFO ] [soure: \(soureUrl.path)]")
        	
//        guard let emtor = fileMgr.enumerator(
//                at: soureUrl, // config.sharePath.source
//                includingPropertiesForKeys: nil,
//                options: .skipsHiddenFiles,
//                errorHandler: nil)
//        else {
//            print("[ ERROR ]: emtor is nil")
//            return
//        }
        
       
        
        try timeUtils.buildTargetTimes()
        
        let files: [URL] = try allFiles(in: soureUrl)
        
        print("[ INFO ] [\(files.count)] found.")
        
        let total = Double(files.count)
        var progress = 0.0
        let sp = Array(repeating: " ", count: 100).joined(separator: "")
        var lastPercent = 0
        var progressBar = "|"
        
        for f in files {
            guard timeUtils.isTargetFile(name: f.lastPathComponent) else { continue }
            let newFilePath = try copy(file: f, from: config.sharePath.source, to: config.sharePath.dist)
            
            progress += 1
            let percent = Int(progress / total * 100)
            if (percent - lastPercent) >= 1 {
                lastPercent = percent
//                let progressBar = Array(repeating: "|", count: percent).joined(separator: "")
                progressBar += "|"
                print("\r Progress: \(progressBar) \(sp) \(percent)%", terminator: " ")
            }
        }
        
//        for case let e as URL in emtor {
//            guard let resValues = try? e.resourceValues(forKeys: resourceKeys),
//                  let isDir = resValues.isDirectory,
//                  let name = resValues.name else {
//                print("[ INFO ] Failed to get resourceValues of [\(e)]")
//                continue
//            }
//
//
//            if !isDir {
//                guard timeUtils.isTargetFile(name: name) else {
//                    continue
//                }
//
//                print("[ INFO ] [Matched file: \(name)]")
//
//                let newFilePath = try copy(file: e, from: config.sharePath.source, to: config.sharePath.dist)
//                print("[ INFO ] [\(name)] has been copied to [\(newFilePath.path)]")
//
//            }
//        } // for case let e
    } // func extract
    
    public func allFiles(in dir: URL) throws -> [URL] {
        let fm = FileManager.default
        guard fm.fileExists(atPath: dir.path) else {
            throw DataExtractorError.directoryNotExist(msg: dir.path)
        }
    
        var files: [URL] = []
        
        let allPath: [URL] = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.nameKey, .isDirectoryKey], options: .skipsHiddenFiles)
        print("[ INFO ] [allPath count: \(allPath.count)]")
        
        for path in allPath {
            guard let resValues = try? path.resourceValues(forKeys: [.nameKey, .isDirectoryKey]),
                  let isDir = resValues.isDirectory,
                  let name = resValues.name else {
                print("[ INFO ] Failed to get resourceValues of [\(path)]")
                continue
            }
            
            if isDir {
                let subPath: [URL] = try! allFiles(in: path)
                files.append(contentsOf: subPath)
            } else {
                files.append(path)
            }
        } // for path
        
        return files
    } // func allFiles
    
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
