//
//  BaseViewController.swift
//  loreal-brush_bar-ios
//
//  Created by Jonathan Gwilliams on 30/08/2016.
//  Copyright © 2016 Sane Mubaloo. All rights reserved.
//

import UIKit

/**
 All view controllers descend from this basic model, making this a useful point for
 extending generic functionality that cannot be expressed in an extension.
 */

class BaseViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        transitioningDelegate = UIApplication.shared.delegate as? UIViewControllerTransitioningDelegate
    }
    
}
