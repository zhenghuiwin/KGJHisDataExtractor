import KGJHisDataExtractor
import Foundation



print("Hello, world!")

//let count = 100001
//let progressBar = ProgressBar(count: count)
//for _ in 1 ... count {
//    Thread.sleep(forTimeInterval: 0.000001)
//    progressBar.add(progress: 1)
//}
//
let timeUtils = TimeUtils()
let extor = DataExtractor()

do {
//    try timeUtils.buildTargetTimes()
    try extor.extract()
    print("\n [\(Date())] buildTargetTimes completed.")
} catch let e {
    print("\n[\(Date())][Error: \(e)]")
}
