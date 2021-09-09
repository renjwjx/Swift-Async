//
//  ViewController.swift
//  Async
//
//  Created by jinren on 2021/9/9.
//

import UIKit


struct Counter : AsyncSequence {
    typealias Element = Int
    let howHigh: Int

    struct AsyncIterator : AsyncIteratorProtocol {
        let howHigh: Int
        var current = 1
        mutating func next() async -> Int? {
            // A genuinely asychronous implementation uses the `Task`
            // API to check for cancellation here and return early.
            guard current <= howHigh else {
                return nil
            }

            let result = current
            current += 1
            return result
        }
    }

    func makeAsyncIterator() -> AsyncIterator {
        return AsyncIterator(howHigh: howHigh)
    }
}


class ViewController: UIViewController {

    @IBOutlet weak var imgView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            await testConCurrencyCall()
        }
        Task {
            let myTasks:[String] = ["task1", "task2", "task3", "task4"]
            await test_testTaskGroup(tasks: myTasks)
        }
    }

    @IBAction func downloadBtn(_ sender: Any) {

        self.imgView.image = nil
        test_traditionalDownload()
//        test_awaitDownload()
    }
    
    func testConCurrencyCall() async {
        let handle = Task {
            print("-------testConCurrencyCall-1--\(NSDate())-----")
            let _ = await doSomething()
            let _ = await doSomething()
            let _ = await doSomething()
            let _ = await doSomething()
            print("-------testConCurrencyCall-2---\(NSDate())----")
            async let a = doSomething()
            async let b = doSomething()
            async let c = doSomething()
            async let d = doSomething()
            print("-------testConCurrencyCall-3---\(NSDate())----")
            let all = await [a, b, c, d]
            print("-------testConCurrencyCall-4---\(NSDate())----")
        }
        print("-------testConCurrencyCall-5---\(NSDate())----")
        let _ = await handle.value
        print("conCureencyCall end ")
    }
    
    func test_awaitDownload() {
        print("start test_awaitDownload ----1-----")

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

        print("end test_awaitDownload ----1-----")
    }
    
    func test_traditionalDownload() {
        print("start test_traditionalDownload ----1-----")
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
    
    func doSomething() async -> String {
        print("async doSomething \(Thread.current)");
        await Task.sleep(1 * 1_000_000_000)
        return "doSomething"
    }

    func processTasks(title: String) async -> String {
        print("start processTasks \(title)")
        await Task.sleep(1 * 1_000_000_000)
        let res = title + " is Done"
        print(res)
        return res
    }
    
    func test_testTaskGroup(tasks: [String]) async ->[String] {
       return await withTaskGroup(of: String.self) { taskGroup in
            for task in tasks {
                taskGroup.addTask(priority: .high) {
                    let res = await self.processTasks(title: task)
                    return res
                }
            }
            var result = [String]()
            for await res in taskGroup {
                result.append(res)
            }
            return result
        }
    }
}


