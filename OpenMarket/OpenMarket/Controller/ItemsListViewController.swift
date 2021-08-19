//
//  OpenMarket - ViewController.swift
//  Created by yagom. 
//  Copyright © yagom. All rights reserved.
// 

import UIKit

class ItemsListViewController: UIViewController {
    private let manager = NetworkManager(session: URLSession.shared)
    private var items: [Page.Item]?
    @IBOutlet weak var listCollectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeItems()
        initializeCollectionViewLayout()
    }
    
    private func initializeItems() {
        let parsedResult = try? NSDataAsset(name: MockURL.mockItems.description)?.data.parse(type: Page.self)
        switch parsedResult {
        case .success(let decodedData):
            self.items = decodedData.items
        case .failure(let error):
            print(error)
        case .none:
            print("none")
        }
//        guard let url = URL(string: "https://camp-open-market-2.herokuapp.com/items/1") else { return }
//
//        manager.fetchData(url: url) { (result: Result<Page, Error>) in
//            switch result {
//            case .success(let decodedData):
//                self.items = decodedData.items
//            case .failure(let error):
//                print(error)
//            }
//        }
    }
    
    private func initializeCollectionViewLayout() {
        if let layout = listCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.itemSize = CGSize(width: 100, height: 100)
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
    }
    
    @IBAction func toggleButtonTapped(_ sender: Any) {
        guard let layout = listCollectionView.collectionViewLayout as? UICollectionViewFlowLayout else { return }

        listCollectionView.performBatchUpdates({
            layout.scrollDirection = (layout.scrollDirection == .vertical) ? .horizontal : .vertical
        }, completion: nil)
    }
}


extension ItemsListViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        items?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCell else {
            return UICollectionViewCell()
        }
        
        cell.updateContent(at: indexPath, items: items, collectionView: collectionView)
        return cell
    }
}

extension ItemsListViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize
    {
        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
        
        let verticalNumberOfItems: CGFloat = 12
        let horizontalNumberOfItems: CGFloat = 2
        let bounds = collectionView.bounds
        let contentWidth = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
        let contentHeight = bounds.height - (layout.sectionInset.top + layout.sectionInset.bottom)
        var width: CGFloat
        var height: CGFloat
        
        switch layout .scrollDirection {
        case .vertical:
            width = contentWidth
            height = (contentHeight - (layout.minimumLineSpacing * (verticalNumberOfItems - 1))) / verticalNumberOfItems
        case .horizontal:
            width = (contentWidth - (layout.minimumLineSpacing * (horizontalNumberOfItems - 1))) / horizontalNumberOfItems
            height = width * 2 / 3
        @unknown default:
            fatalError()
        }
        
        return CGSize(width: width, height: height)
    }
}
