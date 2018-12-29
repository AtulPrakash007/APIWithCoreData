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
    @IBOutlet weak var showHideBtn: UIButton!
    
    @IBOutlet weak var viewXConstraint: NSLayoutConstraint!
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    
    var items = [Categories]()
    var cItems = [Category]()
    var pItems = [Product]()
    var selectedCat = [Int]()
    var childIds = [Int]()
    var rankings = [[Int]]()
    var selectedSegmentIndex: Int = 0
    
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
        startAnimating()
        if NetworkManager.isReachable() {
            Request.sharedInstance.request(url: "https://stark-spire-93433.herokuapp.com/json", method: "GET", params: [:], completion: { (json, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        if let body = json![kCategories] as? [[String: Any]] {
                            self.cItems = body.map { Category(json: $0) }
                        }
                        if let ranking = json![kRankings] as? [[String: Any]] {
                            self.getRanking(json: ranking)
                        }
                    }else {
                        self.stopAnimating()
                    }
                }
            })
        }else {
            if let path = Bundle.main.path(forResource: "Heady", ofType: "json") {
                do {
                    let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                        if let body = json[kCategories] as? [[String: Any]] {
//                        print(body)
                            self.cItems = body.map { Category(json: $0) }
                        }
                        if let ranking = json[kRankings] as? [[String: Any]] {
                            getRanking(json: ranking)
                        }
                    }
                } catch {
                    print("Error deserializing JSON: \(error)")
                    // handle error
                }
            }
            self.stopAnimating()
        }
        
        print(cItems.count)
        
//        let count1 = cItems.reduce(0) { $0 + $1.products.count }
//        print(count1)
//        fetchProduct(all: true, single: false)
//        print(cItems.filter{$0.id == 1}.map{$0.products.count})
//        print(cItems.filter{$0.id == 1 && $0.id == 2})
//        print(cItems.map{$0.products.count})
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
        sortProductList(forSegment: selectedSegmentIndex)
        collectionView.reloadData()
    }
    
    func getRanking(json: [[String: Any]]) {
        for value in 0...json.count - 1 {
            switch  json[value][kRanking] as! String {
            case kMostViewed:
                let arr = json[value][kProducts] as! [[String: Int]]
                let sortedArray = (arr as NSArray).sortedArray(using: [NSSortDescriptor(key: kViewCount, ascending: false)]) as! [[String: Int]]
                let value:[Int] = sortedArray.map{$0[kId]!}
                rankings.append(value)
//                print(sortedArray)
//                print(value)
//                print(kMostViewed)
            case kMostOrdered:
                let arr = json[value][kProducts] as! [[String: Int]]
                let sortedArray = (arr as NSArray).sortedArray(using: [NSSortDescriptor(key: kOrderCount, ascending: false)]) as! [[String: Int]]
                let value:[Int] = sortedArray.map{$0[kId]!}
                rankings.append(value)
            case kMostShared:
                let arr = json[value][kProducts] as! [[String: Int]]
                let sortedArray = (arr as NSArray).sortedArray(using: [NSSortDescriptor(key: kSharedCount, ascending: false)]) as! [[String: Int]]
                let value:[Int] = sortedArray.map{$0[kId]!}
                rankings.append(value)
            default:
                print("No Ranking")
            }
        }
        fetchProduct(all: true, single: false)
        self.stopAnimating()
    }
    
    func getSelectedIds(forIndex: Int) {
        if cItems[forIndex].products.count > 0 {
            selectedCat.append(cItems[forIndex].id!)
        } else {
            childIds = cItems[forIndex].childCategories
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
    
    func sortProductList(forSegment: Int) {
        let sorted = pItems.map{$0.id!}.reorder(by: rankings[forSegment])
        let ordering = Dictionary(uniqueKeysWithValues: sorted.enumerated().map { ($1, $0) })
        pItems = pItems.sorted{ ordering[$0.id!]! < ordering[$1.id!]! }
    }
    
    func viewSetUp(hideView: Bool) {
        if !hideView {
            showHideBtn.setTitle("Filter Hide", for: .normal)
            sideView.isHidden = false
//            viewXConstraint.constant = 0
        }else {
            showHideBtn.setTitle("Filter Show", for: .normal)
            sideView.isHidden = true
//            viewXConstraint.constant = self.sideView.frame.size.width
        }
        tableView.reloadData()
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
    
    func startAnimating() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    @objc func handleTap(_ sender: UITapGestureRecognizer) {
        viewSetUp(hideView: true)
    }
    
    //MARK:- Button Action
    
    @IBAction func sideMenuAction(_ sender: UIButton) {
        if !sideView.isHidden{
            self.viewSetUp(hideView: true)
        }else{
            self.viewSetUp(hideView: false)
        }
    }
    
    @IBAction func SegmentAction(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            selectedSegmentIndex = 0
            print(kMostViewed)
        case 1:
            selectedSegmentIndex = 1
           print(kMostOrdered)
        case 2:
            selectedSegmentIndex = 2
            print(kMostShared)
        default:
            print("No Action")
        }
        sortProductList(forSegment: selectedSegmentIndex)
        collectionView.reloadData()
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
        }else{
            cell.colorLbl.text = "NA"
        }
        
        if let size = cellItem.size {
            cell.sizeLbl.text = String(size)
        }else {
            cell.sizeLbl.text = "NA"
        }
        
        if let price = cellItem.price {
            cell.priceLbl.text = String(price)
        }else{
            cell.priceLbl.text = "NA"
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
        return cItems.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomTableViewCell.self), for: indexPath) as! CustomTableViewCell
        if indexPath.row == 0 {
            tableCell.label.text = "All"
        }else {
            tableCell.label.text = cItems[indexPath.row - 1].name
        }
        
        cell = tableCell
        cell?.selectionStyle = .none
        return cell!
    }
}

//MARK: - UITableViewDelegate

extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selectedCat.removeAll()
        if indexPath.row == 0 {
            fetchProduct(all: true, single: false)
        }else {
            getSelectedIds(forIndex: indexPath.row - 1)
        }
        self.viewSetUp(hideView: true)
    }
}
