//
//  ViewController.swift
//  ReactiveReference
//
//  Created by snlo on 2019/9/24.
//  Copyright © 2019 snlo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var tableView: UITableView!
    
    var dataSource = ["RxSwift", "ReactiveSwift", "ReactiveObjc"]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.delegate = self
        tableView.dataSource = self
        
        view.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.250980407, blue: 0.4784313738, alpha: 1)
    }
}

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        tableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "ViewController.cell")
        let cell = tableView.dequeueReusableCell(withIdentifier: "ViewController.cell", for: indexPath)
        
        cell.textLabel?.text = dataSource[indexPath.row]
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            navigationController?.pushViewController(RxViewController.init(), animated: true)
            break
        case 1:
            navigationController?.pushViewController(ReactiveViewController.init(), animated: true)
            break
        case 2:
            navigationController?.pushViewController(ReactiveOCViewController.init(), animated: true)
            break
        default:
            break
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
}

