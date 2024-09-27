import XCTest
@testable import UM_SQLManager_iOS

final class UM_SQLManager_iOSTests: XCTestCase {
    
    var sqlManager: UMSQLManager!

    override func setUp() {
        super.setUp()
        sqlManager = UMSQLManager()
        try? sqlManager.connectToDatabase(at: ":memory:")
    }

    override func tearDown() {
        sqlManager.closeDatabase()
        sqlManager = nil
        super.tearDown()
    }

    func testCreateTable() {
        let createTableQuery = """
        CREATE TABLE IF NOT EXISTS friends (
            id CHAR(8),
            name VARCHAR(128),
            PRIMARY KEY(id)
          );
        """
        
        XCTAssertNoThrow(try sqlManager.execute(createTableQuery))
    }

    func testInsertOne() {
        
        testCreateTable()
        
        let insertQuery = """
        INSERT INTO friends (id, name)
        VALUES (?, ?);
        """
        
        XCTAssertNoThrow(
            try sqlManager.execute(
                insertQuery,
                parameters: [["1".toNSObject(), "John".toNSObject()]]
            )
        )

        let selectQuery = "SELECT * FROM friends;"
        let result = try? sqlManager.query(selectQuery)
        
        XCTAssertEqual(result?.first?["id"] as? String, "1")
        XCTAssertEqual(result?.first?["name"] as? String, "John")
        
        XCTAssertEqual(result?.count, 1)
    }
    
    func testInsertWithUpdate() {
        testCreateTable()
        
        let insertWithUpdateQuery = """
        INSERT INTO friends (id, name)
          VALUES(?, ?)
          ON CONFLICT(id) DO UPDATE SET name=?;
        """
        
        XCTAssertNoThrow(
            try sqlManager.execute(
                insertWithUpdateQuery,
                parameters: [["1".toNSObject(), "John".toNSObject()]]
            )
        )
        
        XCTAssertNoThrow(
            try sqlManager.execute(
                insertWithUpdateQuery,
                parameters: [["1".toNSObject(), "KANG".toNSObject(), "KANG".toNSObject()]]
            )
        )
        
        let selectQuery = "SELECT * FROM friends WHERE id = '1';"
        let result = try? sqlManager.query(selectQuery)
        
        XCTAssertEqual(result?.first?["name"] as? String, "KANG")
    }
    
    func testTransactionInsertAndFetch() {
        testCreateTable()
        
        XCTAssertNoThrow(
            try sqlManager.beginTransaction()
        )
        
        let insertWithUpdateQuery = """
        INSERT INTO friends (id, name)
          VALUES(?, ?)
          ON CONFLICT(id) DO UPDATE SET name=?;
        """
        
        let parameters = [
            ["1".toNSObject(), "John".toNSObject(), "John".toNSObject()],
            ["2".toNSObject(), "Jane".toNSObject(), "Jane".toNSObject()],
            ["3".toNSObject(), "Tom".toNSObject(), "Tom".toNSObject()],
            ["4".toNSObject(), "Jerry".toNSObject(), "Jerry".toNSObject()]
        ]
        
        XCTAssertNoThrow(
            try sqlManager.execute(insertWithUpdateQuery, parameters: parameters)
        )
        
        XCTAssertNoThrow(
            try sqlManager.commitTransaction()
        )
        
        let selectQuery = "SELECT * FROM friends;"
        
        let result = try? sqlManager.query(selectQuery)
        
        XCTAssertEqual(result?.count, 4)
        XCTAssertEqual(result?.first?["name"] as? String, "John")
        
    }
    
    func testWithTransactionRollBack() {
        testCreateTable()
        
        XCTAssertNoThrow(
            try sqlManager.beginTransaction()
        )
        
        let insertWithUpdateQuery = """
        INSERT INTO friends (id, name)
          VALUES(?, ?)
          ON CONFLICT(id) DO UPDATE SET name=?;
        """
        
        let parameters = [
            ["1".toNSObject(), "John".toNSObject(), "John".toNSObject()],
            ["2".toNSObject(), "Jane".toNSObject(), "Jane".toNSObject()],
            ["3".toNSObject(), "Tom".toNSObject(), "Tom".toNSObject()],
            ["4".toNSObject(), "Jerry".toNSObject(), "Jerry".toNSObject()],
            [1234567890.toNSObject(), "ErrorData".toNSObject(), "ErrorData".toNSObject()]
        ]
        
        try? sqlManager.executeWithTansaction(insertWithUpdateQuery, parameters: parameters)
        
        let selectQuery = "SELECT * FROM friends;"
        
        let result = try? sqlManager.query(selectQuery)
        
        XCTAssertEqual(result?.count, 0)
    }
}
