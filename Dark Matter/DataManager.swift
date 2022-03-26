//
//  DataManager.swift
//  Dark Matter
//
//  Created by Иван Зайцев on 26.03.2022.
//

import Foundation
import UIKit

enum Direction {
    case up
    case down
}
enum C {
    static let maximumInData = 500
    static let delta = 250
}
class DataManager {
    
    
    
    var isPaginating = false
    func updateData(oldData: [Int], pagination: Bool = false, in direction: Direction, completion: @escaping (Result<[Int], Error>) -> () ) {
        
        if pagination {
            isPaginating = true
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 2) {
           //TODO: зачем original data нужна...
            // TODO: клетки нажимаются, убрать
            let originalData = Array(0...40)
            var newData = [Int]()
            
            newData = self.updateData(direction: direction, oldData: oldData)
            completion(.success(pagination ? newData : originalData))
            // TODO: обработать неуспех, то есть если не подгрузится из сети
            // TODO: обработать что выше 0 нельзя идти, не высвечивается худур и не обновляется и не срабатывают никакие методы
            if pagination {
                self.isPaginating = false
            }
        }
    }
    
    private func updateData(direction: Direction, oldData: [Int]) -> [Int]  {
        switch direction {
        case .up:
            var resultData = oldData
            for _ in 0...C.delta {
                resultData.insert((resultData.first ?? 0) - 1 , at: 0)
            }
            resultData.removeSubrange((resultData.count - 1) - C.delta...(resultData.count - 1))
            print("up")
            
            return resultData
            
        case .down:
            var resultData = oldData
            for _ in 0...C.delta {
                resultData.append((resultData.last ?? 0) + 1)
            }
            resultData.removeSubrange(0...C.delta)
            print("down")
            
            return resultData
            
        }
    }
    
}
