///Users/zhenghuiwin/Dropbox/workspace/swift_on_server/KGJHisDataExtractor/Sources
//  File.swift
//  
//
//  Created by zhenghuiwin on 2021/3/17.
//

import Foundation

public class ProgressBar {
    var total = 0.0
    var progress = 0.0
    var lastProgress = 0.0
    
    let sp = Array(repeating: " ", count: 100).joined(separator: "")
    var lastPercent: Int = 0
    var progressBar = ""
    var delta: Int = 0
    
    public init(count: Int) {
        total = Double(count)
        delta = Int(total * 0.01)
        print("delta: \(delta)")
    }
    
    public func add(progress: Int, msg: String = "") {
        self.progress += Double(progress)
        
//        print("Int(self.progress - lastProgress): \(Int(self.progress - lastProgress)), self.progress: \(self.progress), lastProgress: \(lastProgress)")
        
        if Int(self.progress - lastProgress) >= delta {
            lastProgress = self.progress
            let percent = Int(self.progress / total * 100)
            progressBar = Array(repeating: "|", count: percent).joined()
            print("\r\(msg):\(progressBar) \(percent)%", terminator: " ")
//            Thread.sleep(forTimeInterval: 1)
        }

       
    }
}
