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
    
    private var msg = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.title = "ReactiveSwift"
        
        // MARK: - tableView config
        tableView.delegate = self
        tableView.dataSource = self
        
        
        // MARK: - 属性监听
        let viewProgress = UIProgressView.init()
        // viewProgress.progress
        viewProgress.reactive.producer(forKeyPath: "progress").startWithValues { [weak self] (p : Any?) in
            guard let self = self else {return}
            
            guard let v = p as? Float else {
                return
            }
            self.msg = String(v)
        }
        
        // MARK: - 按钮点击事件
        let button = UIButton.init()
        button.reactive.controlEvents(.touchUpInside).observeValues {[weak self] (sender) in
            guard let self = self else {return}
            
            self.msg = "按钮点击"
        }
        
        // MARK: - 通知
        notification()
        
        
    }

    private func notification() {
        /**
         在发送前接受
         */
        //接受
        var disposable = NotificationCenter.default.reactive.notifications(forName: .custome).take(during: reactive.lifetime).observeValues {[weak self] (n) in guard let self = self else {return}
            
            self.msg = "通知处理"
        }
        //发送
        NotificationCenter.default.post(name: .custome, object: nil)
        
        //强制 销毁
        disposable?.dispose()
        disposable = nil
        
    }
    
    deinit {
        print("销毁")
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

// MARK: - notification name
extension Notification.Name {
    public static let custome = Notification.Name("notification.customeName")
}
