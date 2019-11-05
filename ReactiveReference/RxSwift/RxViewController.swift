//
//  RxViewController.swift
//  ReactiveReference
//
//  Created by snlo on 2019/9/25.
//  Copyright © 2019 snlo. All rights reserved.
//

import UIKit

import RxCocoa
import RxSwift

class RxViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelTest: UILabel!
    @IBOutlet weak var textFieldTest: UITextField!
    @IBOutlet weak var buttonTest: UIButton!
    
    var msg = "通知"
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "RxSwift"
        
        // MARK: - tableView config
        tableView.delegate = self
        tableView.dataSource = self
        
//        self.buttonTest.rx.tap.subscribe(onNext: { () in
//            print("按钮被点击")
//        }).disposed(by: disposeBag)
        
        self.buttonTest.rx.controlEvent(.touchUpInside).subscribe(onNext: { () in
            print("按钮被点击")
        }).disposed(by: disposeBag)
        
        
        
    }

    deinit {
        print("销毁")
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension RxViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "RxViewController.cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "RxViewController.cell", for: indexPath)
        
        return cell
    }
    
    
}

// MARK: - UIScrollViewDelegate
extension RxViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}
