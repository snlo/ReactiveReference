//
//  ReactiveViewController.swift
//  ReactiveReference
//
//  Created by snlo on 2019/9/25.
//  Copyright © 2019 snlo. All rights reserved.
//

import UIKit

import ReactiveCocoa
import ReactiveSwift

class ReactiveViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var labelTest: UILabel!
    @IBOutlet weak var textFieldTest: UITextField!
    @IBOutlet weak var buttonTest: UIButton!

    deinit {
        print("销毁")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "ReactiveSwift"

        tableView.delegate = self
        tableView.dataSource = self

        
        baseOperators()
//        click()
//        click_double()
//        notification()
        
    }

}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension ReactiveViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "ReactiveViewController.cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReactiveViewController.cell", for: indexPath)
        
        cell.textLabel?.text = "\(indexPath.row)"
        
        return cell
    }
}

// MARK: - UIScrollViewDelegate
extension ReactiveViewController: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        view.endEditing(true)
    }
}

// MARK: - Notification.Name
extension Notification.Name {
    public static let custome = Notification.Name("notification.customeName")
}

extension ReactiveViewController {
    // MARK: - 基本运算符
    func baseOperators() {
//        creat()
//        map()
        filter()
    }
    
    /// 创建一个信号
    func creat() {
        //创建
        let signal: Signal<Int, Error> = Signal { (observer, lifetime) in
            
            DispatchQueue.main.async {
                for i in 1...5 {
                    observer.send(value: i)
                }
                observer.sendCompleted()
            }
            
            lifetime.observeEnded {
                print("disposed")
            }
        }

        //订阅
        signal.observe { (event) in
            switch event {
            case .value(let n):
                print("next:\(n)")
                break
            case .failed(let error):
                print("error:\(error)")
                break
            case .interrupted:
                print("interrupted")
                break
            case .completed:
                print("completed")
                break
            }
        }
        
        //创建
        let (aSignal, aObserver) = Signal<Any, Error>.pipe()

        DispatchQueue.main.async {
            aObserver.send(value: 3)
            aObserver.sendCompleted()
        }

        //订阅
        aSignal.observe {
            print($0)
        }
        
    }
    
    /// map 映射
    func map() {
        let (signal, observer) = Signal<String, Error>.pipe()
        
        signal
            .map { $0.uppercased() } //将小写字母映射为大写
            .observeResult { print($0) }

        observer.send(value: "a")
        observer.send(value: "b")
        observer.send(value: "c")
    }
    
    /// filter 过滤
    func filter() {
        
        let (signal, observer) = Signal<Int, Error>.pipe()
        
        signal
            .filter { $0 < 5 } //过滤小于5的数据
            .observeResult { print($0) }
        
        for i in 1...8 {
            observer.send(value: i)
        }
        
    }
    
    
}

extension ReactiveViewController {
    
    // MARK: - 单击按钮事件流
    func click() {
        self.buttonTest.reactive.controlEvents(.touchUpInside).observe { (event) in
            switch event {
            case .value(let sender):
                print("点击：\(sender)")
            case .failed(let error):
                print("错误：\(error)")
            case .completed:
                print("完成")
            case .interrupted:
                print("中断")
            }
        }

        self.buttonTest.reactive.controlEvents(.touchUpInside).observeValues { (sender) in
            print("只关注点击 - 点击：\(sender)")
        }

        self.buttonTest.reactive.controlEvents(.touchUpInside).observeCompleted {
            print("只关注完成 - 完成")
        }

        self.buttonTest.reactive.controlEvents(.touchUpInside).observeResult { (result) in
            switch result {
            case .success(let sender):
                print("只关注结果 - 成功：\(sender)")
            case .failure(let error):
                print("只关注结果 - 错误：\(error)")
            }
        }
        
    }
    
    // MARK: - 双击按钮事件流
    func click_double() {
        self.buttonTest.reactive.controlEvents(.touchUpInside)
            .collect(every: DispatchTimeInterval.milliseconds(250), on: QueueScheduler.main, skipEmpty: true, discardWhenCompleted: true)
            .map{ $0.count }
            .filter{ $0 == 2 }
            .observeResult { (resulet) in
                print("双击：\(resulet)")
        }
        
    }
    
    // MARK: - 通知
    func notification() {
        //订阅通知观察
        var disposable = NotificationCenter.default.reactive.notifications(forName: .custome).take(during: reactive.lifetime).observeValues {[weak self] (n) in
            guard let self = self else {return}
            print("\(self):\(n.userInfo!)")
        }
        //发送通知
        NotificationCenter.default.post(name: .custome, object: nil, userInfo: ["user_name":"noti"])
        
        // 强制销毁
        disposable?.dispose()
        disposable = nil
        
    }
    
    
}


