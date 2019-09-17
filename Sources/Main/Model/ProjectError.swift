//
//  ProjectError.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/17.
//

import Foundation

struct ProjectError: Error{
    let message: String
    init(_ message: String){
        self.message = message
    }
}

extension ProjectError: CustomStringConvertible{
    var description: String { return message }
}
