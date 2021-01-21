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
    
    deinit {
        print("销毁")
        self.buttonTest = nil
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "RxSwift"
        
        tableView.delegate = self
        tableView.dataSource = self
        
        
        baseOperators()
        click()
//        click_double()
//        notification()
        
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

// MARK: - Notification.Name
extension Notification.Name {
    public static let customeX = Notification.Name("notification.customeNameX")
}

extension RxViewController {
    // MARK: - 基本运算符
    func baseOperators() {
//        creat()
//        map()
        filter()
    }
    
    /// 创建一个信号
    func creat() {
        //创建
        let signal: Observable<Int> = Observable.create { (observer) -> Disposable in
            for i in 1...5 {
                observer.on(.next(i))
            }
            observer.onCompleted()
            return Disposables.create {
                print("disposed")
            }
        }
        
        //订阅
        signal.subscribe(onNext: { (n) in
            print("next:\(n)")
        }, onError: { (e) in
            print("error:\(e)")
        }, onCompleted: {
            print("completed")
        }, onDisposed: {
            print("disposed")
        }).disposed(by: disposeBag)
        
        //创建
        let aSignal: Observable<Int> = Observable.generate(initialState: 1, condition: {$0 < 5}, iterate: {$0 + 1})
        
        //订阅
        aSignal.subscribe {
            print("aSignal: \($0)")
        }.disposed(by: disposeBag)
        
        //创建
        let bSignal: Observable<Int> = Observable.generate(initialState: 0, condition: {$0 < 5}, scheduler: CurrentThreadScheduler.instance, iterate: {$0 + 1})
        
        //订阅
        bSignal.subscribe {
            print("bSignal: \($0)")
        }.disposed(by: disposeBag)
        
    }
    
    /// map 映射
    func map() {
        let signal: Observable<String> = Observable.create { (observer) -> Disposable in
            observer.on(.next("a"))
            observer.on(.next("b"))
            observer.on(.next("c"))
            observer.onCompleted()
            return Disposables.create {
                print("disposed")
            }
        }
        
        signal
            .map { $0.uppercased() } //将小写字母映射为大写
            .subscribe { print($0) }
            .disposed(by: disposeBag)
    }
    
    // MARK: - filter 过滤
    func filter() {
        let signal: Observable<Int> = Observable.create { (observer) -> Disposable in
            for i in 1...8 {
                observer.onNext(i)
            }
            observer.onCompleted()
            return Disposables.create {
                print("disposed")
            }
        }
        
        signal
            .filter { $0 < 5 } //过滤小于5的数据
            .subscribe { print($0) }
            .disposed(by: disposeBag)
    }
    
    
}

extension RxViewController {
    
    // MARK: - 单击按钮事件流
    func click() {
        //不建议使用
        self.buttonTest.rx.controlEvent(.touchUpInside).subscribe(onNext: { (_) in
            print("点击")
        }, onError: { (error: Error) in
            print("错误：\(error)")
        }, onCompleted: {
            print("完成")
        }, onDisposed: {
            print("处理掉了")
        }).disposed(by: disposeBag)
        
        //不建议使用
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
        
        //这两个是相等的
        
        self.buttonTest.rx.tap.asObservable().bind { (_) in
            print("点击")
        }.disposed(by: disposeBag)
        
    }
    
    // MARK: - 双击事件流
    func click_double() {
        self.buttonTest.rx
            .controlEvent(.touchUpInside).asObservable()
            .buffer(timeSpan: RxTimeInterval.milliseconds(1000), count: 0, scheduler: MainScheduler.init())
            .map{ $0.count }
            .filter{ $0 == 2 }
            .bind { (_) in
                print("双击")
        }.disposed(by: disposeBag)
    }
    
    func notification() {
        //订阅通知观察
        NotificationCenter.default.rx.notification(.customeX, object: nil).asObservable().subscribe { (n) in
            print(":\(n.element!.userInfo!)")
        }.disposed(by: disposeBag)
        
        //发送通知
        NotificationCenter.default.post(name: .customeX, object: nil, userInfo: ["user_name":"noti"])
        
    }
    
}
