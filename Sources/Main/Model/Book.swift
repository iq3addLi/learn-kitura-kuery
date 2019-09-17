//
//  File.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/17.
//

import SwiftKuery
import SwiftKueryORM

public class BookTable: Table  {
    public let tableName = "Books"
    public let id = Column("id", Int32.self, primaryKey: true)
    public let title = Column("text", String.self)
    public let author = Column("text", String.self)
}

public struct BookModel: Model {
    public let id: Int?
    public let title: String
    public let author: String
}

public struct Book {
    public let title: String
    public let author: String
}

extension Book: Codable{}
