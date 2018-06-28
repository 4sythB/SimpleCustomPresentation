//
//  SideMenuInterruptibleAnimator.swift
//  SimpleCustomPresentation
//
//  Created by Brad Forsyth on 3/14/18.
//  Copyright © 2018 Bloom Built Inc. All rights reserved.
//

import UIKit


class SideMenuInterruptibleAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    
    let isPresentation: Bool
    
    init(isPresentation: Bool) {
        self.isPresentation = isPresentation
        super.init()
    }
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.2
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        self.interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let presentedKey = self.isPresentation ? UITransitionContextViewControllerKey.to : UITransitionContextViewControllerKey.from
        let presentingKey = self.isPresentation ? UITransitionContextViewControllerKey.from : UITransitionContextViewControllerKey.to
        
        guard let presentedViewController = transitionContext.viewController(forKey: presentedKey),
            let presentingViewController = transitionContext.viewController(forKey: presentingKey) else { return UIViewPropertyAnimator() }
        
        if self.isPresentation {
            transitionContext.containerView.addSubview(presentedViewController.view)
        }
        
        
        // -------------------------
        // Presented View Controller
        // -------------------------
        
        let presentedViewPresentedFrame = transitionContext.finalFrame(for: presentedViewController)
        var presentedViewDismissedFrame = presentedViewPresentedFrame
        presentedViewDismissedFrame.origin.x = -presentedViewPresentedFrame.width
        
        let presentedViewIntialFrame = isPresentation ? presentedViewDismissedFrame : presentedViewPresentedFrame
        let presentedViewFinalFrame = isPresentation ? presentedViewPresentedFrame : presentedViewDismissedFrame
        
        presentedViewController.view.frame = presentedViewIntialFrame
        
        
        // --------------------------
        // Presenting View Controller
        // --------------------------
        
        var presentingViewPresentedFrame = transitionContext.finalFrame(for: presentingViewController)
        
        if (UIScreen.main.bounds.width * SideMenuHelper.menuWidth) > 300 {
            presentingViewPresentedFrame.origin.x = 300
        } else {
            presentingViewPresentedFrame.origin.x = (UIScreen.main.bounds.width * SideMenuHelper.menuWidth)
        }
        
        let presentingViewDismissedFrame = transitionContext.finalFrame(for: presentingViewController)
        let presentingViewIntitalFrame = isPresentation ? presentingViewDismissedFrame : presentingViewPresentedFrame
        
        presentingViewController.view.frame = presentingViewIntitalFrame
        
        let presentingViewFinalFrame = isPresentation ? presentingViewPresentedFrame : presentingViewDismissedFrame
        
        
        // ---------
        // Animation
        // ---------
        
        let animator = UIViewPropertyAnimator(duration: self.transitionDuration(using: transitionContext), curve: .linear) {
            presentedViewController.view.frame = presentedViewFinalFrame
            presentingViewController.view.frame = presentingViewFinalFrame
        }
        
        animator.addCompletion { (_) in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        
        return animator
    }
}
