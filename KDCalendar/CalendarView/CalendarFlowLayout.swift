import UIKit

open class CalendarFlowLayout: UICollectionViewFlowLayout {
    
    
    override open func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        
        return super.layoutAttributesForElements(in: rect)?.map { attrs in
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes
            self.applyLayoutAttributes(attrscp)
            return attrscp
        }
    }
    
    override open func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        
        if let attrs = super.layoutAttributesForItem(at: indexPath) {
            let attrscp = attrs.copy() as! UICollectionViewLayoutAttributes
            self.applyLayoutAttributes(attrscp)
            return attrscp
        }
        return nil
    }
    
    func applyLayoutAttributes(_ attributes : UICollectionViewLayoutAttributes) {
        guard attributes.representedElementKind == nil else { return }
        
        guard let collectionView = self.collectionView else { return }
        
        var xCellOffset = CGFloat(attributes.indexPath.item % 7) * self.itemSize.width
        var yCellOffset = CGFloat(attributes.indexPath.item / 7) * self.itemSize.height
        
        let offset = CGFloat(attributes.indexPath.section)
        
        switch self.scrollDirection {
        case .horizontal:   xCellOffset += offset * collectionView.frame.size.width
        case .vertical:     yCellOffset += offset * collectionView.frame.size.height
        @unknown default:
            fatalError()
        }
        
        // set frame
        attributes.frame = CGRect(
            x: xCellOffset,
            y: yCellOffset,
            width: self.itemSize.width,
            height: self.itemSize.height
        )
    }
}
