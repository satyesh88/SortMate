//
//  CustomBundle.swift
//  GreenGame
//
//  Created by Satyesh Shivam on 19/06/24.
//

import Foundation

class CustomBundle: Bundle {
    static var bundle: Bundle?

    static func setLanguage(_ language: String) {
        if let path = Bundle.main.path(forResource: language, ofType: "lproj") {
            bundle = Bundle(path: path)
        } else {
            bundle = Bundle.main
        }
        object_setClass(Bundle.main, CustomBundle.self)
    }

    override func localizedString(forKey key: String, value: String?, table tableName: String?) -> String {
        return CustomBundle.bundle?.localizedString(forKey: key, value: value, table: tableName) ?? super.localizedString(forKey: key, value: value, table: tableName)
    }
}




