import XCTest
import class Foundation.Bundle
import KGJHisDataExtractor

final class KGJHisDataExtractorTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.

        // Some of the APIs that we use below are available in macOS 10.13 and above.
        guard #available(macOS 10.13, *) else {
            return
        }

        let fooBinary = productsDirectory.appendingPathComponent("KGJHisDataExtractor")

        let process = Process()
        process.executableURL = fooBinary

        let pipe = Pipe()
        process.standardOutput = pipe

        try process.run()
        process.waitUntilExit()

        let data = pipe.fileHandleForReading.readDataToEndOfFile()
        let output = String(data: data, encoding: .utf8)

        XCTAssertEqual(output, "Hello, world!\n")
    }

    /// Returns path to the built products directory.
    var productsDirectory: URL {
      #if os(macOS)
        for bundle in Bundle.allBundles where bundle.bundlePath.hasSuffix(".xctest") {
            return bundle.bundleURL.deletingLastPathComponent()
        }
        fatalError("couldn't find the products directory")
      #else
        return Bundle.main.bundleURL
      #endif
    }
    
    func testFirst() {
        XCTAssertTrue(true)
    }
    
    func testTimeUtilsIsInTimeRange() throws {
        let timeUtil = TimeUtils()
        try timeUtil.buildTargetTimes()
        
        let ret = timeUtil.isTargetFile(name: "16081508.000")
        XCTAssertTrue(ret)
        
        let ret2 = timeUtil.isTargetFile(name: "16011008.000")
        XCTAssertFalse(ret2)
        
    }
    
    func testDataExtractorNewPath() {
        let file = "/the/old/path/to/the/data/file"
        let from = "/the/old/path/to/"
        let to   = "/the/new/path/to/"
        
        let extor = DataExtractor()
        let newPath = extor.newPath(for: file, from: from, to: to)
        
        XCTAssertEqual("/the/new/path/to/the/data/file", newPath)
    }

    static var allTests = [
        ("testFirst", testFirst),
        ("testTimeUtilsIsInTimeRange", testTimeUtilsIsInTimeRange),
        ("testDataExtractorNewPath", testDataExtractorNewPath),
    ]
}
