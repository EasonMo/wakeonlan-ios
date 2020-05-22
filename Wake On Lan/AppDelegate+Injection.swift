//
//  AppDelegate+Injection.swift
//  Wake on LAN
//
//  Created by Владислав Лисянский on 21.05.2020.
//  Copyright © 2020 Владислав Лисянский. All rights reserved.
//

import Foundation
import Resolver

extension Resolver: ResolverRegistering {
    public static func registerAllServices() {
        registerGlobalServices()
    }
}
