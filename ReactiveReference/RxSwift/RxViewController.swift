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
        
        instance()
    }

    deinit {
        print("销毁")
        self.buttonTest = nil
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


extension RxViewController {
    func instance() {
        
        // MARK: - 单击按钮事件流
        
        ///不建议使用
        self.buttonTest.rx.controlEvent(.touchUpInside).subscribe(onNext: { (_) in
            print("点击")
        }, onError: { (error: Error) in
            print("错误：\(error)")
        }, onCompleted: {
            print("完成")
        }, onDisposed: {
            print("处理掉了")
        }).disposed(by: disposeBag)
        
        ///不建议使用
        self.buttonTest.rx.controlEvent(.touchUpInside).subscribe { (event) in
            switch event {
            case .next(let sender):
                print("不会发出订阅的任何初始值 - 点击：\(sender)")
            case .error(let error):
                print("次订阅中永远不会发出错误 - 错误：\(error)")
            case .completed:
                print("完成")
            }
        }.disposed(by: disposeBag)
        
        
        self.buttonTest.rx.controlEvent(.touchUpInside).asObservable().bind { (_) in
            print("点击")
        }.disposed(by: disposeBag)
        ///这两个是相等的
        self.buttonTest.rx.tap.asObservable().bind { (_) in
            print("点击")
        }.disposed(by: disposeBag)
        
        
        // MARK: - 双击事件流
        self.buttonTest.rx
            .controlEvent(.touchUpInside).asObservable()
            .buffer(timeSpan: RxTimeInterval.milliseconds(250), count: 250, scheduler: MainScheduler.init())
            .map{ $0.count }
            .filter{ $0 == 2 }
            .bind { (_) in
                print("双击")
        }.disposed(by: disposeBag)
        
        
        
    }
}
