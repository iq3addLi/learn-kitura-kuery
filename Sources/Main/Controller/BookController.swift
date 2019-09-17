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
        case .failure(let error): completion( nil, RequestError(rawValue: 401, reason: String(describing: error ) ) )
        }
        
    }
    
    func postBook( query: BookQuery, completion: ([Book]?, RequestError?) -> Void) {
        
        let book = Book(title: "Mituteru Yokoyama", author: "Masamune Date")
        completion( [book], nil )
    }
}
