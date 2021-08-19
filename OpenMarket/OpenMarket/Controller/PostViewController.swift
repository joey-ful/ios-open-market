//
//  ItemDetailViewController.swift
//  OpenMarket
//
//  Created by 홍정아 on 2021/08/18.
//

import UIKit

class PostViewController: UIViewController {
    let manager = NetworkManager(session: URLSession.shared)
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var descriptionsTextField: UITextField!
    @IBOutlet weak var priceTextField: UITextField!
    @IBOutlet weak var currencyTextField: UITextField!
    @IBOutlet weak var discountedPriceTextField: UITextField!
    @IBOutlet weak var stockTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func postButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text,
              let descriptions = descriptionsTextField.text,
              let priceString = priceTextField.text,
              let currency = currencyTextField.text,
              let stockString = stockTextField.text,
              let password = passwordTextField.text,
              let price = Int(priceString),
              let stock = Int(stockString)
        else {
            return showNotificationAlert(message: "필수 항목을 모두 입력해주세요", actionTitle: "OK")
        }

        let url = URL(string: "https://camp-open-market-2.herokuapp.com/item")!

        var parametersChoco: [String : Any] = [
            "title": title,
            "descriptions": descriptions,
            "price": price,
            "currency": currency,
            "stock": stock,
            "password": password
        ]

        if let discountedPriceString = discountedPriceTextField.text, let discountedPrice = Int(discountedPriceString) {
            parametersChoco["discounted_price"] = Int(discountedPrice)
        }

        guard let imageFile = Media(withImage: #imageLiteral(resourceName: "lego"), forKey: "images[]") else { return }

        manager.postData(url: url, parameters: parametersChoco, images: [imageFile])
        
        dismiss(animated: true, completion: nil)
    }
    
    func showNotificationAlert(message: String, actionTitle: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: actionTitle, style: .default)
        alert.addAction(okAction)
        present(alert, animated: true, completion: nil)
    }
}
