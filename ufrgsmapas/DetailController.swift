//
//  DetailController.swift
//  ufrgsmapas
//
//  Created by Augusto Boranga on 26/02/19.
//  Copyright © 2019 UFRGS. All rights reserved.
//

import Foundation
import MapKit
import UIKit

class DetailController: UIViewController {
    
    // MARK: - Properties
    
    var buildings = [Building]()
    
    private var originalY: CGFloat = 0.0
    private var originalHeight: CGFloat = 0.0
    private var originalDragY: CGFloat = 0.0
    
    private var didConfigureCornerRadius: Bool = false
    
    var completionHandler: (() -> ())?
    
    // MARK: - IBOutlets
    
    @IBOutlet weak var alphaView: UIView!
    @IBOutlet weak var draggableView: UIView!
    @IBOutlet weak var draggableHeaderView: UIView!
    @IBOutlet weak var dragIndicatorView: UIView!
    
    @IBOutlet weak var draggableViewHeightContraint: NSLayoutConstraint!
    @IBOutlet weak var draggableViewTopContraint: NSLayoutConstraint!
    @IBOutlet weak var draggableViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var tableView: UITableView!
    
    // MARK: - Overrides
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // configuration calls
        configureTableView()
        configureViewsColors()
        configureDragRecognizer()
        configureDismissWhenTouched()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        self.originalHeight = calculateInitialHeight()
        animateViewsEntering()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if !didConfigureCornerRadius {
            didConfigureCornerRadius = true
            configureRoundedCorners()
        }
    }
    
    // MARK: - Animation methods
    
    private func animateViewsEntering() {
    
        // animate alpha view
        self.alphaView.alpha = 0.0
        self.alphaView.isHidden = false
        
        UIView.animate(withDuration: 0.3) {
            self.alphaView.alpha = 1.0
        }
        
        // animate draggable view
        self.draggableViewHeightContraint.constant = self.originalHeight
        self.draggableView.isHidden = false
        
        self.draggableView.center.y += self.originalHeight
        self.draggableView.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, animations: {
            self.draggableView.center.y -= self.originalHeight
            self.draggableView.layoutIfNeeded()
        }) { _ in
            self.originalY = self.draggableView.center.y
        }
        
    }
    
    private func animateDraggableViewToInitialPosition() {
        self.draggableViewHeightContraint.constant = originalHeight
        
        UIView.animate(withDuration: 0.25) {
            self.draggableView.center.y = self.originalY
            self.draggableView.layoutIfNeeded()
        }
    }
    
    private func animateViewsLeaving() {
    
        self.alphaView.isUserInteractionEnabled = false
        self.tableView.isUserInteractionEnabled = false
        self.draggableView.isUserInteractionEnabled = false
        
        UIView.animate(withDuration: 0.3, animations: {
            self.alphaView.alpha = 0.0
            self.draggableView.center.y += self.originalHeight
            self.draggableView.layoutIfNeeded()
        }) { _ in
            self.dismiss(animated: false, completion: nil)
            
            if let handler = self.completionHandler {
                handler()
            }
        }
    
    }
    
    private func calculateInitialHeight() -> CGFloat {
        
        tableView.layoutIfNeeded()
        
        var paddingTop: CGFloat = 80.0
        
        if UIScreen.main.bounds.height > 800.0 {
            paddingTop = 140.0
        }
        
        let height = draggableHeaderView.frame.size.height + tableView.contentSize.height
        let max = view.frame.size.height - paddingTop
        
        return min(height, max)
    }
    
    // MARK: - Configuration methods
    
    private func configureTableView() {
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = 126.0
        
        tableView.contentInset = UIEdgeInsets(top: 10.0, left: 0, bottom: 6.0, right: 0)
    }
    
    private func configureViewsColors() {
        draggableHeaderView.backgroundColor = .clear
    }
    
    private func configureRoundedCorners() {
        
        dragIndicatorView.clipsToBounds = true
        dragIndicatorView.layer.cornerRadius = dragIndicatorView.frame.height / 2
        
        let path = UIBezierPath(roundedRect: draggableView.bounds,
                                byRoundingCorners:[.topLeft, .topRight],
                                cornerRadii: CGSize(width: 16, height: 16))
        
        let maskLayer = CAShapeLayer()
        
        maskLayer.path = path.cgPath
        
        draggableHeaderView.clipsToBounds = true
        draggableView.clipsToBounds = true
        draggableView.layer.mask = maskLayer
        
    }
    
    private func configureDismissWhenTouched() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissView))
        self.alphaView.addGestureRecognizer(tap)
    }
    
    private func configureDragRecognizer() {
        let pan: UIPanGestureRecognizer = UIPanGestureRecognizer.init(target: self, action: #selector(didDrag(pan:)))
        self.draggableHeaderView.addGestureRecognizer(pan)
    }
    
    // MARK: - Actions
    
    @objc func dismissView() {
        self.animateViewsLeaving()
    }
    
    @objc func didDrag(pan:UIPanGestureRecognizer) {
        
        var translatedPoint = pan.translation(in: self.view)
        
        // drag started
        if pan.state == .began {
            self.originalDragY = draggableView.center.y
        }
        
        // drag was cancelled or ended
        if pan.state == .cancelled || pan.state == .ended {
            // if touch is bellow initial position of card, dismiss
            if draggableView.center.y > self.originalDragY {
                dismissView()
            // else animate back to original place
            } else {
                animateDraggableViewToInitialPosition()
            }
            return
        }
    
        translatedPoint = CGPoint(x: draggableView.center.x, y: self.originalDragY + translatedPoint.y)
    
        let originY = translatedPoint.y - (originalHeight / 2)
        let viewHeight = UIScreen.main.bounds.height - originY
        
        // allow drag only until 30 px above original card position
        if viewHeight <= self.originalHeight + 30.0 {
            UIView.animate(withDuration: 0.1, delay: 0, options: [.curveEaseInOut], animations: {
                self.draggableViewHeightContraint.constant = viewHeight
                
            } , completion: nil)
        }
    }
    
}

// MARK: - UI Table View Data Source

extension DetailController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return buildings.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "buildingCell") as! BuildingTableViewCell
        cell.configure(buildings[indexPath.row], isLastItem: (indexPath.row == buildings.count - 1))
        
        return cell
    }
    
}

// MARK: - UI Table View Delegate

extension DetailController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let b = buildings[indexPath.row]
        showMapsFor(building: b)
    }
    
    func showMapsFor(building: Building) {

        let regionDistance: CLLocationDistance = 10000
        let coordinates = CLLocationCoordinate2D(latitude: building.latitude, longitude: building.longitude)
        let regionSpan = MKCoordinateRegion(center: coordinates, latitudinalMeters: regionDistance, longitudinalMeters: regionDistance)
        
        let options = [
            MKLaunchOptionsMapCenterKey: NSValue(mkCoordinate: regionSpan.center),
            MKLaunchOptionsMapSpanKey: NSValue(mkCoordinateSpan: regionSpan.span)
        ]
        
        let placemark = MKPlacemark(coordinate: coordinates, addressDictionary: nil)
        let mapItem = MKMapItem(placemark: placemark)
        
        mapItem.name = building.name
        mapItem.openInMaps(launchOptions: options)

    }
    
}
