//
//  HamburgerViewController.swift
//  TwitterRedux
//
//  Created by Kavita Gaitonde on 10/4/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit

class HamburgerViewController: UIViewController {

    @IBOutlet weak var menuView: UIView!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var contentLeftMarginConstraint: NSLayoutConstraint!
    
    var menuViewController: UIViewController! {
        didSet {
            view.layoutIfNeeded()
            menuView.addSubview(menuViewController.view)
        }
    }
    
    var originalLeftMargin: CGFloat!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func handlePan(_ sender: UIPanGestureRecognizer) {
        let translation = sender.translation(in: view)
        let velocity = sender.velocity(in: view)
        switch sender.state {
        case UIGestureRecognizerState.began:
            originalLeftMargin = contentLeftMarginConstraint.constant
            print ("BEGAN  translation.x -- \(translation.x)")
            print ("BEGAN  originalleftmargin -- \(originalLeftMargin)")
            break
        case UIGestureRecognizerState.changed:
            contentLeftMarginConstraint.constant = originalLeftMargin + translation.x
            print ("CHANGED  translation.x -- \(translation.x)")
            print ("CHANGED  contentLeftMarginConstraint.constant -- \(contentLeftMarginConstraint.constant)")
            break
        case UIGestureRecognizerState.ended:
            UIView.animate(withDuration: 0.5, animations: {
                if velocity.x > 0 { //pan to right
                    self.contentLeftMarginConstraint.constant = self.view.frame.size.width - 50
                    print ("ENDED to right translation.x -- \(translation.x)")
                    print ("ENDED to right contentLeftMarginConstraint.constant -- \(self.contentLeftMarginConstraint.constant)")
                } else { //go back
                    self.contentLeftMarginConstraint.constant = 0
                    print ("ENDED to left translation.x -- \(translation.x)")
                    print ("ENDED to left contentLeftMarginConstraint.constant -- \(self.contentLeftMarginConstraint.constant)")

                }
            })
            break
        default: break
        }
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
