//
//  ViewController.swift
//  Chart
//
//  Created by Konrad on 28.08.2018.
//  Copyright © 2018 Konrad. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(red: Int, green: Int, blue: Int) {
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(hex: Int) {
        self.init(red: (hex >> 16) & 0xff, green: (hex >> 8) & 0xff, blue: hex & 0xff)
    }
}

class ViewController: UIViewController {
    typealias Bar = ChartBarView.Bar
    typealias BarPart = ChartBarView.BarPart
    
    fileprivate lazy var chartView: ChartBarView = {
        let view = ChartBarView(frame: UIScreen.main.bounds)
        view.axisYWidth = 60
        view.axisXHeight = 40
        view.axisYLinesHidden = false
        view.axisXLinesHidden = false
        return view
    }()
    fileprivate lazy var refreshButton: UIButton = {
        let button = UIButton()
        button.contentEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8)
        button.setTitle("Refresh", for: .normal)
        button.setTitleColor(UIColor.black, for: .normal)
        button.backgroundColor = UIColor.white
        button.layer.cornerRadius = 4
        button.addTarget(
            self,
            action: #selector(refresh),
            for: .touchUpInside)
        button.sizeToFit()
        return button
    }()
    
   fileprivate let colors: [UIColor] = [
        UIColor(hex: 0x81D0A0),
        UIColor(hex: 0xB1CEEA),
        UIColor(hex: 0xFBE341),
        UIColor(hex: 0x33786C),
        UIColor(hex: 0x74A2D2),
        UIColor(hex: 0x55BF80)
    ]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // insert chart
        self.view.addSubview(self.chartView)
        self.view.addSubview(self.refreshButton)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // load chart data
        self.loadChartData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        self.chartView.frame = CGRect(
            x: 0,
            y: 40,
            width: self.view.bounds.width,
            height: self.view.bounds.height - 64)
        self.chartView.invalidateLayout(animated: true)
        self.refreshButton.frame.origin = CGPoint(
            x: self.view.bounds.width - self.refreshButton.bounds.size.width - 20,
            y: 20)
    }
    
    @objc func refresh() {
        self.loadChartData()
    }
    
    fileprivate func rand(from: Int, to: Int) -> Int {
        return Int(arc4random_uniform(UInt32(to - from + 1))) + from
    }
    
    // load chart data
    fileprivate func loadChartData() {
        var bars: [Bar] = []
        for i in 1 ... self.rand(from: 1, to: 4) {
            var data: [BarPart] = []
            for j in 0 ..< self.rand(from: 2, to: self.colors.count) {
                let item: BarPart = BarPart(
                    value: Double(self.rand(from: 100, to: 1000)),
                    color: self.colors[Int(j)],
                    title: "Item \(j + 1)")
                data.append(item)
            }
            let bar: Bar = Bar(title: "Data \(i)",
                parts: data)
            bars.append(bar)
        }
        
        self.chartView.setBars(bars: bars, animated: true)
    }
}
