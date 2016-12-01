//
//  TouchAuthentication.swift
//  SVUServiceManager
//
//  Created by Wee, David G. on 5/3/16.
//  Copyright © 2016 supervalu. All rights reserved.
//

import Foundation
import LocalAuthentication

public enum TOUCH_ERROR: String
{
    case accepted = "ACCEPTED"
    case failed = "FAILED"
    case user_CANCEL = "USER CANCELED"
    case fallback = "FALL BACK"
    case system_CANCEL = "SYSTEM CANCLED"
    case passcode_NOT_SET = "PASSCODE NOT SET"
    case touch_ID_NOT_AVAILABLE = "TOUCH ID NOT AVAILABLE"
    case touch_ID_NOT_ENROLLED = "TOUCH ID NOT ENROLLED"
}

open class TouchAuthentication:NSObject
{
    //String that tells user what touch Id id doing
    var myLocalizedReasonString : String = "Authentication is required"
    
    open func authenticateUser(authenticated:@escaping (_ auth:Bool, _ error:String?)->())
    {
        let context = LAContext()
        let enabled = isTouchIdEnabled()
        
        if enabled == .accepted
        {
            context.evaluatePolicy(LAPolicy.deviceOwnerAuthenticationWithBiometrics, localizedReason: myLocalizedReasonString, reply: { (success , evaluationError ) -> Void in
                if success
                {
                    authenticated(true, nil)
                }
                else
                {
                    authenticated(false, evaluationError?.localizedDescription)
                }
            })
        }
        else
        {
            authenticated(false, enabled.rawValue)
        }
        
    }
    
    
    //Check if touch is enabled on device
    open func isTouchIdEnabled() -> TOUCH_ERROR
    {
        let context = LAContext()
        var error:NSError?
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        {
            return .accepted
        }
        return getTouchErrorFromLAError(error!)
    }
    
    
    func setNewLocalizedReason(reasonStr:String)
    {
        myLocalizedReasonString = reasonStr
    }
    
    func getTouchErrorFromLAError(_ error:NSError) -> TOUCH_ERROR
    {
        switch(error.code)
        {
        case LAError.Code.systemCancel.rawValue:
            return .system_CANCEL
        case LAError.Code.userCancel.rawValue:
            return .user_CANCEL
        case LAError.Code.userFallback.rawValue:
            return .fallback
        case LAError.Code.passcodeNotSet.rawValue:
            return .passcode_NOT_SET
        case LAError.Code.touchIDNotEnrolled.rawValue:
            return .touch_ID_NOT_ENROLLED
        case LAError.Code.touchIDNotAvailable.rawValue:
            return .touch_ID_NOT_AVAILABLE
        default:
            return .failed
        }
    }
}
