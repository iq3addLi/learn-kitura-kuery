//
//  BookController.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/17.
//

import Foundation
import KituraContracts

struct BookController{
    
    let accesser = DatabaseAccesser()
    
    init(){
        if let error = accesser.databaseInitialize(){
            print(error)
        }
    }
    
    func getBook( query: BookQuery, completion: ([BookModel]?, RequestError?) -> Void) {
        
        switch accesser.searchBook(query: query){
        case .success(let books): completion( books, nil )
        case .failure(let error): completion( nil, RequestError(rawValue: 500, reason: String(describing: error ) ) )
        }
        
    }
    
    func postBook( query: BookQuery, completion: (GeneralResult?, RequestError?) -> Void) {
        
        switch accesser.insertBook(query: query){
        case .success(let result): completion( result, nil )
        case .failure(let error): completion( nil, RequestError(rawValue: 500, reason: String(describing: error ) ) )
        }
    }
    
    func deleteBook( id: Int, completion: (RequestError?) -> Void) {
        
        switch accesser.deleteBook(identifier: id.value){
        case .success: completion( nil )
        case .failure(let error): completion( RequestError(rawValue: 500, reason: String(describing: error ) ) )
        }
    }
    
    func deleteBookWithQuery( search: BookSearchQuery, completion: (RequestError?) -> Void) {
        
        switch accesser.deleteBook(identifier: search.id){
        case .success: completion( nil )
        case .failure(let error): completion( RequestError(rawValue: 500, reason: String(describing: error ) ) )
        }
    }
    
    func updateBook( id: Int, query: BookQuery, completion: (GeneralResult?, RequestError?) -> Void) {
        
        switch accesser.updateBook(identifier: id.value, query: query) {
        case .success(let result): completion( result, nil )
        case .failure(let error): completion( nil, RequestError(rawValue: 500, reason: String(describing: error ) ) )
        }
    }
}
