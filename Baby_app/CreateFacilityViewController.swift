//
//  CreateFacilityViewController.swift
//  Baby_app
//
//  Created by infosquare on 2018/01/18.
//  Copyright © 2018年 堀内慶. All rights reserved.
//

import UIKit

class CreateFacilityViewController: UIViewController {

    @IBOutlet weak var facilityLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UserDefaultsの値を取得
        let ud = UserDefaults.standard
        let name = ud.string(forKey: "name")
        facilityLabel.text = name
        print(ud.string(forKey: "name"))
        print(ud.string(forKey: "lat"))
        print(ud.string(forKey: "long"))

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesEnded(touches, with: event)
        for touch: UITouch in touches {
            let tag = touch.view!.tag
            print(tag)
            if tag == 1 {
                dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func closeButton(_ sender: Any) {
        dismiss(animated: true, completion: nil)
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
