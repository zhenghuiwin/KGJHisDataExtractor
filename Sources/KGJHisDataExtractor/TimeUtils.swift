//
//  File.swift
//  
//
//  Created by zhenghuiwin on 2021/3/13.
//

import Foundation

public class TimeUtils {
    
    private static let timesFile = "./conf/times.txt"
    private static let processedTimesFile = "./conf/times2.txt"
    
    // key: year, like "2018", "2019"
    // value: Array of months, index 1 represents January, index 12 represents December.
    // The elements of array are days of the corresponding month, but not all days.
    private var targetTimes: [String : [Set<String>?]] = [:]
    
    
    private let fmt: DateFormatter = {
       let f = DateFormatter()
        f.dateFormat = "yyyy-MM-dd"
        f.timeZone = TimeZone(secondsFromGMT: (8 * 60 * 60))
        return f
    }()
    
    private let fmt2: DateFormatter = {
       let f = DateFormatter()
        f.dateFormat = "yyyy-M-d"
        f.timeZone = TimeZone(secondsFromGMT: (8 * 60 * 60))
        return f
    }()
    
    private let fmtFileName: DateFormatter = {
       let f = DateFormatter()
        f.dateFormat = "yyMMdd"
        f.timeZone = TimeZone(secondsFromGMT: (8 * 60 * 60))  // UTC+8
        return f
    }()
    
    public init() {}
    
    /// Preprocess the `times.txt`.
    /// The time recorded in the output new file `times2.txt` is already sorted.
    /// - Throws: 1. Failed to load contents from the `times.txt`
    ///           2. Failed to write contents to the  `times2.txt`
    public static func preprocessTimes() throws {
//        let fileMgr = FileManager.default
        
        let timesCont = try String(contentsOfFile: TimeUtils.timesFile, encoding: String.Encoding.utf8)
        let lines = timesCont.split(separator: "\n")
        
        var times: [Substring] = []
        for line in lines {
            let timesInLine = line.split(separator: " ")
            for t in timesInLine {
                times.append(t)
            }
        }
        
        let sortedTiems = times.sorted { (s0, s1) -> Bool in
            return s0 <= s1
        }
        
        let newTimesCont = sortedTiems.joined(separator: "\n")
        
        try newTimesCont.write(toFile: TimeUtils.processedTimesFile, atomically: false, encoding: String.Encoding.utf8)
    }
    
    /// Preprocess the `times.txt`.
    /// The time recorded in the output new file `times2.txt` is already sorted.
    /// - Throws: 1. Failed to load contents from the `times.txt`
    ///           2. Failed to write contents to the  `times2.txt`
    public func preprocessTimes2() throws {
        let cnt = try String(contentsOfFile: TimeUtils.timesFile)
        let lines = cnt.split(separator: "\n")
        
        let cal = Calendar.current
        var times: Set<String> = []
        for line in lines {
            guard let currDate = fmt2.date(from:  line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) else {
                print("[ ERROR ] Failed to convert to date from: \(line)")
                continue
            }
            guard let bf1Date = cal.date(byAdding: .day, value: -1, to: currDate),
                  let bf2Date = cal.date(byAdding: .day, value: -2, to: currDate),
                  let aftDate = cal.date(byAdding: .day, value: 1, to: currDate) else {
                print("[ ERROR ] Failed to calculate the new dates from: \(currDate)")
                continue
            }
            
            times.insert(fmt.string(from: bf2Date))
            times.insert(fmt.string(from: bf1Date))
            times.insert(fmt.string(from: currDate))
            times.insert(fmt.string(from: aftDate))
        }
        
        let out = times.sorted { (t0, t1) -> Bool in
            return t0 <= t1
        }.joined(separator: "\n")
        
        try out.write(toFile: TimeUtils.processedTimesFile, atomically: false, encoding: String.Encoding.utf8)
    }
    
    public func buildTargetTimes() throws {
        let cnt = try String(contentsOfFile: TimeUtils.processedTimesFile)
        
        let cal = Calendar.current
        let comps: Set<Calendar.Component> = [.year, .month, .day]
        
        let lines = cnt.split(separator: "\n")
        for line in lines {
            guard let d = fmt.date(from: line.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)) else { continue }
            let dateComps = cal.dateComponents(comps, from: d)
            guard let year = dateComps.year,
                  let month = dateComps.month,
                  let day = dateComps.day else {
                print("-------- [Can not be parsed to date: \(line)] ----------")
                continue
            }
            
            let yearStr = String(year)
            if var m = targetTimes[yearStr] {
                if var days = m[month] {
                    days.insert(String(day))
                    m[month] = days
                } else {
                    m[month] = [String(day)]
                }
                targetTimes.updateValue(m, forKey: yearStr)
            } else {
                // m is nil, [0, 1, ..., 12]
                var m: [Set<String>?] = Array(repeating: nil, count: 13)
                m[month] = [String(day)]
                targetTimes.updateValue(m, forKey: yearStr)
            } // var m
        } // for line
        
//        var sum = 0
//        for y in ["2016", "2017", "2018", "2019", "2020"] {
//            guard let months = targetTimes[y] else { continue }
//            for m in months where m != nil {
//                
//                sum += m!.count
//            }
//        }
//        
//        print("Sum: \(sum)")
    } // func buildTargetTimes
    
    
    /// Check whether the data time of file is within the  target time range.
    /// - Parameter name: The file name,only the name ! The name of file usually looks like this: 18092608.000
    /// - Returns: True: in; False not in
    public func isTargetFile(name: String) -> Bool {
        guard targetTimes.count > 0 else {
            print("[ ERROR ] Should call buildTargetTimes() first!")
            return false
        }
        
        
        let file = name.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        guard file.count == 12 else {
            print("[ ERROR ] The count of file must be 12, looks like: `18092608.000`.")
            return false
        }
        
        let parts = file.split(separator: ".")
        guard parts.count >= 2 else {
            print("[ ERROR ] The file name format must be yyMMddhh.hhh")
            return false
        }
        
        guard parts[1] <= "060" else {
            return false
        }
        
        let num = 6
        let s = file.startIndex
        let dataDateOfFile = file[s ..< file.index(s, offsetBy: num)]
        guard let date = fmtFileName.date(from: String(dataDateOfFile)) else {
            print("[ ERROR ] Failed to convert to date from the name of file: \(file).")
            return false
        }
        
        let cal = Calendar.current
        let comp = cal.dateComponents([.year, .month, .day], from: date)
        guard let year = comp.year,
              let month = comp.month,
              let day = comp.day else {
            print("[ ERROR ] Failed to get the year, month, day from the date of the file name: \(file).")
            return false
        }
        
        // targetTimes: [String : [Set<String>?]] = [:]
        guard let aYear = targetTimes[String(year)],
              let aMonth = aYear[month],
              aMonth.contains(String(day)) else {
            return false
        }
        
        return true
        
    }
}



