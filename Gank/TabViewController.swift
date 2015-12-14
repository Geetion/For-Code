//
//  TabViewController.swift
//  Gank
//
//  Created by Findys on 15/12/13.
//  Copyright © 2015年 GeekTeen. All rights reserved.
//

import UIKit

class TabViewController: UITabBarController,UITabBarControllerDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tabBarController(tabBarController: UITabBarController, didSelectViewController viewController: UIViewController){
        let window = UIApplication.sharedApplication().keyWindow
        let whiteView = UIView(frame: CGRect(x: 0, y: 0, width: WINDOW_WIDTH, height: WINDOW_HEIGHT))
        whiteView.backgroundColor = UIColor.whiteColor()
        window?.addSubview(whiteView)
        UIView.animateWithDuration(1) { () -> Void in
            whiteView.alpha = 0
        }
        whiteView.removeFromSuperview()
        print("123")
    }
    
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
}
