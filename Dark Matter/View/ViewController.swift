//
//  ViewController.swift
//  Dark Matter
//
//  Created by Иван Зайцев on 25.03.2022.
//

import UIKit

class ViewController: UIViewController, UserPresenterDelegate {
    
    
   
    private let presenter = UserPresenter()
    
    private var measurments = [Measurement]()
    
    
    //MARK: - Presenter Delegate
    
    
    func presentData(newData: [Measurement], direction: Direction) {
        
        measurments = newData
        self.updateUI(direction)
        
    }
    func presentFirstData(with newData: [Measurement]) {
        measurments = newData
    }
    
    
    func presentActivityIndicator(in direction: Direction) {
        
        switch direction {
        case .up:
            self.tableView.tableHeaderView = createSpinnerView()
        case .down:
            self.tableView.tableFooterView = createSpinnerView()
        }
    }
    
    
    //MARK: - ViewController LyfeCycle
    
    @IBOutlet weak var tableView: UITableView!
    override func viewDidLoad() {

        super.viewDidLoad()
        tableView.register(UINib(nibName: "MeasureTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
        tableView.dataSource = self
        tableView.delegate = self
        presenter.setMyViewDelegate(delegate: self)
       
        presenter.firstLoadingOfData()
    }
    
    //MARK: - Private Methods
    
    private func scrollToLastRow() {
        
        let indexPath = NSIndexPath(row: C.maximumOfDataOnDevice - (C.countOfAddedItems + 1) + 2, section: 0)
        self.tableView.scrollToRow(at: indexPath as IndexPath, at: .bottom, animated: false)
        
    }
    
    private func scrollToFirstRow() {
        
        let indexPath = NSIndexPath(row: C.countOfAddedItems + 1 - 2 , section: 0)
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
        measurments.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as? MeasureTableViewCell else {
            print("no")
            return UITableViewCell()
            
        }
        cell.label.text = "\(measurments[indexPath.row].measurment)"
        return cell
        
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        
        if position > ( (tableView.contentSize.height - 100) - (scrollView.frame.size.height))  &&
            measurments[measurments.count - 1].index + C.countOfAddedItems < DataBase.data.count - 1 {

            presenter.scrolledToEnd(direction: .down)
        }
        if position < 0 && measurments[0].index != 0  {
            presenter.scrolledToEnd(direction: .up)
        }
    }
}


