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
        
        print("[ INFO ] [\r\(files.count)] 文件预处理结束.")
        
        let proBar = ProgressBar(count: files.count)

        for f in files {
            guard timeUtils.isTargetFile(name: f.lastPathComponent) else { continue }
            let newFilePath = try copy(file: f, from: config.sharePath.source, to: config.sharePath.dist)
            
            proBar.add(progress: 1, msg: "[Copy]")
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
        
        let allPath: [URL] = try fm.contentsOfDirectory(at: dir, includingPropertiesForKeys: [.isDirectoryKey], options: .skipsHiddenFiles)
        print("[ INFO ] [allPath count: \(allPath.count)]")
        
        let bar = ProgressBar(count: allPath.count)
        
        let sourceKey: Set<URLResourceKey> = [.isDirectoryKey]
        
        for path in allPath {
            guard let resValues = try? path.resourceValues(forKeys: sourceKey),
                  let isDir = resValues.isDirectory else {
                print("[ INFO ] Failed to get resourceValues of [\(path)]")
                continue
            }
            
            if isDir {
                let subPath: [URL] = try! allFiles(in: path)
                files.append(contentsOf: subPath)
            } else {
                files.append(path)
                bar.add(progress: 1, msg: "[预处理 \(dir.path)]")
            }
        } // for path
        
        print("[\(Date())][\(allPath.count)]: preprocessing completed.[in func allFiles]")
        
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
