//
//  Credentials.swift
//  App
//
//  Created by Nisum on 4/13/19.
//

import Vapor

struct Credentials: Content {
    let username: String
    let password: String
}
