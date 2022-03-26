//
//  ViewController.swift
//  Dark Matter
//
//  Created by Иван Зайцев on 25.03.2022.
//

import UIKit

class ViewController: UIViewController {
    
    enum C {
        static let maximumInData = 50
        static let delta = 17
    }
    var data = Array(0...C.maximumInData)
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
//        print(data)
    }


}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell =  UITableViewCell(style: .default, reuseIdentifier: nil)
        cell.textLabel?.text = "\(data[indexPath.row])"
        return cell
        
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        if indexPath.row == data.count - 1 {
            let queue = DispatchQueue.global(qos: .utility)
            queue.asyncAfter(deadline: .now() + 1){
                self.changeDataDown()
            }
        }
        if indexPath.row == 0 {
//            print(cell.textLabel?.text)
            let queue = DispatchQueue.global(qos: .utility)
            queue.asyncAfter(deadline: .now() + 1){
                self.changeDataUp()
            }
        }
        
    }
    
    func changeDataDown() {
        
        for _ in 0...C.delta {
            data.append((data.last ?? 0) + 1)
        }
        data.removeSubrange(0...C.delta)
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToLastRow()
            
        }
        print("down")
        print(data.count)
    }
    func changeDataUp() {
        for _ in 0...C.delta {
            data.insert((data.first ?? 0) - 1 , at: 0)
            
        }
        data.removeSubrange((data.count - 1) - C.delta...(data.count - 1))
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.scrollToFirstRow()
            
        }
        print("up")
        print(data.count)
    }
    func scrollToLastRow() {
        let indexPath = NSIndexPath(row: C.maximumInData - (C.delta + 1) , section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
    }
    func scrollToFirstRow() {
        let indexPath = NSIndexPath(row: C.delta + 1 , section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
}

