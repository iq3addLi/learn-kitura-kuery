//
//  BookQuery.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/17.
//

import Foundation

struct BookQuery{
    let title: String
    let author: String
    let limit: Int?
    let offset: Int?
}


import KituraContracts

extension BookQuery: QueryParams{}

struct BookSearchQuery{
    let id: String
}

extension BookSearchQuery: QueryParams{}
