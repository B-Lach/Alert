//
//  ViewController.swift
//  BLAlert
//
//  Created by B-Lach on 02/25/2017.
//  Copyright (c) 2017 B-Lach. All rights reserved.
//

import UIKit
import BLAlert
import SafariServices

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func error(_ sender: Any) {
        Alert.showError(title: "🚫 Short Error Title", message: "Something really messed up\nLine breaks are no problem")
    }
    @IBAction func warning(_ sender: Any) {
        Alert.showWarning(title: "⚠️ Attention",
                          message: "Did you already stared Alert on Github?\nTouch me to do so ❤️",
                          actionClosure: { [weak self] in
                            self?.openWebView()
                            
        })
    }
    
    @IBAction func success(_ sender: Any) {
        Alert.showSuccess(title: "✅ Sucess", message: "You sucessfully stared Alert on github 👍") {
            print("Success dismissed")
        }
    }
    @IBAction func custom(_ sender: Any) {
        Alert.showCustomAlert(title: "😱 Custom Alert Title", message: "Colors are beautiful\nDuration is changeable as well", textColor: .green, backgroundColor: UIColor.purple.withAlphaComponent(0.5), duration: 1.0)
    }
    
}

extension ViewController {
    func openWebView() {
        let url = URL(string: "https://github.com/B-Lach/Alert")!
        
        let vc = SFSafariViewController(url: url)
        present(vc, animated: true, completion: nil)
    }
}
