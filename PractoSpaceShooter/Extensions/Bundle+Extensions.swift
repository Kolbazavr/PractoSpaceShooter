//
//  Bundle+Extensions.swift
//  PractoSpaceShooter
//
//  Created by ANTON ZVERKOV on 15.05.2025.
//

import Foundation

extension Bundle {
    func decode<T: Decodable>(_ type: T.Type, from file: String) -> T {
        guard let url = url(forResource: file, withExtension: nil) else {
            fatalError("No such file")
        }
        guard let data = try? Data(contentsOf: url) else {
            fatalError("Couldn't load data from \(url)")
        }
        let decoder = JSONDecoder()
        guard let decoded = try? decoder.decode(T.self, from: data) else {
            fatalError("Failed to decode")
        }
        return decoded
    }
}
