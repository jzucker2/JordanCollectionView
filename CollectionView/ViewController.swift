//
//  ViewController.swift
//  CollectionView
//
//  Created by Jordan Zucker on 10/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

import UIKit

class CollectionViewLayout: UICollectionViewFlowLayout, UICollectionViewDelegateFlowLayout {
    
    
    
    override init() {
        super.init()
        scrollDirection = .vertical
        itemSize = Cell.debugSize
        estimatedItemSize = Cell.debugSize
        sectionInset = UIEdgeInsets(top: 20.0, left: 20.0, bottom: 20.0, right: 20.0)
        minimumLineSpacing = 30.0
        minimumInteritemSpacing = 30.0
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func prepare() {
        super.prepare()
    }
    func modifyLayout(with attributes: UICollectionViewLayoutAttributes, at indexPath: IndexPath) {
        attributes.center.y += 100.0
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let attributes = super.layoutAttributesForItem(at: indexPath) else {
            return nil
        }
        
        modifyLayout(with: attributes, at: indexPath)
        return attributes
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        print("^^^^^^^^^^^^^^^^ \(#function)")
        guard let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath) else {
            return nil
        }
        return attributes
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        guard let allAttributesInRect = super.layoutAttributesForElements(in: rect) else {
            print("`````````````` return nil")
            return nil
        }
        var finalAttributesInRect = allAttributesInRect
        for cellAttributes in allAttributesInRect {
            cellAttributes.center.y += 100
            finalAttributesInRect.append(cellAttributes)
        }
        return allAttributesInRect
    }
    
    override var collectionViewContentSize: CGSize {
        var size = super.collectionViewContentSize
        size.height += SupplementaryCell.debugSize.height
        return size
    }

}

class Cell: UICollectionViewCell {
    let label: UILabel
    
    override init(frame: CGRect) {
        self.label = UILabel(frame: .zero)
        super.init(frame: frame)
        contentView.addSubview(label)
        contentView.backgroundColor = UIColor.red
        let views = [
            "label": label
        ]
        label.translatesAutoresizingMaskIntoConstraints = false
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        contentView.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    static func reuseIdentifier() -> String {
        return "Cell"
    }
    
    func update(text: String) {
        label.text = text
        contentView.setNeedsLayout()
    }
    
    static var debugSize: CGSize {
        return CGSize(width: 100.0, height: 100.0)
    }
    
    static var debugHeight: CGFloat {
        return 40.0
    }
    
}

class SupplementaryCell: UICollectionReusableView {
    
    class func reuseIdentifier() -> String {
        return "Supplementary"
    }
    
    let label: UILabel
    
    override init(frame: CGRect) {
        self.label = UILabel(frame: .zero)
        super.init(frame: frame)
        self.addSubview(label)
        self.backgroundColor = UIColor.green
        label.textColor = UIColor.blue
        let views = [
            "label": label
        ]
        label.translatesAutoresizingMaskIntoConstraints = false
        let verticalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "V:|[label]|", options: [], metrics: nil, views: views)
        let horizontalConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|[label]|", options: [], metrics: nil, views: views)
        NSLayoutConstraint.activate(verticalConstraints)
        NSLayoutConstraint.activate(horizontalConstraints)
        self.setNeedsLayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func update(text: String) {
        label.text = text
        label.textAlignment = .center
        self.sizeToFit()
        self.setNeedsLayout()
    }
    
    static var debugSize: CGSize {
        return CGSize(width: 100.0, height: 100.0)
    }
}

class HeaderCell: SupplementaryCell {
    class override func reuseIdentifier() -> String {
        return "Header"
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.purple
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var dataSource: [Array<String>] = {
        let firstSection = ["Pub", "Nub"]
        let secondSection = ["Jordan", "Rocks"]
        return [firstSection, secondSection]
    }()
    
    //var dataSourceSection = ["Test", "This"]
    
    var collectionView: UICollectionView!
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let frame = self.view.frame
        let layout = CollectionViewLayout()
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        collectionView.dataSource = self
        collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.cyan
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier())
        collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderCell.reuseIdentifier())
        collectionView.register(SupplementaryCell.self, forSupplementaryViewOfKind: "Test", withReuseIdentifier: SupplementaryCell.reuseIdentifier())
        view.addSubview(collectionView)
        collectionView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return dataSource.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let dataSourceSection = dataSource[section]
        return dataSourceSection.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: Cell.reuseIdentifier(), for: indexPath) as? Cell else {
            fatalError()
        }
        let dataSection = dataSource[indexPath.section]
        let text = dataSection[indexPath.item]
        cell.update(text: text)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        print("!!!!!!!!!!!!!!!!!! \(#function) with kind: \(kind)")
        switch kind {
        case UICollectionElementKindSectionHeader:
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: HeaderCell.reuseIdentifier(), for: indexPath) as? HeaderCell else {
                fatalError()
            }
            view.update(text: "\(indexPath.section)")
            return view
        case "Test":
            guard let view = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: SupplementaryCell.reuseIdentifier(), for: indexPath) as? SupplementaryCell else {
                fatalError()
            }
            view.update(text: "Hobnob")
            return view
        default:
            fatalError()
        }
    }

    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("================== \(#function)")
        return HeaderCell.debugSize
    }

    /*
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        print("================== \(#function)")
        switch section {
        case 0:
            return CGSize(width: collectionView.frame.size.width, height: 300.0)
        default:
            return SupplementaryCell.debugSize
        }
    }
 */
}

