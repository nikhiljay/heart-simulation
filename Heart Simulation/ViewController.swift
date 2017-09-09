//
//  ViewController.swift
//  Heart Simulation
//
//  Created by Nikhil D'Souza on 7/11/17.
//  Copyright © 2017 Nikhil D'Souza. All rights reserved.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate, UITextFieldDelegate {

    @IBOutlet var sceneView: ARSCNView!
    let numberToolbar: UIToolbar = UIToolbar()
    let scene = SCNScene(named: "art.scnassets/Heart.dae")!
    
    var pumping: Bool = false
    var bpm: Double = 72.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        sceneView.delegate = self
        
        //Textfield
        let textField = UITextField(frame: CGRect(x: 20, y: 30, width: self.view.frame.width-40, height: 30))
        textField.placeholder = "Enter BPM here"
        textField.font = UIFont.systemFont(ofSize: 15)
        textField.borderStyle = UITextBorderStyle.roundedRect
        textField.keyboardType = UIKeyboardType.numberPad
        textField.contentVerticalAlignment = UIControlContentVerticalAlignment.center
        textField.textAlignment = NSTextAlignment.center
        textField.delegate = self
        self.view.addSubview(textField)
        
        //Done button
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexLeft = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let flexRight = UIBarButtonItem(barButtonSystemItem: .fixedSpace,
                                        target: nil, action: nil)
        flexRight.width = 10
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done,
                                            target: view, action: #selector(UIView.endEditing(_:)))
        keyboardToolbar.items = [flexLeft, doneBarButton, flexRight]
        textField.inputAccessoryView = keyboardToolbar
        
        let heartNode = scene.rootNode.childNode(withName: "Heart", recursively: true)
        heartNode?.position = SCNVector3Make(0, 0, -1)
        
        sceneView.scene = scene
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let number = Double(textField.text!) {
            if number > 300 {
                let alert = UIAlertController(title: "Error", message: "Heart rate is way too high.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else if number == 0 {
                let alert = UIAlertController(title: "Error", message: "This is not a dead person simulator.", preferredStyle: UIAlertControllerStyle.alert)
                alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            } else {
                bpm = number
                pump()
            }
        } else {
            let alert = UIAlertController(title: "Error", message: "Not a valid number: \(textField.text!)", preferredStyle: UIAlertControllerStyle.alert)
            alert.addAction(UIAlertAction(title: "Ok", style: UIAlertActionStyle.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        pumping = !pumping
        pump()
    }
    
    func pump() {
        let heart = scene.rootNode.childNode(withName: "Heart", recursively: true)
        
        if pumping == true {
            heart?.removeAllActions()
            let expand = SCNAction.scale(by: 1.2, duration: 21.6/bpm) //systole part 1
            let contract = SCNAction.scale(by: 0.8333, duration: 7.2/bpm) //systole part 2
            let delay = SCNAction.wait(duration: 28.8/bpm) //diastole
            let pumpSequence = SCNAction.sequence([expand, contract, delay])
            heart?.runAction(SCNAction.repeatForever(pumpSequence))
        } else {
            let reset = SCNAction.scale(to: 2, duration: 0)
            heart?.removeAllActions()
            heart?.runAction(reset)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let configuration = ARWorldTrackingConfiguration()
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        sceneView.session.pause()
    }
}
