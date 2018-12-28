//
//  ViewController.swift
//  APIWithCoreData
//
//  Created by Atul on 24/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var viewXConstraint: NSLayoutConstraint!
    
    var items = [Categories]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        viewSetUp(hideView: true)
        registerCollectionViewCell()
        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
        sideView.addGestureRecognizer(tap)
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getData() {
        
        guard let data = dataFromFile("Heady") else {
            return
        }
        
        do {
            if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let body = json["categories"] as? [String: Any] {
            
                print(body)
            }
        } catch {
            print("Error deserializing JSON: \(error)")
        }
        /*
        if NetworkManager.isReachable() {
            Request.sharedInstance.request(url: "https://stark-spire-93433.herokuapp.com/json", method: "GET", params: [:], completion: { (dict, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        if let catArray = dict!["categories"] as? [String: Any] {
                            for categories in catArray {
                                print(categories)
                            }
                        }
                    }
                }
            })
        }
        */
    }
    
    func viewSetUp(hideView: Bool) {
        if !hideView {
            sideView.isHidden = false
//            viewXConstraint.constant = 0
        }else {
            sideView.isHidden = true
//            viewXConstraint.constant = self.sideView.frame.size.width
        }
    }
    
    func registerCollectionViewCell() {
        tableView.estimatedRowHeight = 50
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.tableFooterView = UIView()
        tableView.register(UINib(nibName: String(describing: CustomTableViewCell.self),bundle: nil), forCellReuseIdentifier:String(describing: CustomTableViewCell.self))
        
        collectionView.register(UINib(nibName: String(describing: CollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: CollectionViewCell.self))
        
        if let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 110,height: 80)
        }
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        viewSetUp(hideView: true)
    }
    
    @IBAction func sideMenuAction(_ sender: UIButton) {
        if viewXConstraint.constant == 0{
            self.viewSetUp(hideView: true)
        }else{
            self.viewSetUp(hideView: false)
        }
    }
    

}

extension ViewController: UICollectionViewDelegate {
    
}

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 10
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath) as! CollectionViewCell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: String(describing: CollectionHeaderView.self),
                                                                             for: indexPath) as! CollectionHeaderView
            headerView.label.text = "Testing"
            return headerView
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomTableViewCell.self), for: indexPath) as! CustomTableViewCell
        cell = tableCell
        cell?.selectionStyle = .none
        return cell!
    }
}

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.viewSetUp(hideView: true)
    }
}
