//
//  ViewController.swift
//  Dark Matter
//
//  Created by Иван Зайцев on 25.03.2022.
//

import UIKit

class ViewController: UIViewController {
    
    let dataManager = DataManager()
    
    // TODO: обьявление даты надо в другое место
    var data = Array(0...C.maximumInData)
    
    //MARK: - ViewController LyfeCycle
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    //MARK: - Private Methods
    
    private func scrollToLastRow() {
        
        //TODO: тут плюс 2 это округленное отношение размеров футера и одной клетки, надо это вычислять
        let indexPath = NSIndexPath(row: C.maximumInData - (C.delta + 1) + 2, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
        
    }
    
    private func scrollToFirstRow() {
        //TODO: если нажать на челку то экран взлетает но не срабатывает обновляющий метож
        //TODO: тут минус 2 это округленное отношение размеров футера и одной клетки, надо это вычислять
        let indexPath = NSIndexPath(row: C.delta + 1 - 2 , section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .top, animated: false)
    }
    
    private func createSpinnerView() -> UIView {
        
        let footerView = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 100))
        let spinner = UIActivityIndicatorView()
        spinner.center = footerView.center
        footerView.addSubview(spinner)
        spinner.startAnimating()
        
        return footerView
        
    }
    
    private func updateUI(_ direction: Direction) {
        switch direction {
        case .up:
            DispatchQueue.main.async {
                self.tableView.tableHeaderView = nil
                self.tableView.reloadData()
                self.scrollToFirstRow()
            }
            
        case .down:
            DispatchQueue.main.async {
                self.tableView.tableFooterView = nil
                self.tableView.reloadData()
                self.scrollToLastRow()
                
            }
        }
        
    }
    
}
//MARK: - UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate

extension ViewController: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = "\(data[indexPath.row])"
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        if position > ( (tableView.contentSize.height - 100) - (scrollView.frame.size.height)) {
            
            guard !dataManager.isPaginating else { return }
            dataManager.updateData(oldData: data, pagination: true, in: .down) { [weak self] result in
                switch result {
                case .success(let updatedData):
                    
                    self?.data = updatedData
                    self?.updateUI(.down)
                    
                case .failure(_):
                    break
                }
            }
            self.tableView.tableFooterView = createSpinnerView()
        }
        
        if position < 0 {
            
            guard !dataManager.isPaginating else { return }
            dataManager.updateData(oldData: data, pagination: true, in: .up) { [weak self] result in
                switch result {
                case .success(let updatedData):
                    
                    self?.data = updatedData
                    self?.updateUI(.up)
                    
                case .failure(_):
                    break
                }
            }
            self.tableView.tableHeaderView = createSpinnerView()
        }
    }
}


