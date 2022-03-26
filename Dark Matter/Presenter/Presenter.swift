//
//  Presenter.swift
//  Dark Matter
//
//  Created by Иван Зайцев on 26.03.2022.
//

import Foundation

protocol UserPresenterDelegate: AnyObject {
    func presentData(newData: [Measurement], direction: Direction)
    func presentActivityIndicator(in direction: Direction)
    func presentFirstData(with newData: [Measurement])
}


enum Direction {
    case up
    case down
}
enum C {
    static let maximumOfDataOnDevice = 50
    static let countOfAddedItems = 15
    // you cannot put countOfAddedItems > or = than maximumOfDataOnDevice
}


class UserPresenter {
        
    var myData = [Measurement]()
    
    weak var delegate: UserPresenterDelegate?
    

    public func firstLoadingOfData() {

        myData = Array(DataBase.data[0...C.maximumOfDataOnDevice])
        self.delegate?.presentFirstData(with: myData)
        
    }
    
    public func requestNewDataFromDatabase(from index: Int, in direction: Direction) -> [Measurement] {
        
        switch direction {
        case .up:
            return Array(DataBase.data[index - C.countOfAddedItems...index])
        case .down:
            return Array(DataBase.data[index...index + C.countOfAddedItems])
        }
    }
    
    public func setMyViewDelegate(delegate: UserPresenterDelegate) {
        self.delegate = delegate
    }
    
    
    func scrolledToEnd(direction: Direction) {
        
        guard !isPaginating else { return }
        
        updateData(oldData: myData, pagination: true, in: direction, completion: { [weak self] result in
            
            switch result {
            case .success(let updatedData):
                self?.delegate?.presentData(newData: updatedData, direction: direction)
            case .failure(_):
                break
            }
        })
        self.delegate?.presentActivityIndicator(in: direction)
        
    }
    
    var isPaginating = false
    
    func updateData(oldData: [Measurement], pagination: Bool = false, in direction: Direction, completion: @escaping (Result<[Measurement], Error>) -> () ) {
        
        if pagination {
            isPaginating = true
        }
        
        DispatchQueue.global(qos: .userInitiated).asyncAfter(deadline: .now() + 1) {
            
            let originalData = [Measurement(measurment: "DEFAULT", index: 0)]
            var newData = [Measurement]()
            
            newData = self.refactorData(direction: direction, oldData: oldData)
            self.myData = newData
            completion(.success(pagination ? newData : originalData))
            
            if pagination {
                self.isPaginating = false
            }
        }
    }
    
    private func refactorData(direction: Direction, oldData: [Measurement]) -> [Measurement]  {
        
        let lastIndex = (direction == .down) ? (oldData.last ?? Measurement(measurment: "no", index: 0)).index : (oldData.first ?? Measurement(measurment: "no", index: 0)).index

        let newData = (direction == .down) ? requestNewDataFromDatabase(from: lastIndex + 1, in: direction) : requestNewDataFromDatabase(from: lastIndex - 1, in: direction)
     
        switch direction {
        case .up:
            var resultData = oldData
            for i in stride(from: C.countOfAddedItems, through: 0, by: -1) {
                resultData.insert(newData[i], at: 0)
                
            }
            resultData.removeSubrange((resultData.count - 1) - C.countOfAddedItems...(resultData.count - 1))
            print("up")
            
            return resultData
            
        case .down:
            var resultData = oldData
            for i in 0...C.countOfAddedItems {
                resultData.append(newData[i])
            }
            resultData.removeSubrange(0...C.countOfAddedItems)
            print("down")
            
            return resultData
            
        }
    }
}
