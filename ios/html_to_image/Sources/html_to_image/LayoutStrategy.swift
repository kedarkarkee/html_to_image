//
//  LayoutStrategy.swift
//  Pods
//
//  Created by Kedar Karki on 11/06/2025.
//

import UIKit

class LayoutStrategy {
    let width: Int
    let height: Int

    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }

    static func parseFromMap(_ map: [String: Any]) -> LayoutStrategy {
        let screenScale = UIScreen.main.scale

        let widthFromMap =
            map["width"] as? Double ?? UIScreen.main.bounds.size.width
        let heightFromMap =
            map["height"] as? Double ?? UIScreen.main.bounds.size.height

        let width = Int(widthFromMap * screenScale)
        let height = Int(heightFromMap * screenScale)

        return LayoutStrategy(width: width, height: height)
    }
}
