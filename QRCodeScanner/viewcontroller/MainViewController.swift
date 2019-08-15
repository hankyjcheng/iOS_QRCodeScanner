//
//  ViewController.swift
//  QRCodeScanner
//
//  Created by Hank Cheng on 10/2/18.
//  Copyright © 2018 Hank Cheng. All rights reserved.
//

import UIKit

protocol QRCodeScanDelegate {
    func onScanSuccess(text: String!)
}

class MainViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "mainToCamera") {
            let vc = segue.destination as! CameraViewController
            vc.delegate = self
        }
    }

}

extension MainViewController : QRCodeScanDelegate {
    func onScanSuccess(text: String!) {
        let alert = UIAlertController(title: "QRCode Scan Success", message: text, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(alert, animated: true)
    }
}

