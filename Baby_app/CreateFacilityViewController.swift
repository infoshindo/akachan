//
//  CreateFacilityViewController.swift
//  Baby_app
//
//  Created by infosquare on 2018/01/18.
//  Copyright © 2018年 堀内慶. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON

class CreateFacilityViewController: UIViewController, UIPickerViewDelegate, UIPickerViewDataSource {

    @IBOutlet weak var facilityLabel: UILabel!
    @IBOutlet weak var evaluationLabel: UILabel!
    @IBOutlet weak var commentField: UITextField!
    @IBOutlet weak var selectbox: UITextField!

    var pickerView: UIPickerView!
    let list = ["1", "2", "3", "4", "5"]
    var facility_id = ""
    var commentString = ""
    var evalueString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // UserDefaultsの値を取得
        let ud = UserDefaults.standard
        facility_id = ud.string(forKey: "id")!
        let name = ud.string(forKey: "name")
        facilityLabel.text = name

        var evaluation = "- 評価はありません"
        if (ud.string(forKey: "evalue") != nil)
        {
            evaluation = "評価:"
            let star = ud.string(forKey: "evalue")
            evaluation += String(repeating:"★", count:Int(star!)!)
            evaluation += String(repeating:"☆", count:(5 - Int(star!)!))
        }
        evaluationLabel.text = evaluation

        pickerView = UIPickerView()
        pickerView.delegate = self
        pickerView.dataSource = self
        pickerView.showsSelectionIndicator = true
        
        selectbox.text = "評価を選択してください"

        selectbox.inputView = pickerView
        
        // Do any additional setup after loading the view.
    }

    // ボタン押下時のアクション
    @IBAction func pushButton(_ sender: UIButton) {
        // コメントと評価を取得
        commentString = commentField.text!
        evalueString = selectbox.text!
        print(facility_id + "と" + commentString + "と" + evalueString)
        
        Alamofire.request("http://pasgroup:rem3shs3days@akachan.northbay.biz/regist_info", parameters: ["facility_id": facility_id,"comment_detail": commentString,"comment_value": evalueString])
            .responseJSON{ response in
            }
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commentField.resignFirstResponder()
        selectbox.resignFirstResponder()
        return true
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        commentField.resignFirstResponder()
        selectbox.resignFirstResponder()
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.list[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectbox.text = list[row]
    }
    
    func CGRectMake(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) -> CGRect {
        return CGRect(x: x, y: y, width: width, height: height)
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
