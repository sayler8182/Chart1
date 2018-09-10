//
//  ChartBar.swift
//  Chart
//
//  Created by Konrad on 28.08.2018.
//  Copyright © 2018 Konrad. All rights reserved.
//

import Foundation
import UIKit

public extension ChartBarView {
    public class Bar {
        public var title: String
        public var parts: [BarPart]
        
        public init(title: String, part: BarPart) {
            self.title = title
            self.parts = [part]
        }
        
        public init(title: String, parts: [BarPart]) {
            self.title = title
            self.parts = parts
        }
    }
    
    public class BarPart {
        public var value: Double
        public var color: UIColor
        public var title: String
        
        public init(value: Double?, color: UIColor, title: String) {
            self.value = value ?? 0
            self.color = color
            self.title = title
        }
    }
    
    public struct LegendItem {
        public var color: UIColor
        public var title: String
    }
}

public class ChartBarView: UIView {
    fileprivate lazy var axisYView: UIView      = self.makeAxisYView()
    fileprivate lazy var axisXView: UIView      = self.makeAxisXView()
    fileprivate lazy var contentView: UIView    = self.makeContentView()
    fileprivate lazy var legendView: UIView     = self.makeLegendView()
    
    fileprivate var legendItemHeight: CGFloat   = 24
    fileprivate var legendHeight: CGFloat       = 0
    public var axisYWidth: CGFloat              = 80
    public var axisXHeight: CGFloat             = 40
    public var axisYLinesHidden: Bool           = false
    public var axisXLinesHidden: Bool           = false
    
    fileprivate var legendItems: [LegendItem]   = []
    fileprivate var bars: [Bar]                 = []
    
    fileprivate var axisYLabels: [UILabel]      = []
    fileprivate var axisYLines: [UIView]        = []
    fileprivate var axisXLabels: [UILabel]      = []
    fileprivate var axisXLines: [UIView]        = []
    fileprivate var contentViews: [UIView]      = []
    fileprivate var legendViews: [UIView]       = []
    
    public var numberFormatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 0
        return formatter
    }()
    
    public override func awakeFromNib() {
        super.awakeFromNib()
        
        // invalidate layout
        self.invalidateLayout(animated: false)
    }
    
    public func setBars(bars: [Bar], animated: Bool) {
        self.bars = bars
        self.reloadData(animated: animated)
    }
    
    // reload data
    public func reloadData(animated: Bool) {
        self.reloadContent()
        self.reloadLegend()
        self.reloadAxisY()
        self.reloadAxisX()
        self.invalidateLayout(animated: animated)
    }
    
    // invalidate layout
    public func invalidateLayout(animated: Bool) {
        self.invalidateContent(animated: animated)
        self.invalidateLegend(animated: animated)
        self.invalidateAxisY(animated: animated)
        self.invalidateAxisX(animated: animated)
    }
    
    // bars max value
    fileprivate func barsMaxValue(bars: [Bar]) -> Int? {
        var values: [Double] = []
        for bar in bars {
            let value: Double = bar.parts
                .map { $0.value }
                .reduce(0, +)
            values.append(value)
        }
        
        guard let valueDouble: Double = values.max() else { return nil }
        return Int(ceil(valueDouble))
    }
}

// MARK: - Axis Y and X
extension ChartBarView {
    
    // make axis label
    fileprivate func makeAxixLabel(frame: CGRect) -> UILabel {
        let label: UILabel = UILabel(frame: frame)
        label.font = UIFont.systemFont(ofSize: 14)
        label.minimumScaleFactor = 0.7
        return label
    }
}

// MARK: - Axis Y
extension ChartBarView {
    
    // make axis y
    fileprivate func makeAxisYView() -> UIView {
        let view: UIView = UIView()
        self.addSubview(view)
        return view
    }
    
    // reload axis y
    fileprivate func reloadAxisY() {
        
        // invalidate layout
        self.invalidateLayout(animated: false)
    }
    
    // axis y max value
    fileprivate func axisYMaxValue(barsMaxValue: Int) -> Int {
        guard barsMaxValue != 0 else { return 10 }
        let steps: [Int] = [1, 2, 5]
        var scale: Int = 1
        for _ in 1 ... 6 {
            for step in steps {
                let rounding: Int = step * scale
                let value: Int = rounding * 10
                if barsMaxValue < value {
                    let barsMaxValueDouble: Double = Double(barsMaxValue)
                    let roundingDouble: Double = Double(rounding)
                    let valueDouble: Double = ceil(barsMaxValueDouble / roundingDouble) * roundingDouble
                    return Int(ceil(valueDouble))
                }
            }
            
            scale *= 10
        }
        
        return barsMaxValue
    }
    
    // axis y steps
    fileprivate func axisYStepsCount(maxValue: Int) -> Int {
        let steps: [Int] = [Int](2...10)
        for step in steps.reversed() {
            if maxValue % step == 0 {
                return step
            }
        }
        return 10
    }
    
    // invalidate axis y
    fileprivate func invalidateAxisY(animated: Bool) {
        let axisYViewFrame: CGRect = CGRect(
            x: 0,
            y: 0,
            width: self.axisYWidth,
            height: self.bounds.height - self.legendHeight - self.axisXHeight)
        self.axisYView.frame = axisYViewFrame
        
        // generate axis y
        self.axisYView.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.axisYLabels.removeAll()
        self.axisYLines.removeAll()
        
        guard let barsMaxValue: Int = self.barsMaxValue(bars: self.bars) else { return }
        let maxValue: Int = self.axisYMaxValue(barsMaxValue: barsMaxValue)
        let stepsCount: Int = self.axisYStepsCount(maxValue: maxValue)
        guard stepsCount > 0 else { return }
        let itemHeight: CGFloat = axisYViewFrame.height / CGFloat(stepsCount)
        let stepValue: Int = maxValue / stepsCount
        let startY: CGFloat = axisYViewFrame.height
        for i in 0 ... stepsCount {
            let row: CGFloat = CGFloat(i)
            let labelValue: Int = i * stepValue
            
            // label
            let label: UILabel = self.makeAxixLabel(frame: CGRect(
                x: 0,
                y: startY - (itemHeight / 2) - (row * itemHeight),
                width: self.axisYWidth,
                height: itemHeight))
            label.textAlignment = NSTextAlignment.right
            label.text = self.numberFormatter.string(from: labelValue as NSNumber)
            
            // line
            let line: UIView = UIView(frame: CGRect(
                x: self.axisYWidth + 20,
                y: startY - (row * itemHeight),
                width: self.bounds.width - self.axisYWidth - 40,
                height: 1))
            line.backgroundColor = UIColor.groupTableViewBackground
            
            // save reference
            self.axisYLabels.append(label)
            self.axisYView.addSubview(label)
            
            if !self.axisYLinesHidden {
                self.axisYLines.append(line)
                self.axisYView.addSubview(line)
            }
        }
    }
}

// MARK: - Axis X
extension ChartBarView {
    
    // make axis x
    fileprivate func makeAxisXView() -> UIView {
        let view: UIView = UIView( )
        self.addSubview(view)
        return view
    }
    
    // realod axis x
    fileprivate func reloadAxisX() {
        
        // invalidate layout
        self.invalidateLayout(animated: false)
    }
    
    // invalidate axis x
    fileprivate func invalidateAxisX(animated: Bool) {
        let axisXViewFrame: CGRect = CGRect(
            x: self.axisYWidth,
            y: self.bounds.height - self.legendHeight - self.axisXHeight,
            width: self.bounds.width - self.axisYWidth,
            height: self.axisXHeight)
        self.axisXView.frame = axisXViewFrame
        
        // generate axis x
        self.axisXView.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.axisXLabels.removeAll()
        
        let stepsCount: Int = self.bars.count
        guard stepsCount > 0 else { return }
        let itemHeight: CGFloat = axisXViewFrame.height
        let itemWidth: CGFloat = axisXViewFrame.width / CGFloat(stepsCount)
        for (i, bar) in self.bars.enumerated() {
            let column: CGFloat = CGFloat(i)
            
            // label
            let label: UILabel = self.makeAxixLabel(frame: CGRect(
                x: column * itemWidth,
                y: 0,
                width: itemWidth,
                height: itemHeight))
            label.textAlignment = NSTextAlignment.center
            label.text = bar.title
            
            // line
            let line: UIView = UIView(frame: CGRect(
                x: column * itemWidth + (itemWidth / 2),
                y: -self.contentView.frame.height,
                width: 1,
                height: self.contentView.frame.height))
            line.backgroundColor = UIColor.groupTableViewBackground
            
            // save reference
            self.axisXView.addSubview(label)
            self.axisXLabels.append(label)
            
            if !self.axisXLinesHidden {
                self.axisXLines.append(line)
                self.axisXView.addSubview(line)
            }
        }
    }
}

// MARK: - Content
extension ChartBarView {
    
    // make content
    fileprivate func makeContentView() -> UIView {
        let view: UIView = UIView( )
        self.addSubview(view)
        return view
    }
    
    // realod content
    fileprivate func reloadContent() {
        
        // invalidate layout
        self.invalidateLayout(animated: false)
    }
    
    // content bar part height
    fileprivate func contentBarPartHeight(part: BarPart, maxValue: Int, maxHeight: CGFloat) -> CGFloat {
        let value: Double = part.value
        let maxValue: Double = Double(maxValue)
        let ratio: Double = value / maxValue
        let height: Double = ratio * Double(maxHeight)
        return CGFloat(height)
    }
    
    // invalidate content
    fileprivate func invalidateContent(animated: Bool) {
        let contentViewFrame: CGRect = CGRect(
            x: self.axisYWidth,
            y: 0,
            width: self.bounds.width - self.axisYWidth,
            height: self.bounds.height - self.legendHeight - self.axisXHeight)
        self.contentView.frame = contentViewFrame
        
        // generate content
        self.contentView.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.contentViews.removeAll()
        
        guard let barsMaxValue: Int = self.barsMaxValue(bars: self.bars) else { return }
        let maxValue: Int = self.axisYMaxValue(barsMaxValue: barsMaxValue)
        let stepsCount: Int = self.bars.count
        guard stepsCount > 0 else { return }
        let maxHeight: CGFloat = contentViewFrame.height
        let itemWidth: CGFloat = contentViewFrame.width / CGFloat(stepsCount)
        for (i, bar) in self.bars.enumerated() {
            let column: CGFloat = CGFloat(i)
            let barItemX: CGFloat = column * itemWidth + (itemWidth / 4)
            let barItemY: CGFloat = maxHeight
            var barItemsHeight: CGFloat = 0
            
            for (_, part) in bar.parts.enumerated() {
                let barItemHeight: CGFloat = self.contentBarPartHeight(
                    part: part,
                    maxValue: maxValue,
                    maxHeight: maxHeight)
                barItemsHeight += barItemHeight
                
                // view
                let view: UIView = UIView(frame: CGRect(
                    x: barItemX,
                    y: barItemY - barItemsHeight,
                    width: itemWidth / 2,
                    height: barItemsHeight))
                view.backgroundColor = part.color
                
                self.contentViews.append(view)
                self.contentView.insertSubview(view, at: 0)
                self.contentView.superview?.bringSubview(toFront: self.contentView)
            }
        }
        
        // animate content
        if animated == true {
            self.animateContent()
        }
    }
    
    // animate content
    fileprivate func animateContent() {
        let views: [UIView] = self.contentView.subviews
        let frames: [CGRect] = views.map { $0.frame }
        let startY: CGFloat = self.contentView.frame.height
        
        // set start positions
        for view in views {
            view.frame.origin.y = startY
            view.frame.size.height = 0
        }
        
        // animate positions
        UIView.animate(
            withDuration: 1,
            animations: {
                for (i, view) in views.enumerated() {
                    let frame: CGRect = frames[i]
                    view.frame.origin.y = frame.origin.y
                    view.frame.size.height = frame.size.height
                }
        })
        
    }
}

// MARK: - Legend
extension ChartBarView {
    
    // make legend
    fileprivate func makeLegendView() -> UIView {
        let view: UIView = UIView()
        self.addSubview(view)
        return view
    }
    
    // reload legend
    fileprivate func reloadLegend() {
        let parts: [BarPart] = self.bars
            .flatMap { $0.parts }
        var items: [LegendItem] = []
        for part in parts {
            if !items.contains(where: { $0.title == part.title }) {
                items.append(LegendItem(color: part.color, title: part.title))
            }
        }
        
        let startY: CGFloat = 20
        let itemHeight: CGFloat = self.legendItemHeight
        self.legendHeight = startY + CGFloat((items.count - 1) / 3) * itemHeight + itemHeight
        self.legendItems = items
        
        // invalidate layout
        self.invalidateLayout(animated: false)
    }
    
    // invalidate legend
    fileprivate func invalidateLegend(animated: Bool) {
        let legendViewFrame: CGRect = CGRect(
            x: 40,
            y: self.bounds.height - self.legendHeight,
            width: self.bounds.width - 40,
            height: self.legendHeight)
        self.legendView.frame = legendViewFrame
        
        // generate legend
        self.legendView.subviews.forEach {
            $0.removeFromSuperview()
        }
        self.legendViews.removeAll()
        
        let items: [LegendItem] = self.legendItems
        let itemHeight: CGFloat = self.legendItemHeight
        let itemWidth: CGFloat = self.legendView.bounds.width / 3
        let startY: CGFloat = 20
        for (i, item) in items.enumerated() {
            let column: CGFloat = CGFloat(i % 3)
            let row: CGFloat = CGFloat(i / 3)
            
            // view
            let view: UIView = UIView(frame: CGRect(
                x: column * itemWidth,
                y: startY + row * itemHeight,
                width: itemWidth,
                height: itemHeight))
            
            // color
            let colorView: UIView = UIView(frame: CGRect(
                x: 4,
                y: 4,
                width: itemHeight - 8,
                height: itemHeight - 8))
            colorView.backgroundColor = item.color
            view.addSubview(colorView)
            
            // title
            let titleLabel: UILabel = UILabel(frame: CGRect(
                x: itemHeight + 4,
                y: 0,
                width: itemWidth - (itemHeight + 8),
                height: itemHeight))
            titleLabel.textColor = item.color
            titleLabel.font = UIFont.systemFont(ofSize: 14, weight: UIFont.Weight.bold)
            titleLabel.adjustsFontSizeToFitWidth = true
            titleLabel.minimumScaleFactor = 0.5
            titleLabel.numberOfLines = 2
            titleLabel.text = item.title
            view.addSubview(titleLabel)
            
            // save reference
            self.legendViews.append(view)
            self.legendView.addSubview(view)
        }
    }
}
