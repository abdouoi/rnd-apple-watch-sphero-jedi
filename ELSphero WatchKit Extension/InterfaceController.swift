//
//  InterfaceController.swift
//  ELSphero WatchKit Extension
//
//  Created by Dmitriy on 1/11/16.
//  Copyright © 2016 Dmitriy. All rights reserved.
//

import WatchKit
import Foundation
import CoreMotion
import WatchConnectivity

enum States:Int{
    case Back = 0, Stop, Right, Left, Direct
}

class InterfaceController: WKInterfaceController {
    
    @IBOutlet weak var labelX: WKInterfaceLabel!
    @IBOutlet weak var labelY: WKInterfaceLabel!
    @IBOutlet weak var labelZ: WKInterfaceLabel!
    @IBOutlet weak var labelState: WKInterfaceLabel!
    @IBOutlet weak var labelCount: WKInterfaceLabel!
    let motionManager = CMMotionManager()

    override func awakeWithContext(context: AnyObject?) {
        super.awakeWithContext(context)
        
        motionManager.accelerometerUpdateInterval = 0.5
    }
    
    override func willActivate() {
        super.willActivate()
        
        var state:States = States.Back
        var prevState:States = States.Back
        let count: Int = 0
        
        if (motionManager.accelerometerAvailable == true) {
            let handler:CMAccelerometerHandler = {
                (data: CMAccelerometerData?, error: NSError?) -> Void in
                self.labelX.setText(String(format: "%.2f", data!.acceleration.x))
                self.labelY.setText(String(format: "%.2f", data!.acceleration.y))
                self.labelZ.setText(String(format: "%.2f", data!.acceleration.z))
                
                //Change the state if needed
                if data!.acceleration.x >= 0.85 {
                    prevState = state
                    state = States.Back
                }
                else if data!.acceleration.x <= -0.85{
                    prevState = state
                    state = States.Stop
                }
                else if data!.acceleration.y >= 0.85{
                    prevState = state
                    state = States.Right
                }
                else if data!.acceleration.y <= -0.85{
                    prevState = state
                    state = States.Left
                }
                else if abs(data!.acceleration.z) >= 0.85{
                    prevState = state
                    state = States.Direct
                }
                
                // Send the message if the state changed
                if state == States.Back && prevState != States.Back {
                    self.sendMessage("Back")
                }
                else if state == States.Stop && prevState != States.Stop{
                    self.sendMessage("Stop")
                }
                else if state == States.Right && prevState != States.Right{
                    self.sendMessage("Right")
                }
                else if state == States.Left && prevState != States.Left{
                    self.sendMessage("Left")
                }
                else if state == States.Direct && prevState != States.Direct{
                    self.sendMessage("Direct")
                }
                
                self.labelState.setText(String(format: "%i", state.rawValue))
                self.labelCount.setText(String(format: "%i",count))

            }
            motionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.currentQueue()!, withHandler: handler)
        }
        else {
            self.labelX.setText("not available")
            self.labelY.setText("not available")
            self.labelZ.setText("not available")
        }
    }
    
    override func didDeactivate() {
        super.didDeactivate()
        
        motionManager.stopAccelerometerUpdates()
    }
    
    
    var session: WCSession? {
        didSet {
            if let session = session {
                session.delegate = self
                session.activateSession()
            }
        }
    }

    func sendMessage(direction:String){
        
        session = WCSession.defaultSession()
        
        if session == nil{
            self.sendMessage(direction)
            return
        }
    
        session!.sendMessage(["direction": direction], replyHandler: { (response) -> Void in

        },
        errorHandler: { (error) -> Void in
            
                print(error)
                self.sendMessage(direction)
        })
    }

}

extension InterfaceController: WCSessionDelegate {
    
}
