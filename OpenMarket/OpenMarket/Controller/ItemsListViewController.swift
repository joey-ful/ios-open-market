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
        initializeItemsList(at: 1)
        initializeCollectionViewLayout()
    }
    
    private func initializeItemsList(at pageNumber: Int) {
        var urlComponents = URLComponents(string: "https://camp-open-market-2.herokuapp.com")
        urlComponents?.path = "/items/\(pageNumber)"
        
        guard let url = urlComponents?.url else { return }

        manager.fetchData(url: url) { (result: Result<Page, Error>) in
            switch result {
            case .success(let decodedData):
                self.items = decodedData.items
                DispatchQueue.main.async {
                    self.listCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func initializeCollectionViewLayout() {
        if let layout = listCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            layout.minimumInteritemSpacing = 10
            layout.minimumLineSpacing = 10
            
            layout.sectionInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "gridCell", for: indexPath) as? GridItemCell else {
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
        
        let numberOfItemsPerRow: CGFloat = 2 // 한 줄에 2개의 셀
        let bounds = collectionView.bounds // collectionView 자체 부분 - 마진 + 내용
        let contentWidth = bounds.width - (layout.sectionInset.left + layout.sectionInset.right) // 내용이 보여지는 부분
        let width = (contentWidth - (layout.minimumLineSpacing * (numberOfItemsPerRow - 1))) / numberOfItemsPerRow // 셀 너비
        let height = width * 10/7

        return CGSize(width: width, height: height)
    }
    
//    func collectionView(_ collectionView: UICollectionView,
//                        layout collectionViewLayout: UICollectionViewLayout,
//                        sizeForItemAt indexPath: IndexPath) -> CGSize
//    {
//        guard let layout = collectionViewLayout as? UICollectionViewFlowLayout else { return CGSize.zero }
//
//        let verticalNumberOfItems: CGFloat = 12
//        let horizontalNumberOfItems: CGFloat = 2
//        let bounds = collectionView.bounds
//        let contentWidth = bounds.width - (layout.sectionInset.left + layout.sectionInset.right)
//        let contentHeight = bounds.height - (layout.sectionInset.top + layout.sectionInset.bottom)
//        var width: CGFloat
//        var height: CGFloat
//
//        switch layout .scrollDirection {
//        case .vertical:
//            width = contentWidth
//            height = (contentHeight - (layout.minimumLineSpacing * (verticalNumberOfItems - 1))) / verticalNumberOfItems
//        case .horizontal:
//            width = (contentWidth - (layout.minimumLineSpacing * (horizontalNumberOfItems - 1))) / horizontalNumberOfItems
//            height = width * 2 / 3
//        @unknown default:
//            fatalError()
//        }
//
//        return CGSize(width: width, height: height)
//    }
}
