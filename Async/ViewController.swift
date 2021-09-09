//
//  ViewController.swift
//  Async
//
//  Created by jinren on 2021/9/9.
//

import UIKit

class ViewController: UIViewController {

    
    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    @IBAction func downloadBtn(_ sender: Any) {
        self.imgView.image = nil
        
        traditionalDownload()
//        awaitDownload()
    }
    
    func awaitDownload() {
        print("start awaitDownload ----1-----")

        Task {
            print("start Task")
            print("start download \(Thread.current)")
            let (data, response) = try await URLSession.shared.data(from: URL(string: "https://miro.medium.com/max/1400/1*6-G_o5PZSzppyfdLTbFu-A.png")!, delegate: nil)
            print("complete download \(Thread.current)")
            let res = response as! HTTPURLResponse
            if res.statusCode == 200 {
                if let img = UIImage(data: data) {
                    self.imgView.image = img
                }
            }
            print("end Task")
        }

        print("end awaitDownload ----1-----")
    }
    
    func traditionalDownload() {
        print("start traditionalDownload ----1-----")
        let task = URLSession.shared.dataTask(with: URL(string: "https://miro.medium.com/max/1400/1*6-G_o5PZSzppyfdLTbFu-A.png")!) { data, response, error in
            print("download completeHandle \(Thread.current)")
            let httpRes = response as! HTTPURLResponse
            if httpRes.statusCode == 200 {
                DispatchQueue.main.async {
                    print("update imageview \(Thread.current)")
                    self.imgView.image = UIImage(data: data!)
                }
            }
        }
        task.resume()
    }
    
}



