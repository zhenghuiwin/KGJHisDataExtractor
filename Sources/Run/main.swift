import KGJHisDataExtractor



print("Hello, world!")

let timeUtils = TimeUtils()
let extor = DataExtractor()

do {
//    try timeUtils.buildTargetTimes()
    try extor.extract()
    print("buildTargetTimes completed.")
} catch let e {
    print("[Error: \(e)]")
}
