//
//  GeneralResult.swift
//  Main
//
//  Created by iq3AddLi on 2019/09/18.
//

import Foundation

struct GeneralResult{
    let infomation: String
    
    init(_ infomation: String){
        self.infomation = infomation
    }
}

extension GeneralResult: Codable{}
