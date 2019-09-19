//
//  DatabaseAccesser.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/17.
//

import Foundation
import SwiftKuery
import SwiftKueryMySQL
import Dispatch


class DatabaseAccesser{
    
    private lazy var connectionPool: ConnectionPool = {
        let option = ConnectionPoolOptions(initialCapacity: 10, maxCapacity: 50)
        return MySQLConnection.createPool(host: "127.0.0.1", user: "root", database: "mysql_test", poolOptions: option)
    }()
    
    // Release connection
    private func connectionByConnectionPool() throws -> ConnectionPoolConnection  {
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Result<ConnectionPoolConnection,Error>?
        connectionPool.getConnection { ( connectionOrNil, errorOrNil) in
            if let error = errorOrNil{
                result = .failure(error)
            }
            else if let connection = connectionOrNil{
                result = .success(connection)
            }
            else{
                result = .failure( ProjectError("Unexpected error.") )
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        switch result!{
        case .success(let connection): return connection
        case .failure(let error): throw error
        }
    }
    
    private func connect(by connection: ConnectionPoolConnection) throws {
        let semaphore = DispatchSemaphore(value: 0)
        
        var error: Error?
        connection.connect { (result) in
            if result.success == false{
                error = result.asError
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = error{
            throw error
        }
    }
    
    private func execute(by connection: ConnectionPoolConnection, query: Query) throws -> ResultSet? {
        let semaphore = DispatchSemaphore(value: 0)
        
        var result: Result<ResultSet?,Error>?
        connection.execute(query: query) { (queryResult) in
            if queryResult.success == false, let error = queryResult.asError{
                result = .failure(error)
            }else{
                result = .success(queryResult.asResultSet) // ResultSet is null when query’s type is insert.
            }
            semaphore.signal()
        }
        semaphore.wait()
        
        switch result!{
        case .success(let resultSet): return resultSet
        case .failure(let error): throw error
        }
    }
    
    private func create( table: Table, connection: ConnectionPoolConnection ) throws {
        let semaphore = DispatchSemaphore(value: 0)
    
        var error: Error?
        table.create( connection: connection ) { result in
            // Fail
            if result.success == false{
                error = ProjectError("Create table is failed. reason=\( String(describing: result.asError) )")
            }
            semaphore.signal()
        }
        semaphore.wait()
        if let error = error{
            throw error
        }
    }
    
    func databaseInitialize() -> Error? {

        do {
            let connection = try connectionByConnectionPool()
            try connect(by: connection)
            let table = BookTable()
            do{
                // Find table type
                let query = Select(from: table)
                _ = try self.execute(by: connection, query: query)
            }catch( let queryError as QueryError ){
                if case .databaseError = queryError{ // "The operation couldn’t be completed. (SwiftKuery.QueryError error 2.)"
                    // if table not found then create table.
                    try create(table: table, connection: connection)
                }
            }
        } catch (let error){
            return error
        }
        return nil
    }
        
//            // Release connection
//            connectionPool.getConnection { ( connectionOrNil, errorOrNil) in
//                guard let connection = connectionOrNil else{ error = errorOrNil; semaphore.signal(); return }
//                // Connect
//                connection.connect { result in
//                    // Fail with abort
//                    guard result.success else { semaphore.signal(); return }
//                    // Find table type
//                    let table: Table
//                    do {
//                        table = try BookRow.getTable()
//                    }catch( let e ){
//                        error = e; semaphore.signal(); return
//                    }
//                    // Find Table
//                    connection.execute(query: Select(from: table)) { result in
//                        // Table is found. normal finish.
//                        if result.success { semaphore.signal(); return }
//                        // Create table
//                        table.create(connection: connection) { result in
//                            // OK
//                            if result.success { semaphore.signal(); return }
//                            // Fail
//                            error = result.asError; semaphore.signal()
//                        }
//                    }
//                }
//            }
//            semaphore.wait()
//
//        return error
    
    func searchBook( query: BookQuery ) -> Result<[BookModel],Error>{
        do {
            // release connection by connection pool
            let connection = try connectionByConnectionPool()
            
            // Connect
            try connect(by: connection)
            
            // Create Query
            let table = BookTable()
            var select = Select(table.title, table.author, from: table)
                .where( table.title == query.title && table.author == query.author )
            
            if let limit = query.limit {
                select = select.limit(to: limit)
            }
            if let offset = query.offset {
                select = select.offset(offset)
            }
            
            // Execute query
            guard let resultSet = try self.execute(by: connection, query: select) else{
                return .failure(ProjectError("Unexpected error."))
            }
            
            // Get result
            var models:[BookModel] = []
            resultSet.forEach { (rowsOrNil, errorOrNil) in
                if errorOrNil != nil{
                    return
                }
                guard let rows = rowsOrNil as? [BookModel] else{ return }
                models = rows
            }
//            resultSet.nextRow { (rowsOrNil, errorOrNil) in
//                if errorOrNil != nil{
//                    return
//                }
//                guard let rows = rowsOrNil as? [BookModel] else{ return }
//                models = rows
//            }
            // Done connection
            resultSet.done()
            
            // Successed
            return .success(models)
        } catch (let error){
            // Failed
            return .failure(error)
        }
    }
    
    func insertBook( query: BookQuery ) -> Result<GeneralResult,Error>{
        do {
            // Release connection by connection pool
            let connection = try connectionByConnectionPool()
            
            // Connect
            try connect(by: connection)
            
            // Create Query
            let table = BookTable()
            let insert = Insert(into: table, columns: [table.title, table.author], values: [query.title, query.author])
            
            // Execute query
            _ = try execute(by: connection, query: insert) // Expect return value is nil
            
            // Successed
            return .success(GeneralResult("Insert is successed."))
        } catch (let error){
            // Failed
            return .failure(error)
        }
    }
    
    func deleteBook( identifier: String ) -> Result<GeneralResult,Error>{
        do {
            // Release connection by connection pool
            let connection = try connectionByConnectionPool()
            
            // Connect
            try connect(by: connection)
            
            // Create Query
            let table = BookTable()
            let delete = Delete(from: table)
                            .where( table.id == identifier )
            
            // Execute query
            _ = try execute(by: connection, query: delete) // Expect return value is nil
            
            // Successed
            return .success(GeneralResult("Delete is successed."))
        } catch (let error){
            // Failed
            return .failure(error)
        }
    }
    
    func updateBook( identifier: String, query: BookQuery ) -> Result<GeneralResult,Error>{
        do {
            // Release connection by connection pool
            let connection = try connectionByConnectionPool()
            
            // Connect
            try connect(by: connection)
            
            // Create Query
            let table = BookTable()
            let update = Update(table, set: [(table.title, query.title), (table.author, query.author)])
                                .where( table.id == identifier )
            
            // Execute query
            _ = try execute(by: connection, query: update) // Expect return value is nil
            
            // Successed
            return .success(GeneralResult("Update is successed."))
        } catch (let error){
            // Failed
            return .failure(error)
        }
    }
}
