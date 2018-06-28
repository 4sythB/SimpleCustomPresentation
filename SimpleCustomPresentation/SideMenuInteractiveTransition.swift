//
//  SideMenuInteractiveTransition.swift
//  SimpleCustomPresentation
//
//  Created by Brad Forsyth on 3/14/18.
//  Copyright © 2018 Brad Forsyth. All rights reserved.
//

import UIKit


@objcMembers
class SideMenuInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var hasStarted = false
    var shouldFinish = false
}

@objc enum SwipeDirection: Int {
    case up
    case down
    case left
    case right
}

@objcMembers
class SideMenuHelper: NSObject {
    
    static let menuWidth: CGFloat = 0.8
    static let percentThreshold: CGFloat = 0.3
    
    @objc static func calculateProgress(translationInView: CGPoint, viewBounds: CGRect, direction: SwipeDirection) -> CGFloat {
        let pointOnAxis: CGFloat
        let axisLength: CGFloat
        
        switch direction {
        case .up, .down:
            pointOnAxis = translationInView.y
            axisLength = viewBounds.height
        case .left, .right:
            pointOnAxis = translationInView.x
            axisLength = viewBounds.width
        }
        
        let movementOnAxis = pointOnAxis / axisLength
        let positiveMovementOnAxis: Float
        let positiveMovementOnAxisPercent: Float
        
        switch direction {
        case .right, .down: // positive
            positiveMovementOnAxis = fmaxf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fminf(positiveMovementOnAxis, 1.0)
            return CGFloat(positiveMovementOnAxisPercent)
        case .up, .left: // negative
            positiveMovementOnAxis = fminf(Float(movementOnAxis), 0.0)
            positiveMovementOnAxisPercent = fmaxf(positiveMovementOnAxis, -1.0)
            return CGFloat(-positiveMovementOnAxisPercent)
        }
    }
    
    static func mapGestureStateToInteractor(gestureState: UIGestureRecognizerState, progress: CGFloat, interactor: SideMenuInteractiveTransition?, triggerSegue: () -> Void) {
        guard let interactor = interactor else { return }
        switch gestureState {
        case .began:
            interactor.hasStarted = true
            triggerSegue()
        case .changed:
            interactor.shouldFinish = progress > percentThreshold
            interactor.update(progress)
        case .cancelled:
            interactor.hasStarted = false
            interactor.cancel()
        case .ended:
            interactor.hasStarted = false
            interactor.shouldFinish ? interactor.finish() : interactor.cancel()
        default:
            break
        }
    }
}
