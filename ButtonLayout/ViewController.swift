//
//  ViewController.swift
//  ButtonLayout
//
//  Created by Craig Siemens on 2020-09-15.
//  Copyright © 2020 Craig Siemens. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        showModal()
    }
    
    private func showModal() {
        // MARK: - 1. Present a navigation controller as a modal
        let viewController = UIViewController()
        viewController.view.backgroundColor = .blue
        
        let navigationController = UINavigationController(rootViewController: viewController)
        present(navigationController, animated: true, completion: nil)
        
        DispatchQueue.main.async {
            self.pushBrokenViewController(into: navigationController)
        }
    }
    
    private func pushBrokenViewController(into navigationController: UINavigationController) {
        
        // MARK: - 2. Push a view controller that contains a `BrokenButton` in a `scrollView`
        let viewController = ScrollViewController()
        
        /// Creating the button
        let button = BrokenButton(frame: CGRect(x: 0, y: 100, width: 320, height: 100))
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Now swipe to dismiss the modal", for: .normal)
        button.setImage(UIImage(systemName: "globe"), for: .normal)
                
        /// Setting this in `ScrollViewController.viewDidLoad` doesn't cause the issue. Also occurs with `UITableView`
        viewController.scrollView.addSubview(button)
        
        /// Must be animated, changing animated to false doesnt have the issue
        navigationController.pushViewController(viewController, animated: true)
    }
}


/// A view controller that contains a scroll view.
class ScrollViewController: UIViewController {
    let scrollView = UIScrollView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        scrollView.frame = view.bounds
        view.addSubview(scrollView)
    }
}

/// A button that can break modal pan to dismiss transition when all below are true.
/// - added to a scroll view
/// - thats in a view controller
/// - that pushed onto a navigation controller
/// - that's presented modally
class BrokenButton: UIButton {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setupSubviews()
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupSubviews() {
        // MARK: CAUSE - Dynamic tint color
        /// Commenting this out fixes it, also using a non dynamic color fixes it.
        tintColor = .systemRed
        //tintColor = .red
        
        let backgroundView = UIView()
        addSubview(backgroundView)
        
        // MARK: CAUSE - Positioning a subview with autolayout
        /// Is only an issue if this subview is positioned/sized using autolayout. Setting the frame instead doesn't have the issue.
        backgroundView.constrainEdgesEqualTo(self)
        //backgroundView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
    }
    
    override public func tintColorDidChange() {
        super.tintColorDidChange()
        
        // MARK: - CAUSE - Triggering layout in `tintColorDidChange`
        /// This was found by trying to update `imageView.tintColor` and finding that layout subviews was being called
        setNeedsLayout()
        layoutIfNeeded()
    }
}

// Helper, nothing special here.
extension UIView {
    func constrainEdgesEqualTo(_ otherView: UIView) {
        translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: otherView.leadingAnchor),
            trailingAnchor.constraint(equalTo: otherView.trailingAnchor),
            topAnchor.constraint(equalTo: otherView.topAnchor),
            bottomAnchor.constraint(equalTo: otherView.bottomAnchor)
        ])
    }
}
