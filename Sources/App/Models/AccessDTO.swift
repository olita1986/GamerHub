//
//  AccessDTO.swift
//  App
//
//  Created by Nisum on 4/13/19.
//

import Vapor

struct AccessDto: Content {
    let accessToken: String
    let expiredAt: Date
    let refreshToken: String
}
