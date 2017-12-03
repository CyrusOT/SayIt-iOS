//
//  ViewController.swift
//  kk
//
//  Created by Ahmed AlOtaibi on 12/2/17.
//  Copyright © 2017 Ahmed AlOtaibi. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var camView: UIView!
    @IBOutlet weak var upperLabel: RoundedShadowView!
    @IBOutlet weak var captureView: RoundedShadowImage!
    @IBOutlet weak var flashButton: RoundedShadowButton!
    @IBOutlet weak var idLabel: UILabel!
    @IBOutlet weak var confidenceLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

