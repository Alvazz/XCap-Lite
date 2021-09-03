//
//  DefaultsAdapter+Keys.swift
//  XCap
//
//  Created by scchn on 2021/5/31.
//

import Foundation

import SwiftyUserDefaults

extension DefaultsKeys {
    var scales: DefaultsKey<[Scale]> { .init("scales", defaultValue: []) }
}
