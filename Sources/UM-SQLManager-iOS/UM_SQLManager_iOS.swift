// The Swift Programming Language
// https://docs.swift.org/swift-book

import Foundation
import SQLite3

/// UMSQLManager 관련 오류
public enum UMSQLError: Error {
    case connectionError
    case preparationError
    case executionError(message: String)
    case commitError
    case rollbackError
    case bindingError
    
    var localizedDescription: String {
        switch self {
        case .connectionError:
            return "Database Connection Error"
        case .bindingError:
            return "Types not supported for query binding"
        default:
            return ""
        }
    }
    
    static func makeExecutationError(query: String, parameters: [Any]?) -> Self {
        
        var message: String = "Failed to executeQuery"
        
        if !query.isEmpty {
            message += "\nquery: \(query)"
        }
        
        if !(parameters?.isEmpty ?? false) {
            message += "\nparameters: \(parameters?.description ?? "")"
        }
        
        return .executionError(
            message: message
        )
    }
}

public class UMSQLManager {
    
    private var db: OpaquePointer?
    
    deinit {
        closeDatabase()
    }
    
    /// 데이터베이스 연결 메서드
    public func connectToDatabase(at path: String) throws {
        
        let flags = SQLITE_OPEN_CREATE | SQLITE_OPEN_READWRITE | SQLITE_OPEN_FULLMUTEX
        
        if sqlite3_open_v2(path, &db, flags, nil) != SQLITE_OK {
            throw UMSQLError.connectionError
        } else {
            print("Successfully connected to database at \(path)")
        }
    }
    
    /// 데이터베이스 연결 해제 메서드
    public func closeDatabase() {
        if db != nil {
            sqlite3_close(db)
        }
    }
    
    /// SQL 실행 (INSERT, UPDATE, DELETE)
    public func execute(_ query: String, parameters: [[NSObject]]? = nil) throws {
        var statement: OpaquePointer?
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            throw UMSQLError.preparationError
        }
        
        if let parameters = parameters {
            for params in parameters {
                try bindParameters(statement, params)
                
                if sqlite3_step(statement) != SQLITE_DONE {
                    throw UMSQLError.makeExecutationError(
                        query: query,
                        parameters: params
                    )
                }
                
                if sqlite3_reset(statement) != SQLITE_OK {
                    throw UMSQLError.makeExecutationError(
                        query: query,
                        parameters: params
                    )
                }
            }
        } else {
            
            if sqlite3_step(statement) != SQLITE_DONE {
                throw UMSQLError.makeExecutationError(
                    query: query,
                    parameters: parameters
                )
            }
            
        }
        
        sqlite3_finalize(statement)
    }
    
    /// transaction을 활용한 execute
    public func executeWithTansaction(_ query: String, parameters: [[NSObject]]? = nil) throws {
        do {
            try beginTransaction()
            try execute(query, parameters: parameters)
            try commitTransaction()
        } catch {
            try rollbackTransaction()
            throw error
        }
    }
    
    /// SQL조회(SELECT) 메서드
    public func query(_ query: String, parameters: [NSObject]? = nil) throws -> [[String: Any]] {
        var statement: OpaquePointer?
        var result = [[String: Any]]()
        
        if sqlite3_prepare_v2(db, query, -1, &statement, nil) != SQLITE_OK {
            throw UMSQLError.preparationError
        }
        
        try bindParameters(statement, parameters)
        
        while sqlite3_step(statement) == SQLITE_ROW {
            var row = [String: Any]()
            let columnCount = sqlite3_column_count(statement)
            
            for i in 0..<columnCount {
                let columnName = String(cString: sqlite3_column_name(statement, i))
                let columnType = sqlite3_column_type(statement, i)
                
                switch columnType {
                case SQLITE_INTEGER:
                    row[columnName] = sqlite3_column_int64(statement, i)
                case SQLITE_FLOAT:
                    row[columnName] = sqlite3_column_double(statement, i)
                case SQLITE_TEXT:
                    row[columnName] = String(cString: sqlite3_column_text(statement, i))
                case SQLITE_NULL:
                    row[columnName] = nil
                default:
                    row[columnName] = nil
                }
            }
            
            result.append(row)
        }
        
        sqlite3_finalize(statement)
        return result
    }
    
    /// 파라미터 bind 메서드
    private func bindParameters(_ statement: OpaquePointer?, _ parameters: [NSObject]?) throws {
        
        guard let parameters = parameters else {
            return
        }
        
        for (index, param) in parameters.enumerated() {
            let index = Int32(index + 1)
            
            if let stringParam = param as? NSString {
                sqlite3_bind_text(statement, index, stringParam.utf8String, -1, nil)
            } else {
                throw UMSQLError.bindingError
            }
        }
    }
}

/// Transaction
public extension UMSQLManager {
    
    /// 트랜젝션 시작
    func beginTransaction() throws {
        if sqlite3_exec(db, "BEGIN TRANSACTION", nil, nil, nil) != SQLITE_OK {
            throw UMSQLError.executionError(message: "Failed to begin transaction")
        }
    }
    
    /// 커밋 트랜젝션
    func commitTransaction() throws {
        if sqlite3_exec(db, "COMMIT", nil, nil, nil) != SQLITE_OK {
            throw UMSQLError.commitError
        }
    }
    
    /// 트랜젝션 롤백
    private func rollbackTransaction() throws {
        if sqlite3_exec(db, "ROLLBACK TRANSACTION", nil, nil, nil) != SQLITE_OK {
            throw UMSQLError.rollbackError
        }
    }
}
