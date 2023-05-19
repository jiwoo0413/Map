//
//  ViewController.swift
//  Map
//
//  Created by 홍지우 on 2023/05/16.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var uploadButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        uploadButton.addTarget(self, action: #selector(buttonTapped), for: .touchUpInside)

    @objc func buttonTapped() {
        fetchCinValueFromMobiusServer()
    }
    
    func fetchCinValueFromMobiusServer() {
        var request = URLRequest(url: URL(string: "http://203.253.128.177:7579/Mobius/zz/Map/latest")!,timeoutInterval: Double.infinity)
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("12345", forHTTPHeaderField: "X-M2M-RI")
        request.addValue("SOrigin", forHTTPHeaderField: "X-M2M-Origin")

        request.httpMethod = "GET"
        
        let task = URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                print("Error: \(error)")
                DispatchQueue.main.async {
                    self.uploadButton.tintColor = .red
                }
                return
            }
            
            guard let data = data else {
                print("No data received")
                DispatchQueue.main.async {
                    self.uploadButton.tintColor = .red
                }
                return
            }
            
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                print(json)
                if let m2mCin = json as? [String: Any], let cin = m2mCin["m2m:cin"] as? [String: Any] {
                    let conValue = cin["con"] as? String
                    print(conValue)
                    DispatchQueue.main.async {
                        self.openSafari(with: conValue ?? "N/A")
                    }
                } else {
                    print("Invalid JSON format or missing 'cin' key")
                    DispatchQueue.main.async {
                        self.uploadButton.tintColor = .red
                    }
                }
            } catch {
                print("Error decoding JSON: \(error)")
                DispatchQueue.main.async {
                    self.uploadButton.tintColor = .red
                }
            }
        }
        
        task.resume()
    }
    
    func openSafari(with cinValue: String) {
        guard let safariURL = URL(string: "https://www.example.com/(cinValue)") else {
            print("Invalid URL")
            DispatchQueue.main.async {
                self.uploadButton.tintColor = .red
            }
            return
        }
        
        if UIApplication.shared.canOpenURL(safariURL) {
            UIApplication.shared.open(safariURL)
        } else {
            print("Unable to open Safari")
            DispatchQueue.main.async {
                self.uploadButton.tintColor = .red
            }
        }
    }

}

