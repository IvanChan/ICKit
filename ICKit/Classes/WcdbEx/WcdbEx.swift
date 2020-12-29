//
//  WcdbEx.swift
//  ICKit
//
//  Created by _ivanC on 02/01/2020.
//  Copyright © 2018 Ico. All rights reserved.
//

import Foundation
import WCDBSwift

public struct ICDatabaseTable<Root: TableDecodable> {
      public enum TableType {
        case cache
        case content
        case user
        
        func database() throws -> Database {
            switch self {
            case .cache: return try ICDatabase.cacheDatabase()
            case .content: return try ICDatabase.contentDatabase()
            case .user: return try ICDatabase.userDatabase()
            }
        }
    }
    public private(set) var tablename:String
    public private(set) var tableType:TableType
    public private(set) var rootType: Root.Type
    
    public init(tablename:String, tableType:TableType, rootType:Root.Type) {
        self.tablename = tablename
        self.tableType = tableType
        self.rootType = rootType
    }
    
    public func database() throws ->Database {
        return try tableType.database()
    }
    
    public func create() {
        do {
            try database().create(table: tablename, of: rootType)
        } catch {
            print("\(error)")
        }
    }
    
    public func drop() throws {
        try database().drop(table: tablename)
    }
    
    public func getObjects<Object>(on propertyConvertibleList: [PropertyConvertible], where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws -> [Object] where Object : TableDecodable {
        return try database().getObjects(on: propertyConvertibleList, fromTable: tablename, where: condition, orderBy: orderList, limit: limit, offset: offset)
    }
    
    public func getObjects<Object>(on propertyConvertibleList: PropertyConvertible..., where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws -> [Object] where Object : TableDecodable {
        return try getObjects(on: propertyConvertibleList.isEmpty ? Object.Properties.all : propertyConvertibleList, where: condition, orderBy: orderList, limit: limit, offset: offset)
    }
    
    public func getObject<Object>(on propertyConvertibleList: [PropertyConvertible], where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, offset: Offset? = nil) throws -> Object? where Object : TableDecodable {
        return try database().getObject(on: propertyConvertibleList, fromTable: tablename, where: condition, orderBy: orderList, offset: offset)
    }
    
    public func getObject<Object>(on propertyConvertibleList: PropertyConvertible..., where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, offset: Offset? = nil) throws -> Object? where Object : TableDecodable {
        return try getObject(on: propertyConvertibleList.isEmpty ? Object.Properties.all : propertyConvertibleList, where: condition, orderBy: orderList, offset: offset)
    }
    
    public func insert<Object>(objects: [Object], on propertyConvertibleList: [PropertyConvertible]? = nil) throws where Object : TableEncodable {
        return try database().insert(objects: objects, on: propertyConvertibleList, intoTable: tablename)
    }
    
    public func insertOrReplace<Object>(objects: [Object], on propertyConvertibleList: [PropertyConvertible]? = nil) throws where Object : TableEncodable {
        return try database().insertOrReplace(objects: objects, on: propertyConvertibleList, intoTable: tablename)
    }
    
    public func insert<Object>(objects: Object..., on propertyConvertibleList: [PropertyConvertible]? = nil) throws where Object : TableEncodable {
        return try database().insert(objects: objects, on: propertyConvertibleList, intoTable: tablename)
    }
    
    public func insertOrReplace<Object>(objects: Object..., on propertyConvertibleList: [PropertyConvertible]? = nil) throws where Object : TableEncodable {
        return try database().insertOrReplace(objects: objects, on: propertyConvertibleList, intoTable: tablename)
    }
    
    public func delete(where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws {
        return try database().delete(fromTable: tablename, where: condition, orderBy: orderList, limit:limit, offset: offset)
    }
    
    public func getValue(on result: ColumnResultConvertible, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws -> WCDBSwift.FundamentalValue {
        return try database().getValue(on: result, fromTable: tablename, where: condition, orderBy: orderList, limit:limit, offset: offset)
    }

    public func update<Object>(on propertyConvertibleList: [PropertyConvertible], with object: Object, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws where Object : TableEncodable {
        return try database().update(table: tablename, on: propertyConvertibleList, with: object, where: condition, orderBy: orderList, limit: limit, offset: offset)
    }
    
    public func update<Object>(on propertyConvertibleList: PropertyConvertible..., with object: Object, where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws where Object : TableEncodable {
        return try database().update(table: tablename, on: propertyConvertibleList.isEmpty ? Object.Properties.all : propertyConvertibleList, with: object, where: condition, orderBy: orderList, limit: limit, offset: offset)
    }
    
    public func update(on propertyConvertibleList: PropertyConvertible..., with row: [ColumnEncodable], where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws {
        return try database().update(table: tablename, on: propertyConvertibleList, with: row, where: condition, orderBy: orderList, limit: limit, offset: offset)
    }
    
    public func update(on propertyConvertibleList: [PropertyConvertible], with row: [ColumnEncodable], where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws {
        return try database().update(table: tablename, on: propertyConvertibleList, with: row, where: condition, orderBy: orderList, limit: limit, offset: offset)
    }
    
    public func count(on result: ColumnResultConvertible = Column.all.count(), where condition: Condition? = nil, orderBy orderList: [OrderBy]? = nil, limit: Limit? = nil, offset: Offset? = nil) throws -> WCDBSwift.FundamentalValue {
        return try getValue(on: result, where: condition, orderBy: orderList, limit: limit, offset: offset)
    }
    
    public func objectExist(where condition: Condition) -> Bool {
        do {
            let objCount = try count(where: condition)
            return objCount.int64Value > 0
        } catch {
            print("\(error)")
        }
        
        return false
    }
}

public class ICDatabase {
    
    /// Clear as you like
    public static let cache:ICDatabase = ICDatabase()
    
    /// NOT that important, might clear
    public static let content:ICDatabase = ICDatabase()
    
    /// persistent, can NOT clear
    public static let user:ICDatabase = ICDatabase(isBackupEnabled:true)
    
    private var _database:Database?
    public func database() throws -> Database {
        if let database = _database {
            return database
        }
        throw NSError(domain: "ICDatabase", code: -600, userInfo: [NSLocalizedDescriptionKey:"\(dbName) use before initialized"])
    }
    
    private var isBackupEnabled:Bool
    init(isBackupEnabled:Bool = false) {
        self.isBackupEnabled = isBackupEnabled
    }
    
    private var dbPath:String = ""
    private var dbName:String = ""
    func load(with path:String) {
        close()
        
        if path.count > 0 {
            dbPath = path
            dbName = dbPath.ic.lastPathComponent
            _database = Database(withPath: path)
        }
    }
    
    func close() {
        _database?.close()
        _database = nil;
    }
    
    public func createTable<Root>(_ tablename: String, of rootType: Root.Type) where Root : TableDecodable {
        do {
            try database().create(table: tablename, of: rootType)
        } catch {
            print("\(error)")
        }
    }
    
    public func reset() {
        close()
        try? FileManager.default.removeItem(atPath: dbPath)
        load(with: dbPath)
    }
    
    private var backupTimer:Timer?
    private func startBackup() {
        stopBackup()
        
        guard isBackupEnabled else {return}
        
        backupTimer = Timer.scheduledTimer(withTimeInterval: 5 * 60, repeats: true, block: { [weak self] (_) in
            try? self?.database().backup()
        })
    }
    
    private func stopBackup() {
        backupTimer?.invalidate()
        backupTimer = nil
    }
    
    public func recover(_ completion: @escaping (Bool)->Void) {
        guard let db = _database else {
            completion(false)
            return
        }
        
        DispatchQueue.global(qos: .background).async { [weak self] in
            guard let self = self else {return}
            
            self.close()
            
            let dbDir = self.dbPath.ic.stringByDeletingLastPathComponent
            let tempDir = dbDir.ic.stringByAppendingPathComponent(path: "broken_\(Date.timeIntervalSinceReferenceDate)")
            ICPathUtil.createDirectoryIfNeeded(tempDir)
            
            try? db.moveFiles(toDirectory: tempDir, withExtraFiles: [])
            
            
            let newDatabase = Database(withPath: self.dbPath)
            
            // TODO: need to create all table before recover
            let oldDBPath = tempDir.ic.stringByAppendingPathComponent(path: self.dbName)
            try? newDatabase.recover(fromPath: oldDBPath)
            
            try? db.removeFiles()
            
            self._database = newDatabase
            self.startBackup()
            DispatchQueue.main.async {
                completion(true)
            }
        }
    }
}

extension ICDatabase {
    class func userDatabase() throws -> Database {
        return try ICDatabase.user.database()
    }
    
    class func contentDatabase() throws -> Database {
        return try ICDatabase.content.database()
    }
    
    class func cacheDatabase() throws -> Database {
        return try ICDatabase.cache.database()
    }
}

public class DatabaseManager: NSObject {

    @discardableResult class public func loadUserDatabase(_ username:String) -> Bool {
        guard username.count > 0 else {
            return false
        }
        
        closeUserDatabase()

        let path = ICPathUtil.librarySubDir(with: "Database")
        
        let cacheDBPath = path.ic.stringByAppendingPathComponent(path: "cache/cache.db")
        ICDatabase.cache.load(with: cacheDBPath)
        
        let contentDBPath = path.ic.stringByAppendingPathComponent(path: "content/content.db")
        ICDatabase.content.load(with: contentDBPath)
        
        let userDBPath = path.ic.stringByAppendingPathComponent(path: "user/user.db")
        ICDatabase.user.load(with: userDBPath)

        return true
    }
    
    class public func closeUserDatabase() {
        ICDatabase.cache.close()
        ICDatabase.content.close()
        ICDatabase.user.close()
    }
}
