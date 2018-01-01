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
    var cItems = [Category]()
    var pItems = [Product]()
    var selectedCat = [Int]()
    var childIds = [Int]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        viewSetUp(hideView: true)
        registerCollectionViewCell()
//        let tap = UITapGestureRecognizer(target: self, action: #selector(self.handleTap(_:)))
//        sideView.addGestureRecognizer(tap)
//        tableView.removeGestureRecognizer(tap)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func getData() {
        if let path = Bundle.main.path(forResource: "Heady", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                    if let body = json["categories"] as? [[String: Any]] {
//                        print(body)
                        self.cItems = body.map { Category(json: $0) }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
                // handle error
            }
        }
        print(cItems.count)
        
        let count1 = cItems.reduce(0) { $0 + $1.products.count }
        print(count1)
        fetchProduct(all: true, single: false)
//        print(cItems.filter{$0.id == 1}.map{$0.products.count})
//        print(cItems.filter{$0.id == 1 && $0.id == 2})
//        print(cItems.map{$0.products.count})

   /*
        if let path = Bundle.main.path(forResource: "Heady", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any], let categories = json["categories"] as? Array<Any>{
//                    let rankings = json["rankings"] as? Array<Any>
                    
                    if categories.count > 0 {
                        for index in 0...categories.count - 1 {
                            let category = categories[index] as? [String: Any]
                            let cId = category!["id"] as? Int
                            let cName = category!["name"] as? String
                            
                            var products = [Products]()
                            if let productInfo = category!["products"] as? Array<Any> {
                                for p in 0...productInfo.count-1 {
                                    let productItem = productInfo[p] as? [String: Any]
                                    let pId = productItem!["id"] as? Int
                                    let pName = productItem!["name"] as? String
                                    
                                    var variants = [Variants]()
                                    if let variantInfo = productItem!["variants"] as? Array<Any> {
                                        for v in 0...variantInfo.count-1 {
                                            let variantItem = variantInfo[v] as? [String: Any]
                                            let vItem = Variants(id: variantItem!["id"] as? Int,
                                                                 name: variantItem!["color"] as? String,
                                                                 size: variantItem!["size"] as? Int,
                                                                 price: variantItem!["price"] as? Int)
                                            variants.append(vItem)
                                        }
                                    }
                                    
                                    let pItem = Products(id: pId, name: pName, variants: variants, like_count: 0, view_count: 0, shared_count: 0)
                                    products.append(pItem)
                                }
                            }
                            
                            let childInfo = category!["child_categories"] as! Array<Int>
//                            var childs = [ChildCategories]()
//                            if childInfo.count > 0 {
//
//                            }
//                            let pId = productInfo["id"]
//                            let pName = productInfo["name"]
                            print(childInfo)
                            let cItem = Categories(id: cId, name: cName, products: products, childCategories: childInfo)
                            items.append(cItem)
                        }
                    }
                }
            } catch {
                print("Error deserializing JSON: \(error)")
                // handle error
            }
        }
        */
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
    
    func fetchProduct(all isAll: Bool, single isSingle: Bool) {
        pItems.removeAll()
        if isAll {
            let temp:[[Product]] = cItems.map{$0.products}
            for product in temp {
                print(product.count)
                for p in product {
                    pItems.append(p)
                }
            }
        }
        
        if isSingle {
//            var temp = [[Product]]()
            for ids in selectedCat {
                let temp:[[Product]] = cItems.filter{$0.id! == ids}.map{$0.products}
                for product in temp {
                    print(product.count)
                    for p in product {
                        pItems.append(p)
                    }
                }
            }
        }
        
        collectionView.reloadData()
    }
    
    func getSelectedIds(forIndex: IndexPath) {
        if cItems[forIndex.row].products.count > 0 {
            selectedCat.append(cItems[forIndex.row].id!)
        } else {
            childIds = cItems[forIndex.row].childCategories
            getSubIDs(from: childIds)
        }
        print(selectedCat)
        fetchProduct(all: false, single: true)
    }
    
    func getSubIDs(from: [Int]) {
        for ids in from {
            let count = cItems.filter{$0.id == ids}.map{$0.products.count}[0]
            if count == 0 {
                let cat = cItems.filter{$0.id == ids}
                childIds = cat[0].childCategories
                getSubIDs(from: childIds)
            }else {
                selectedCat.append(ids)
                childIds.removeFirst()
            }
        }
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
        if !sideView.isHidden{
            self.viewSetUp(hideView: true)
        }else{
            self.viewSetUp(hideView: false)
        }
    }
    

}

//MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return pItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pItems[section].variants.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath) as! CollectionViewCell
        let cellItem = pItems[indexPath.section].variants[indexPath.item]
        if let color = cellItem.color {
            cell.colorLbl.text = color
        }
        if let size = cellItem.size {
            cell.sizeLbl.text = String(size)
        }
        if let price = cellItem.price {
            cell.priceLbl.text = String(price)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        
        switch kind {
        case UICollectionElementKindSectionHeader:
            let headerView = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                             withReuseIdentifier: String(describing: CollectionHeaderView.self),
                                                                             for: indexPath) as! CollectionHeaderView
//            print(pItems[indexPath.section].name ?? "Nothing")
            headerView.label.text = pItems[indexPath.section].name
            return headerView
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
}

//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomTableViewCell.self), for: indexPath) as! CustomTableViewCell
        tableCell.label.text = cItems[indexPath.row].name
        cell = tableCell
        cell?.selectionStyle = .none
        return cell!
    }
}

//MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCat.removeAll()
        getSelectedIds(forIndex: indexPath)
        self.viewSetUp(hideView: true)
    }
}
