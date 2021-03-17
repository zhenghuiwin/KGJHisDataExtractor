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
    var delta = 0.0
    
    public init(count: Int) {
        total = Double(count)
        delta = total * 0.01
        print("[delta: \(delta), total: \(total)]")
    }
    
    public func add(progress: Int, msg: String = "") {
        self.progress += Double(progress)
        
//        print("Int(self.progress - lastProgress): \(Int(self.progress - lastProgress)), self.progress: \(self.progress), lastProgress: \(lastProgress)")
        
        if total.isLessThanOrEqualTo(self.progress) {
            progressBar = Array(repeating: "|", count: 100).joined()
            print("\r\(msg):\(progressBar) \(100)%", terminator: " ")
            return
        }
        
        if delta.isLessThanOrEqualTo((self.progress - lastProgress)) {
            let percent = Int(self.progress / total * 100)
//            print("\nprogress-lastProgress: \(self.progress - lastProgress), progress: \(self.progress), lastProgress: \(lastProgress), percent: \(percent)")
            
            progressBar = Array(repeating: "|", count: percent).joined()
            print("\r\(msg):\(progressBar) \(percent)%", terminator: " ")
            lastProgress = self.progress
        }
    }
}
