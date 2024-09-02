//
//  AppSize.swift
//  sidu
//
//  Created by Armstrong Liu on 01/09/2024.
//

import Foundation

@Observable
class AppSize {
    var appSize: CGSize = .zero
    
    init(size: CGSize) {
        self.appSize = size
    }
    
    func getScreenWidth() -> CGFloat {
        return self.appSize.width
    }
    
    func getScreenHeight() -> CGFloat {
        return self.appSize.height
    }
}
