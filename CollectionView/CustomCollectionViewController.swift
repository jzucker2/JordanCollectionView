//
//  CustomCollectionViewController.swift
//  CollectionView
//
//  Created by Jordan Zucker on 10/11/16.
//  Copyright © 2016 Jordan Zucker. All rights reserved.
//

import UIKit
import CoreData
import JSQDataSourcesKit

typealias ItemCellFactory = ViewFactory<Item, Cell>
typealias ItemSupplementaryViewFactory = ViewFactory<Item, SupplementaryCell>

struct ComposedCollectionSupplementaryViewFactory: ReusableViewFactoryProtocol {
    
    let leftViewFactory: ItemSupplementaryViewFactory
    let rightViewFactory: ItemSupplementaryViewFactory
    
    init(leftViewFactory: ItemSupplementaryViewFactory,
                rightViewFactory: ItemSupplementaryViewFactory) {
        self.leftViewFactory = leftViewFactory
        self.rightViewFactory = rightViewFactory
    }
    
    func reuseIdentiferFor(item: Item?, type: ReusableViewType, indexPath: IndexPath) -> String {
        return SupplementaryCell.reuseIdentifier()
    }
    
    public func configure(view: SupplementaryCell,
                          item: Item?,
                          type: ReusableViewType,
                          parentView: UICollectionView,
                          indexPath: IndexPath) -> SupplementaryCell {
        switch type {
        case .supplementaryView(kind: "Left"):
            return leftViewFactory.configure(view: view, item: item as Item!, type: type, parentView: parentView, indexPath: indexPath)
        case .supplementaryView(kind: "Right"):
            return rightViewFactory.configure(view: view, item: item as Item!, type: type, parentView: parentView, indexPath: indexPath)
        default:
            fatalError("attempt to dequeue supplementary view with unknown kind: \(type)")
        }
    }
}

extension UIApplication {
    var persistentContainer: NSPersistentContainer {
        guard let appDelegate = delegate as? AppDelegate else {
            fatalError()
        }
        return appDelegate.persistentContainer
    }
    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
}

class CustomLayout: UICollectionViewLayout {
    
    struct LayoutInfo {
        var items: [IndexPath: UICollectionViewLayoutAttributes]?
        var leftSupplementaryViews: [IndexPath: UICollectionViewLayoutAttributes]?
        var rightSupplementaryViews: [IndexPath: UICollectionViewLayoutAttributes]?
        
        mutating func clear() {
            items?.removeAll()
            leftSupplementaryViews?.removeAll()
            rightSupplementaryViews?.removeAll()
        }
    }
    
    var layoutInfo = LayoutInfo()
    
    var contentSize: CGSize = .zero
    //var layoutInfo: [String: [IndexPath: UICollectionViewLayoutAttributes]]
    
    required override init() {
        super.init()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func invalidateLayout() {
        super.invalidateLayout()
        layoutInfo.clear()
    }
    
    override func prepare() {
        super.prepare()
        /*
        collectionView.flatMap { (<#Wrapped#>) -> U? in
            <#code#>
        }
        guard let fetchedObjects = collectionView. else {
            contentSize = .zero
            return
        }
 */
        var totalNumberOfObjects = 0
        guard let sections = collectionView?.numberOfSections else {
            contentSize = .zero
            layoutInfo.clear()
            return
        }
        for section in 0..<sections {
            totalNumberOfObjects += (collectionView?.numberOfItems(inSection: section) ?? 0)
        }
        
        if totalNumberOfObjects == 0 {
            contentSize = .zero
            layoutInfo.clear()
            return
        }
        
        let bounds = UIScreen.main.bounds
        
        var preparedContentSize = CGSize(width: bounds.width, height: bounds.height)
        
        let adjustedHeight = CGFloat(integerLiteral: totalNumberOfObjects) * Cell.debugHeight
        
        preparedContentSize.height = adjustedHeight
        
        contentSize = preparedContentSize
        
        var allAttributes = [IndexPath: UICollectionViewLayoutAttributes]()
        
        let supplementaryIndexPath = IndexPath(item: 0, section: 0)
        
        let supplementaryWidth = contentSize.width/2
        let supplementaryHeight = CGFloat(integerLiteral: 200)
        
        let leftAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "Left", with: supplementaryIndexPath)
        let rightAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: "Right", with: supplementaryIndexPath)
        
        leftAttributes.frame = CGRect(x: 0.0, y: 0.0, width: supplementaryWidth, height: supplementaryHeight)
        rightAttributes.frame = CGRect(x: supplementaryWidth, y: 0.0, width: supplementaryWidth, height: supplementaryHeight)
        
        layoutInfo.rightSupplementaryViews = [supplementaryIndexPath: rightAttributes]
        layoutInfo.leftSupplementaryViews = [supplementaryIndexPath: leftAttributes]
        for section in 0..<sections {
            guard let existingCollectionView = collectionView else {
                fatalError()
            }
            for item in 0..<existingCollectionView.numberOfItems(inSection: section) {
                let itemIndexPath = IndexPath(item: item, section: section)
                let attributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
                let y = CGFloat(integerLiteral: itemIndexPath.item) * Cell.debugHeight + supplementaryHeight
                attributes.frame = CGRect(x: 0.0, y: y, width: contentSize.width, height: Cell.debugHeight)
                
                attributes.zIndex = item
                allAttributes[itemIndexPath] = attributes
            }
        }
        /*
        for (index, item) in fetchedObjects.enumerated() {
            let itemIndexPath = fetchedResultsController.indexPath(forObject: item)!
            let attributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
            let y = CGFloat(integerLiteral: itemIndexPath.item) * Cell.debugHeight + supplementaryHeight
            attributes.frame = CGRect(x: 0.0, y: y, width: contentSize.width, height: Cell.debugHeight)
            
            attributes.zIndex = index
            allAttributes[itemIndexPath] = attributes
        }
 */
        
        layoutInfo.items = allAttributes
        
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        /*
        let superAttributes = super.layoutAttributesForElements(in: rect)
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else {
            return nil
        }
        
        var allAttributes = [UICollectionViewLayoutAttributes]()
        for (index, item) in fetchedObjects.enumerated() {
            let itemIndexPath = fetchedResultsController.indexPath(forObject: item)!
            let attributes = UICollectionViewLayoutAttributes(forCellWith: itemIndexPath)
            let y = CGFloat(integerLiteral: itemIndexPath.item) * Cell.debugHeight
            attributes.frame = CGRect(x: 0.0, y: y, width: contentSize.width, height: Cell.debugHeight)
            
            attributes.zIndex = index
            allAttributes.append(attributes)
        }
        
        print("\(#function) superAttributes: \(superAttributes) allAttributes: \(allAttributes) in rect: \(rect)")
        return allAttributes
 */
        /*
        NSMutableArray *myAttributes [NSMutableArray arrayWithCapacity:self.layoutInformation.count];
        for(NSString *key in self.layoutInformation){
            NSDictionary *attributesDict = [self.layoutInformation objectForKey:key];
            for(NSIndexPath *key in attributesDict){
                UICollectionViewLayoutAttributes *attributes =
                    [attributesDict objectForKey:key];
                if(CGRectIntersectsRect(rect, attributes.frame)){
                    [attributes addObject:attributes];
                }
            }
        }
        return myAttributes;
 */
        var returningAttributes = [UICollectionViewLayoutAttributes]()
        
        func appendIntersectingAttributes(comparing attributes: [IndexPath: UICollectionViewLayoutAttributes]?) {
            guard let actualAttributes = attributes else {
                return
            }
            for (_, itemAttributes) in actualAttributes {
                if itemAttributes.frame.intersects(rect) {
                    returningAttributes.append(itemAttributes)
                }
            }
        }
        
        appendIntersectingAttributes(comparing: layoutInfo.items)
        appendIntersectingAttributes(comparing: layoutInfo.rightSupplementaryViews)
        appendIntersectingAttributes(comparing: layoutInfo.leftSupplementaryViews)
        
        
        
        /*
        guard let currentItems = layoutInfo.items else {
            return nil
        }
        for (_, itemAttributes) in currentItems {
            if itemAttributes.frame.intersects(rect) {
                returningAttributes.append(itemAttributes)
            }
        }
        
        guard let leftViews = layoutInfo.leftSupplementaryViews else {
            return returningAttributes
        }
        
        for
        
        guard let rightViews = layoutInfo.rightSupplementaryViews else {
            return returningAttributes
        }
 */
        
        return returningAttributes
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.layoutAttributesForItem(at: indexPath)
        print("\(#function) attributes: \(attributes) with indexPath: \(indexPath)")
        //return attributes
        //return self.layoutInfo[@"MyCellKind"][indexPath];
        //return layoutInfo[Cell.reuseIdentifier()]?[indexPath]
        return layoutInfo.items?[indexPath]
    }
    
    override func layoutAttributesForSupplementaryView(ofKind elementKind: String, at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        //let attributes = super.layoutAttributesForSupplementaryView(ofKind: elementKind, at: indexPath)
        //print("\(#function) attributes: \(attributes) with kind: \(elementKind) at indexPath: \(indexPath)")
        //return attributes
        switch elementKind {
        case "Left":
            return layoutInfo.leftSupplementaryViews?[indexPath]
        case "Right":
            return layoutInfo.rightSupplementaryViews?[indexPath]
        default:
            fatalError("Can't handle kind: \(elementKind)")
        }
    }
    
    override func prepare(forCollectionViewUpdates updateItems: [UICollectionViewUpdateItem]) {
        super.prepare(forCollectionViewUpdates: updateItems)
        print("################### \(#function)")
    }
    
    override func finalizeCollectionViewUpdates() {
        super.finalizeCollectionViewUpdates()
        print("\(#function)")
    }
    
    override var collectionViewContentSize: CGSize {
        print("\(#function) size: \(contentSize)")
        return contentSize
    }
    
    /*
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        print(#function)
        return true
    }
 */
    
    // MARK: - NSFetchedResultsControllerDelegate
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
    }
}

class CustomCollectionViewController: UIViewController, UICollectionViewDelegate {
    
    class UpdateOperation: Operation {
        
    }
    
    private lazy var operationQueue: OperationQueue = {
        let queue = OperationQueue()
        queue.name = "FetchedResultsQueue"
        queue.qualityOfService = .userInitiated
        queue.maxConcurrentOperationCount = 3
        return queue
    }()
    
    //typealias ItemCellFactory = ViewFactory<Item, Cell>
    //typealias ItemSupplementaryViewFactory = ViewFactory<Item, SupplementaryCell>
    var dataSourceProvider: DataSourceProvider<FetchedResultsController<Item>, ItemCellFactory, ComposedCollectionSupplementaryViewFactory>!
    
    var delegateProvider: FetchedResultsDelegateProvider<ItemCellFactory>!
    
    
    var blockOperations: [BlockOperation]?
    var collectionView: UICollectionView!
    var fetchedResultsController: FetchedResultsController<Item>!
    
    /*
    lazy var fetchedResultsController: NSFetchedResultsController<Item> = {
        let allResultsFetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Item.creationDate), ascending: false)
        allResultsFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        let creatingFetchedResultsController = NSFetchedResultsController(fetchRequest: allResultsFetchRequest, managedObjectContext: UIApplication.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        //creatingFetchedResultsController.delegate = self
        return creatingFetchedResultsController
    }()
 */
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        fatalError()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    deinit {
        operationQueue.cancelAllOperations()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let frame = self.view.frame
        let layout = CustomLayout()
        self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        
        let cellFactory = ViewFactory(reuseIdentifier: Cell.reuseIdentifier()) { (cell, model: Item?, type, collectionView, indexPath) -> Cell in
            guard let updatedText = model?.title else {
                return cell
            }
            cell.update(text: updatedText)
            return cell
        }
        
        let leftViewFactory = ViewFactory(reuseIdentifier: SupplementaryCell.reuseIdentifier(), type: .supplementaryView(kind: "Left")) { (view, model: Item?, kind, collectionView, indexPath) -> SupplementaryCell in
            view.update(text: "Left")
            return view
        }
        
        let rightViewFactory = ViewFactory(reuseIdentifier: SupplementaryCell.reuseIdentifier(), type: .supplementaryView(kind: "Right")) { (view, model: Item?, kind, collectionView, indexPath) -> SupplementaryCell in
            view.update(text: "Right")
            return view
        }
        
        let composedViewFactory = ComposedCollectionSupplementaryViewFactory(leftViewFactory: leftViewFactory, rightViewFactory: rightViewFactory)
        
        
        print(rightViewFactory.reuseIdentifier)
        
        /*
         typealias ThingCellFactory = ViewFactory<Thing, CollectionViewCell>
         typealias ThingSupplementaryViewFactory = ComposedCollectionSupplementaryViewFactory<Thing>
         var dataSourceProvider: DataSourceProvider<FetchedResultsController<Thing>, ThingCellFactory, ThingSupplementaryViewFactory>!
         
         var delegateProvider: FetchedResultsDelegateProvider<ThingCellFactory>!
         */
        
        delegateProvider = FetchedResultsDelegateProvider(cellFactory: cellFactory, collectionView: collectionView)
        
        let allResultsFetchRequest: NSFetchRequest<Item> = Item.fetchRequest()
        let creationDateSortDescriptor = NSSortDescriptor(key: #keyPath(Item.creationDate), ascending: false)
        allResultsFetchRequest.sortDescriptors = [creationDateSortDescriptor]
        fetchedResultsController = FetchedResultsController<Item>(fetchRequest: allResultsFetchRequest, managedObjectContext: UIApplication.shared.viewContext, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.delegate = delegateProvider.collectionDelegate
        
        dataSourceProvider = DataSourceProvider(dataSource: fetchedResultsController, cellFactory: cellFactory, supplementaryFactory: composedViewFactory)
        
        
        //self.collectionView = UICollectionView(frame: frame, collectionViewLayout: layout)
        //collectionView.dataSource = self
        //collectionView.delegate = self
        
        collectionView.backgroundColor = UIColor.cyan
        collectionView.register(Cell.self, forCellWithReuseIdentifier: Cell.reuseIdentifier())
        //collectionView.register(HeaderCell.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: HeaderCell.reuseIdentifier())
        collectionView.register(SupplementaryCell.self, forSupplementaryViewOfKind: "Right", withReuseIdentifier: SupplementaryCell.reuseIdentifier())
        collectionView.register(SupplementaryCell.self, forSupplementaryViewOfKind: "Left", withReuseIdentifier: SupplementaryCell.reuseIdentifier())
        collectionView.dataSource = dataSourceProvider.collectionViewDataSource
        collectionView.delegate = self
        view.addSubview(collectionView)
        
        //collectionView.dataSource = dataSourceProvider.colle
        
        //collectionView.reloadData()
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError(error.localizedDescription)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
