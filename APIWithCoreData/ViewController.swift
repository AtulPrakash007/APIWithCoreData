//
//  ViewController.swift
//  APIWithCoreData
//
//  Created by Atul on 24/12/18.
//  Copyright © 2018 Atul. All rights reserved.
//

import UIKit
import CoreData

class ViewController: UIViewController {

    /**
     * Outlet Connection
     */
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sideView: UIView!
    @IBOutlet weak var showHideBtn: UIButton!
    
    
    var activityIndicator: UIActivityIndicatorView = UIActivityIndicatorView()
    let userDefault = UserDefaults.standard
    /**
     * Hold API Values variables
     * Also variables to play around
     */
    var cItems = [Category]()
    var pItems = [Product]()
    var selectedCat = [Int]()
    var childIds = [Int]()
    var rankings = [[Int]]()
    var selectedSegmentIndex: Int = 0
    var networkAvailable: Bool = true
    
    /**
     * Hold Core Data Values variables
     */
    
    var coreItems: [Categories] = []
    var prodItems: [Products] = []
    var rankItems: [Rankings] = []
    
    //MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getDataFromAPI()
        viewSetUp(hideView: true)
        registerCollectionViewCell()
        
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    //MARK: - Custom Functions
    
    /**
     * Get Data called first time from View Did Load
     * It checks for network connectivity from Model Class
     * If Network available then use Request class to call the API
     * If netwrok not available read the local JSON file
     * Once data is serialized, it will pass to Data Model to get Gategories
     * Also will pass to another method to get the rankings
     */
    
    func getDataFromAPI() {
        startAnimating()
        if NetworkManager.isReachable() {
            networkAvailable = true
            Request.sharedInstance.request(url: "https://stark-spire-93433.herokuapp.com/json", method: "GET", params: [:], completion: { (json, error) in
                DispatchQueue.main.async {
                    if error == nil {
                        if let body = json![kCategories] as? [[String: Any]] {
                            self.cItems = body.map { Category(json: $0) }
                            if !self.userDefault.bool(forKey: kCatSaved) {
                                let bool = self.saveCategoryData(with: body)
                                if bool {
//                                    self.coreItems = self.fetchCatDataFromDB()
                                    self.userDefault.set(true, forKey: kCatSaved)
                                    self.userDefault.synchronize()
                                }else {
                                    self.showAlert(titleText: "Error", alertMsg: "Unable to store data in Database for offline use")
                                }
                            }
                        }
                        if let ranking = json![kRankings] as? [[String: Any]] {
                            self.getRanking(json: ranking)
                            
                            if !self.userDefault.bool(forKey: kRankSaved) {
                                let bool = self.saveRankingData(with: ranking)
                                if bool {
                                    self.rankItems = self.fetchRankDataFromDB()
                                    self.userDefault.set(true, forKey: kRankSaved)
                                    self.userDefault.synchronize()
                                }else {
                                    self.showAlert(titleText: "Error", alertMsg: "Unable to store data in Database for offline use")
                                }
                            }
                        }
                    }else {
                        self.stopAnimating()
                    }
                }
            })
        }else {
            networkAvailable = false
//            readLocalJsonFile()
            if self.userDefault.bool(forKey: kRankSaved) && self.userDefault.bool(forKey: kCatSaved) {
                coreItems = self.fetchCatDataFromDB()
                rankItems = self.fetchRankDataFromDB()
                print(rankItems)
                fetchProduct(all: true, single: false)
            }else {
                showAlert(titleText: "Info", alertMsg: "Oops Data haven't stored in Database, Kindly connect to network and store data for offline use")
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
    
    func readLocalJsonFile() {
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
    }
    
    /**
     * The method is used to get all products or particular category products
     * Boolean parameter need to pass to identify all Products or category products
     * The Product variable will be prepared here
     * The method will be called after getting data first time
     * Second time when select the filter from Side Menu Table
     * once product is ready, reload the collection view
     */
    
    func fetchProduct(all isAll: Bool, single isSingle: Bool) {
        if networkAvailable {
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
    
        } else {
            prodItems.removeAll()
            if isAll {
                for category in coreItems {
                    for product in category.products! {
                        let p = product as! Products
                        prodItems.append(p)
                    }
                }
            }
            
            if isSingle {
                for ids in selectedCat {
                    let temp1 = coreItems.filter{$0.id == Int32(ids)}
                    for category in temp1 {
                        for product in category.products! {
                            let p = product as! Products
                            prodItems.append(p)
                        }
                    }
                }
            }
        }
        sortProductList(forSegment: selectedSegmentIndex)
        collectionView.reloadData()
    }
    
    /**
     * The method is used to get all three types of ranking
     * It's pre assumed here that there were three types of rankings
     * Parameter as JSON response received from the Server
     * rankings variable will be prepared here
     * this variable is used to sort the product list as per segment selection
     */
    
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
    
    /**
     * The method is used to prepare the list of category ids, whose product need to be displayed
     * parameter the index value of category items
     */
    
    func getSelectedIds(forIndex: Int) {
        if networkAvailable {
            if cItems[forIndex].products.count > 0 {
                selectedCat.append(cItems[forIndex].id!)
            } else {
                childIds = cItems[forIndex].childCategories
                getSubIDs(from: childIds)
            }
        }else {
            if (coreItems[forIndex].products?.count) != 0 {
                selectedCat.append(Int(coreItems[forIndex].id))
            } else {
                childIds = coreItems[forIndex].child as! [Int]
                getSubIDs(from: childIds)
            }
        }
        
        print(selectedCat)
        fetchProduct(all: false, single: true)
    }
    
    /**
     * This method is used to fetch sub categories
     * it will prepare the list of all categories by iterating through child categories
     * finally we have those categories who doesn't have child
     */
    
    func getSubIDs(from: [Int]) {
        if networkAvailable {
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
        } else {
            for ids in from {
                let count = coreItems.filter{$0.id == ids}.map{$0.products?.count}[0]
                if count == 0 {
                    let cat = coreItems.filter{$0.id == ids}
                    childIds = cat[0].child as! [Int]
                    getSubIDs(from: childIds)
                }else {
                    selectedCat.append(ids)
                    childIds.removeFirst()
                }
            }
        }
    }
    
    /**
     * The method is used to sort the product list based on ranking
     * recieve the int parameter which will used to denote based on which ranking need to sort
     */
    
    func sortProductList(forSegment: Int) {
        if networkAvailable {
            let sorted = pItems.map{$0.id!}.reorder(by: rankings[forSegment])
            let ordering = Dictionary(uniqueKeysWithValues: sorted.enumerated().map { ($1, $0) })
            pItems = pItems.sorted{ ordering[$0.id!]! < ordering[$1.id!]! }
        } else {
            switch forSegment {
            case 0:
                let sorted = prodItems.map{$0.id}.reorder(by: rankItems[0].mostviewed as! [Int32])
                let ordering = Dictionary(uniqueKeysWithValues: sorted.enumerated().map { ($1, $0) })
                prodItems = prodItems.sorted{ ordering[$0.id]! < ordering[$1.id]! }
            case 1:
                let sorted = prodItems.map{$0.id}.reorder(by: rankItems[0].mostordered as! [Int32])
                let ordering = Dictionary(uniqueKeysWithValues: sorted.enumerated().map { ($1, $0) })
                prodItems = prodItems.sorted{ ordering[$0.id]! < ordering[$1.id]! }
            case 2:
                let sorted = prodItems.map{$0.id}.reorder(by: rankItems[0].mostsahred as! [Int32])
                let ordering = Dictionary(uniqueKeysWithValues: sorted.enumerated().map { ($1, $0) })
                prodItems = prodItems.sorted{ ordering[$0.id]! < ordering[$1.id]! }
            default:
                print("Wrong Index")
            }
            
        }
    }
    
    /**
     * This method u=is used to basic view setup
     * here it is responsible to sho and hide the filter
     * receive parameter as booloean to show and hide identification
     */
    
    func viewSetUp(hideView: Bool) {
        if !hideView {
            showHideBtn.setTitle("Filter Hide", for: .normal)
            sideView.isHidden = false
        }else {
            showHideBtn.setTitle("Filter Show", for: .normal)
            sideView.isHidden = true
        }
        tableView.reloadData()
    }
    
    /**
     * this method is used to register table and collection view coustom cells
     * also used to set the height and width of the coustom cell
     */
    
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
    
    /**
     * The method is used to show activity indicator over the view
     */
    
    func startAnimating() {
        activityIndicator.center = self.view.center
        activityIndicator.hidesWhenStopped = true
        activityIndicator.activityIndicatorViewStyle = .gray
        view.addSubview(activityIndicator)
        
        activityIndicator.startAnimating()
        UIApplication.shared.beginIgnoringInteractionEvents()
    }
    
    /**
     * the method is used to stop activity indicator and start interacrtions
     */
    
    func stopAnimating() {
        activityIndicator.stopAnimating()
        UIApplication.shared.endIgnoringInteractionEvents()
    }
    
    //MARK: - Alert
    
    func showAlert(titleText:String, alertMsg:String) {
        stopAnimating()
        let alert = UIAlertController(title: titleText, message:alertMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            
        })
        self.present(alert, animated: true, completion: nil)
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
    
    //MARK: - End of Class
}



//MARK: - UICollectionViewDelegate

extension ViewController: UICollectionViewDelegate {
    
}

//MARK: - UICollectionViewDataSource

extension ViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        if networkAvailable {
            return pItems.count
        } else {
            return prodItems.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if networkAvailable {
            return pItems[section].variants.count
        } else {
            return (prodItems[section].variants?.count)!
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: String(describing: CollectionViewCell.self), for: indexPath) as! CollectionViewCell
        if networkAvailable {
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
            
        }else {
            let variant = prodItems[indexPath.section].variants
            let cellItem = variant?.allObjects[indexPath.item] as? Variants
            if let color = cellItem?.color {
                cell.colorLbl.text = color
            }else{
                cell.colorLbl.text = "NA"
            }
            
            if let size = cellItem?.size {
                cell.sizeLbl.text = String(size)
            }else {
                cell.sizeLbl.text = "NA"
            }
            
            if let price = cellItem?.price {
                cell.priceLbl.text = String(price)
            }else{
                cell.priceLbl.text = "NA"
            }
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
            if networkAvailable {
                headerView.label.text = pItems[indexPath.section].name
            }else {
                headerView.label.text = prodItems[indexPath.section].name
            }
            
            return headerView
        default:
            
            assert(false, "Unexpected element kind")
        }
    }
}

//MARK: - UITableViewDataSource

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if networkAvailable {
            return cItems.count + 1
        }else {
            return coreItems.count + 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        
        let tableCell = tableView.dequeueReusableCell(withIdentifier: String(describing: CustomTableViewCell.self), for: indexPath) as! CustomTableViewCell
        if indexPath.row == 0 {
            tableCell.label.text = "All"
        }else {
            if networkAvailable {
                tableCell.label.text = cItems[indexPath.row - 1].name
            }else {
                tableCell.label.text = coreItems[indexPath.row - 1].name
            }
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
