//
//  MacawChartView.swift
//  VPD
//
//  Created by Ikenna Udokporo on 24/01/2020.
//  Copyright © 2020 voguepay. All rights reserved.
//

import UIKit
import Macaw

struct swiftVideo {
    var showNumber = ""
    var veiwCount: Double?
    
}

class MacawChartView: MacawView {

    
    static let lastFiveShows = createDummyData()
    static let maxValue = 6000
    static let maxValueLineHeight = 180
    static let lineWidth: Double = 275
    
    static let dataDivisor = Double(maxValue/maxValueLineHeight)
    static let adjustedData: [Double] = lastFiveShows.map({ $0.veiwCount! / dataDivisor })
    static var animations: [Animation] = []
    
    required init?(coder aDecoder: NSCoder) {
        super.init(node: MacawChartView.createChart(), coder: aDecoder)
        backgroundColor = .clear
    }
    
    private static func createChart() -> Group {
        var items: [Node] =  addXaxisItem()
        items.append(createBars())
        
        return Group(contents: items, place: .identity)
    }

 
    private static func addYaxisItem() -> [Node] {
        
        let maxLines = 6
        let lineInterval = Int(maxValue/maxLines)
        let yAxisHeight: Double = 200
        let lineSpacing: Double = 30
        
        var newNode: [Node] = []
         
        for i in 1...maxLines {
            let y = yAxisHeight - (Double(i) * lineSpacing)
            
            let valueLine = Line(x1: -5, y1: y, x2: lineWidth, y2: y).stroke(fill: Color.white.with(a: 0.10))
            
            let valueText = Text(text: "\(i * lineInterval)", align: .max, baseline: .mid, place: .move(dx: -10, dy: y))
            
            valueText.fill = Color.white
            
            newNode.append(valueLine)
            newNode.append(valueText)
        }
        
        let yAxis = Line(x1:0, y1:0, x2: 0, y2: yAxisHeight).stroke(fill: Color.white.with(a: 0.25))
        
        newNode.append(yAxis)
        
        return  newNode
    }
    
    private static func addXaxisItem() -> [Node] {
        let chartBaseY = 200
        var newNode: [Node] = []
//        
//        for i in 1...adjustedData.count {
//            let x = (Double(i) * 50)
//            let valueText = Text(text: lastFiveShows, stroke: <#T##Stroke?#>, align: <#T##Align#>, baseline: <#T##Baseline#>, place: <#T##Transform#>)
//        }
        return []
    }
    
    private static func createBars() -> Group {
        return Group()
    }
    
    
    private static func createDummyData () -> [swiftVideo] {
        
        let one = swiftVideo(showNumber: "23", veiwCount: 2334)
        let two = swiftVideo(showNumber: "23", veiwCount: 2334)
        let three = swiftVideo(showNumber: "23", veiwCount: 2334)
        let four = swiftVideo(showNumber: "23", veiwCount: 2334)
        let five = swiftVideo(showNumber: "23", veiwCount: 2334)
        
        return [one, two, three, four, five]
    }

}
