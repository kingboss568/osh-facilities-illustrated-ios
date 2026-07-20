//
//  IsoHouseView.swift
//  山形屋（Pitched House）等角投影插畫 — 來自 02-house.html SVG
//  作為品牌主視覺，用於 Onboarding、Paywall 等 hero 區。
//

import SwiftUI

/// 等角投影山形屋。SVG 原 viewBox 200×180。
struct IsoHouseView: View {
    var size: CGFloat = 200

    var body: some View {
        Canvas { context, _ in
            let scale = size / 200
            let lineWidth: CGFloat = max(1, 2.4 * scale)

            func pt(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
                CGPoint(x: x * scale, y: y * scale)
            }
            func poly(_ coords: [CGFloat], fill: Color) {
                var path = Path()
                for i in stride(from: 0, to: coords.count, by: 2) {
                    let p = pt(coords[i], coords[i+1])
                    if i == 0 { path.move(to: p) } else { path.addLine(to: p) }
                }
                path.closeSubpath()
                context.fill(path, with: .color(fill))
                context.stroke(path, with: .color(Color(red: 0.227, green: 0.184, blue: 0.122)),
                               style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
            }

            // 地基
            poly([20,140, 100,180, 180,140, 100,100], fill: Color(red:0.804,green:0.722,blue:0.541))
            poly([20,140, 100,180, 100,160, 20,120],  fill: Color(red:0.627,green:0.522,blue:0.314))
            poly([100,180, 180,140, 180,120, 100,160],fill: Color(red:0.541,green:0.435,blue:0.227))

            // 房屋 cube
            poly([55,138, 100,160, 100,108, 55,86],   fill: Color(red:0.980,green:0.980,blue:0.965))
            poly([100,160, 145,138, 145,86, 100,108], fill: Color(red:0.914,green:0.890,blue:0.831))
            poly([55,86, 100,108, 145,86, 100,64],    fill: Color(red:0.804,green:0.722,blue:0.541))

            // 雙斜屋頂
            poly([55,86, 100,64, 100,40, 55,62],      fill: Color(red:0.627,green:0.522,blue:0.314))
            poly([100,64, 145,86, 145,62, 100,40],    fill: Color(red:0.541,green:0.435,blue:0.227))
            poly([55,62, 100,40, 145,62, 100,84],     fill: Color(red:0.227,green:0.184,blue:0.122))

            // 煙囪
            poly([118,72, 128,76, 128,55, 118,51],    fill: Color(red:0.627,green:0.522,blue:0.314))
            poly([128,76, 138,72, 138,51, 128,55],    fill: Color(red:0.541,green:0.435,blue:0.227))
            poly([118,51, 128,55, 138,51, 128,47],    fill: Color(red:0.227,green:0.184,blue:0.122))

            // 窗（左）
            poly([68,124, 86,133, 86,114, 68,105],    fill: Color(red:0.659,green:0.769,blue:0.847))
            // 門（右面）
            poly([115,151, 130,143, 130,124, 115,131],fill: Color(red:0.227,green:0.184,blue:0.122))
            // 窗（右）
            poly([135,142, 145,137, 145,123, 135,128],fill: Color(red:0.659,green:0.769,blue:0.847))

            // 門把
            let knob = pt(118, 138)
            let r = 1.8 * scale
            let knobRect = CGRect(x: knob.x - r, y: knob.y - r, width: r*2, height: r*2)
            context.fill(Path(ellipseIn: knobRect), with: .color(Color(red:0.941,green:0.776,blue:0.455)))
        }
        .frame(width: size, height: size * 0.9)
    }
}

#Preview {
    IsoHouseView(size: 300)
        .background(Color(red: 0.957, green: 0.918, blue: 0.831))
}
