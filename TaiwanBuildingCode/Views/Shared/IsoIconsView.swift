//
//  IsoIconsView.swift
//  職業安全衛生設施規則全圖解
//
//  Centralized isometric SwiftUI Canvas icon library.
//  All icons are drawn from _bootstrap.html polygon data.
//  Usage: IsoIcon(.stairs, size: 110)
//

import SwiftUI

// MARK: - Icon kinds

enum IsoIconKind {
    // ─── 三大篇 bigcard（100×100 viewBox）
    case stairs        // 設計篇
    case column        // 構造篇
    case lightbulb     // 設備篇

    // ─── 章節列 small（40×40 viewBox）
    case boxBasic      // Ch01 用語定義
    case boxBand       // Ch02 一般設計通則
    case stairSmall    // Ch03 樓梯
    case flame         // 強調風險
    case parking       // Ch05 停車
    case wheelchair    // Ch06 無障礙
    case columnSmall   // Ch07 建築構造
    case gear          // Ch08 建築設備

    // ─── 常用卡（64×64 viewBox）
    case favDesign     // 設計階段必查
    case favFire       // 職安風險
    case favAccess     // 無障礙設施
    case favParking    // 停車空間
    case favVent       // 採光通風（窗戶）
    case favGreen      // 綠建築（葉子）
    case favStruct     // 構造安全
    case favEquip      // 設備系統（齒輪）

    // ─── 計算器（48×48 viewBox）
    case calcBox       // 容積率
    case calcWindow    // 建蔽率
    case calcSlab      // 樓地板面積
    case calcStairs    // 樓梯
    case calcParking   // 停車位
    case calcHeight    // 建築物高度
    case calcGround    // 法定空地

    // ─── Paywall feature list（28×28 viewBox）
    case featIllust    // 163張圖解
    case featText      // 全文條文
    case featStar      // 業界懶人包
    case featCalc      // 計算器
    case featPDF       // PDF匯出
    case featCloud     // iCloud同步
    case featNoAd      // 無廣告

    // ─── Paywall hero（140×140）
    case lockHero
}

// MARK: - Main view

struct IsoIcon: View {
    let kind: IsoIconKind
    var size: CGFloat = 48

    var body: some View {
        Canvas { ctx, canvasSize in
            let s = canvasSize.width
            switch kind {
            case .stairs:        drawStairs(ctx, s)
            case .column:        drawColumn(ctx, s)
            case .lightbulb:     drawLightbulb(ctx, s)
            case .boxBasic:      drawBoxBasic(ctx, s)
            case .boxBand:       drawBoxBand(ctx, s)
            case .stairSmall:    drawStairSmall(ctx, s)
            case .flame:         drawFlame(ctx, s)
            case .parking:       drawParking(ctx, s)
            case .wheelchair:    drawWheelchair(ctx, s)
            case .columnSmall:   drawColumnSmall(ctx, s)
            case .gear:          drawGear(ctx, s)
            case .favDesign:     drawFavDesign(ctx, s)
            case .favFire:       drawFavFire(ctx, s)
            case .favAccess:     drawFavAccess(ctx, s)
            case .favParking:    drawFavParking(ctx, s)
            case .favVent:       drawFavVent(ctx, s)
            case .favGreen:      drawFavGreen(ctx, s)
            case .favStruct:     drawFavStruct(ctx, s)
            case .favEquip:      drawFavEquip(ctx, s)
            case .calcBox:       drawCalcBox(ctx, s)
            case .calcWindow:    drawCalcWindow(ctx, s)
            case .calcSlab:      drawCalcSlab(ctx, s)
            case .calcStairs:    drawCalcStairs(ctx, s)
            case .calcParking:   drawCalcParking(ctx, s)
            case .calcHeight:    drawCalcHeight(ctx, s)
            case .calcGround:    drawCalcGround(ctx, s)
            case .featIllust:    drawFeatIllust(ctx, s)
            case .featText:      drawFeatText(ctx, s)
            case .featStar:      drawFeatStar(ctx, s)
            case .featCalc:      drawFeatCalc(ctx, s)
            case .featPDF:       drawFeatPDF(ctx, s)
            case .featCloud:     drawFeatCloud(ctx, s)
            case .featNoAd:      drawFeatNoAd(ctx, s)
            case .lockHero:      drawLockHero(ctx, s)
            }
        }
        .frame(width: size, height: size)
    }
}

// MARK: - Helpers

private let stroke = Color(red: 0.227, green: 0.184, blue: 0.122) // #3a2f1f
private let kraft2 = Color(red: 0.804, green: 0.722, blue: 0.541) // #cdb88a
private let tile2  = Color(red: 0.627, green: 0.522, blue: 0.314) // #a08550
private let deep   = Color(red: 0.541, green: 0.435, blue: 0.227) // #8a6f3a
private let paper  = Color(red: 0.918, green: 0.894, blue: 0.831) // #e9e3d4 kraft
private let skyC   = Color(red: 0.659, green: 0.769, blue: 0.847) // #a8c4d8
private let goldC  = Color(red: 0.941, green: 0.776, blue: 0.455) // #f0c674
private let rust   = Color(red: 0.776, green: 0.435, blue: 0.227) // #c66f3a

/// Scale a "native" point from the given viewBox size to the canvas size.
private func sc(_ value: CGFloat, from vb: CGFloat, to canvas: CGFloat) -> CGFloat {
    value / vb * canvas
}

/// Build a CGPath polygon from points in native coordinate space [x0,y0, x1,y1, …]
private func poly(_ pts: [CGFloat], vb: CGFloat, canvas: CGFloat) -> Path {
    var path = Path()
    guard pts.count >= 4, pts.count.isMultiple(of: 2) else { return path }
    let scale = canvas / vb
    path.move(to: CGPoint(x: pts[0]*scale, y: pts[1]*scale))
    stride(from: 2, to: pts.count, by: 2).forEach { i in
        path.addLine(to: CGPoint(x: pts[i]*scale, y: pts[i+1]*scale))
    }
    path.closeSubpath()
    return path
}

private func fill(_ ctx: GraphicsContext, _ path: Path, _ color: Color) {
    ctx.fill(path, with: .color(color))
}

private func fillStroke(_ ctx: GraphicsContext, _ path: Path, _ fill: Color, strokeW: CGFloat = 2, vb: CGFloat = 100) {
    ctx.fill(path, with: .color(fill))
    ctx.stroke(path, with: .color(stroke), lineWidth: strokeW)
}

private func strokeOnly(_ ctx: GraphicsContext, _ path: Path, _ c: Color, strokeW: CGFloat = 2) {
    ctx.stroke(path, with: .color(c), lineWidth: strokeW)
}

// MARK: - 共用底座 diamond (100 vb)

private func baseDiamond100(_ ctx: GraphicsContext, _ s: CGFloat) {
    let b = poly([20,80,50,95,80,80,50,65], vb:100, canvas:s)
    fillStroke(ctx, b, kraft2)
}

private func baseDiamondLeft100(_ ctx: GraphicsContext, _ s: CGFloat) {
    let l = poly([20,80,50,95,50,80,20,65], vb:100, canvas:s)
    fill(ctx, l, tile2)
}

private func baseDiamondRight100(_ ctx: GraphicsContext, _ s: CGFloat) {
    let r = poly([50,95,80,80,80,65,50,80], vb:100, canvas:s)
    fill(ctx, r, deep)
}

// MARK: - 三大篇 bigcards (100×100 vb)

private func drawStairs(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond100(ctx, s); baseDiamondLeft100(ctx, s); baseDiamondRight100(ctx, s)
    let vb: CGFloat = 100
    let sw: CGFloat = 2
    // stair face 1
    fillStroke(ctx, poly([50,65,60,70,60,60,50,55], vb:vb, canvas:s), paper, strokeW:sw)
    // stair top 1
    fillStroke(ctx, poly([50,55,60,60,70,55,60,50], vb:vb, canvas:s), kraft2, strokeW:sw)
    // stair side 1
    fillStroke(ctx, poly([60,60,70,55,70,45,60,50], vb:vb, canvas:s), kraft2, strokeW:sw)
    // stair face 2
    fillStroke(ctx, poly([60,50,70,45,80,40,70,35], vb:vb, canvas:s), paper, strokeW:sw)
    // stair side 2
    fillStroke(ctx, poly([70,55,80,40,80,30,70,45], vb:vb, canvas:s), kraft2, strokeW:sw)
}

private func drawColumn(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond100(ctx, s); baseDiamondLeft100(ctx, s); baseDiamondRight100(ctx, s)
    let vb: CGFloat = 100; let sw: CGFloat = 2
    fillStroke(ctx, poly([40,75,50,80,50,40,40,35], vb:vb, canvas:s), paper, strokeW:sw)   // shaft left
    fillStroke(ctx, poly([50,80,60,75,60,35,50,40], vb:vb, canvas:s), kraft2, strokeW:sw)  // shaft right
    fillStroke(ctx, poly([40,35,50,40,60,35,50,30], vb:vb, canvas:s), tile2, strokeW:sw)   // shaft top
    fillStroke(ctx, poly([30,30,50,40,70,30,50,20], vb:vb, canvas:s), paper, strokeW:sw)   // entab top
    fillStroke(ctx, poly([30,30,50,40,50,30,30,20], vb:vb, canvas:s), kraft2, strokeW:sw)  // entab left
    fillStroke(ctx, poly([50,40,70,30,70,20,50,30], vb:vb, canvas:s), tile2, strokeW:sw)   // entab right
    fill(ctx, poly([35,20,50,15,65,20,50,10], vb:vb, canvas:s), .init(red:0.227,green:0.184,blue:0.122)) // pediment dark
}

private func drawLightbulb(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond100(ctx, s); baseDiamondLeft100(ctx, s); baseDiamondRight100(ctx, s)
    let vb: CGFloat = 100; let sw: CGFloat = 2
    fillStroke(ctx, poly([35,75,50,82,50,55,35,48], vb:vb, canvas:s), paper, strokeW:sw)   // box left
    fillStroke(ctx, poly([50,82,65,75,65,48,50,55], vb:vb, canvas:s), kraft2, strokeW:sw)  // box right
    fillStroke(ctx, poly([35,48,50,55,65,48,50,41], vb:vb, canvas:s), tile2, strokeW:sw)   // box top
    // bulb circle
    let scale = s / vb
    let cx = 50*scale; let cy = 32*scale; let r = 13*scale
    var bulb = Path(); bulb.addEllipse(in: CGRect(x:cx-r, y:cy-r, width:r*2, height:r*2))
    fillStroke(ctx, bulb, goldC, strokeW:sw)
}

// MARK: - 章節列 small (40×40 vb)

private func baseDiamond40(_ ctx: GraphicsContext, _ s: CGFloat) {
    fillStroke(ctx, poly([8,30,20,36,32,30,20,24], vb:40, canvas:s), kraft2, strokeW:1.5)
}

private func drawBoxBasic(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let vb: CGFloat = 40; let sw: CGFloat = 1.5
    fillStroke(ctx, poly([14,27,20,30,20,16,14,13], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([20,30,26,27,26,13,20,16], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([14,13,20,16,26,13,20,10], vb:vb, canvas:s), tile2, strokeW:sw)
}

private func drawBoxBand(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let vb: CGFloat = 40; let sw: CGFloat = 1.5
    fillStroke(ctx, poly([14,24,20,27,20,12,14,9], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([20,27,26,24,26,9,20,12], vb:vb, canvas:s), kraft2, strokeW:sw)
    fill(ctx, poly([12,12,28,12,28,9,12,9], vb:vb, canvas:s), stroke)
}

private func drawStairSmall(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let vb: CGFloat = 40; let sw: CGFloat = 1.5
    fillStroke(ctx, poly([14,30,20,33,20,28,14,25], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([14,25,20,28,26,25,20,22], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([20,28,26,25,26,20,20,22], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([20,22,26,20,32,17,26,14], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([26,20,32,17,32,12,26,14], vb:vb, canvas:s), kraft2, strokeW:sw)
}

private func drawFlame(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let sc40 = s / 40
    var outerFlame = Path()
    outerFlame.move(to: CGPoint(x: 20*sc40, y: 26*sc40))
    outerFlame.addCurve(to: CGPoint(x:17*sc40, y:21*sc40),
                        control1: CGPoint(x:18*sc40, y:24*sc40),
                        control2: CGPoint(x:17*sc40, y:23*sc40))
    outerFlame.addCurve(to: CGPoint(x:20*sc40, y:14*sc40),
                        control1: CGPoint(x:17*sc40, y:18*sc40),
                        control2: CGPoint(x:20*sc40, y:17*sc40))
    outerFlame.addCurve(to: CGPoint(x:24*sc40, y:21*sc40),
                        control1: CGPoint(x:21*sc40, y:17*sc40),
                        control2: CGPoint(x:24*sc40, y:18*sc40))
    outerFlame.addCurve(to: CGPoint(x:20*sc40, y:26*sc40),
                        control1: CGPoint(x:24*sc40, y:23*sc40),
                        control2: CGPoint(x:22*sc40, y:25*sc40))
    outerFlame.closeSubpath()
    fill(ctx, outerFlame, rust)

    var innerFlame = Path()
    innerFlame.move(to: CGPoint(x:19*sc40, y:22*sc40))
    innerFlame.addCurve(to: CGPoint(x:17*sc40, y:19*sc40),
                        control1: CGPoint(x:18*sc40, y:21*sc40),
                        control2: CGPoint(x:17*sc40, y:20*sc40))
    innerFlame.addCurve(to: CGPoint(x:19*sc40, y:15*sc40),
                        control1: CGPoint(x:17*sc40, y:17*sc40),
                        control2: CGPoint(x:19*sc40, y:16*sc40))
    innerFlame.addCurve(to: CGPoint(x:22*sc40, y:19*sc40),
                        control1: CGPoint(x:20*sc40, y:16*sc40),
                        control2: CGPoint(x:22*sc40, y:17*sc40))
    innerFlame.addCurve(to: CGPoint(x:19*sc40, y:22*sc40),
                        control1: CGPoint(x:22*sc40, y:21*sc40),
                        control2: CGPoint(x:20*sc40, y:22*sc40))
    innerFlame.closeSubpath()
    fill(ctx, innerFlame, goldC)
}

private func drawParking(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let vb: CGFloat = 40
    fill(ctx, poly([11,28,14,30,26,23,23,21], vb:vb, canvas:s), .white)
    fill(ctx, poly([17,31,20,33,32,26,29,24], vb:vb, canvas:s), .white)
}

private func drawWheelchair(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let vb: CGFloat = 40; let sc = s/vb; let sw: CGFloat = 1.5
    var wc = Path(); wc.move(to:CGPoint(x:16*sc,y:22*sc)); wc.addLine(to:CGPoint(x:20*sc,y:23*sc))
    wc.addLine(to:CGPoint(x:22*sc,y:27*sc)); wc.addLine(to:CGPoint(x:26*sc,y:29*sc))
    ctx.stroke(wc, with:.color(skyC), lineWidth:sw)
    var head = Path(); head.addEllipse(in:CGRect(x:(22-2.5)*sc,y:(14-2.5)*sc,width:5*sc,height:5*sc))
    fill(ctx, head, skyC)
}

private func drawColumnSmall(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let vb: CGFloat = 40; let sw: CGFloat = 1.5
    fillStroke(ctx, poly([14,27,20,30,20,14,14,11], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([20,30,26,27,26,11,20,14], vb:vb, canvas:s), kraft2, strokeW:sw)
    fill(ctx, poly([12,14,20,17,28,14,20,11], vb:vb, canvas:s), stroke)
}

private func drawGear(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond40(ctx, s)
    let vb: CGFloat = 40; let sc = s/vb
    var bulb = Path(); bulb.addEllipse(in:CGRect(x:(20-6)*sc,y:(14-6)*sc,width:12*sc,height:12*sc))
    fillStroke(ctx, bulb, goldC, strokeW:1.5)
}

// MARK: - 常用卡 fav (64×64 vb)

private func baseDiamond64(_ ctx: GraphicsContext, _ s: CGFloat) {
    fillStroke(ctx, poly([10,48,32,58,54,48,32,38], vb:64, canvas:s), kraft2, strokeW:2)
}

private func drawFavDesign(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let vb: CGFloat = 64; let sw: CGFloat = 2
    fillStroke(ctx, poly([20,44,32,50,32,18,20,12], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([32,50,44,44,44,12,32,18], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([20,12,32,18,44,12,32,6], vb:vb, canvas:s), tile2, strokeW:sw)
    fill(ctx, poly([14,20,18,18,16,16,12,18], vb:vb, canvas:s), stroke)
}

private func drawFavFire(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let sc64 = s/64
    var of = Path()
    of.move(to:CGPoint(x:32*sc64,y:42*sc64))
    of.addCurve(to:CGPoint(x:25*sc64,y:30*sc64), control1:CGPoint(x:28*sc64,y:38*sc64), control2:CGPoint(x:25*sc64,y:36*sc64))
    of.addCurve(to:CGPoint(x:32*sc64,y:14*sc64), control1:CGPoint(x:25*sc64,y:23*sc64), control2:CGPoint(x:32*sc64,y:19*sc64))
    of.addCurve(to:CGPoint(x:41*sc64,y:30*sc64), control1:CGPoint(x:34*sc64,y:19*sc64), control2:CGPoint(x:41*sc64,y:23*sc64))
    of.addCurve(to:CGPoint(x:32*sc64,y:42*sc64), control1:CGPoint(x:41*sc64,y:36*sc64), control2:CGPoint(x:36*sc64,y:40*sc64))
    of.closeSubpath(); fill(ctx, of, rust)

    var inf = Path()
    inf.move(to:CGPoint(x:30*sc64,y:36*sc64))
    inf.addCurve(to:CGPoint(x:27*sc64,y:30*sc64), control1:CGPoint(x:28*sc64,y:34*sc64), control2:CGPoint(x:27*sc64,y:33*sc64))
    inf.addCurve(to:CGPoint(x:32*sc64,y:21*sc64), control1:CGPoint(x:27*sc64,y:25*sc64), control2:CGPoint(x:32*sc64,y:23*sc64))
    inf.addCurve(to:CGPoint(x:37*sc64,y:30*sc64), control1:CGPoint(x:33*sc64,y:23*sc64), control2:CGPoint(x:37*sc64,y:25*sc64))
    inf.addCurve(to:CGPoint(x:30*sc64,y:36*sc64), control1:CGPoint(x:37*sc64,y:34*sc64), control2:CGPoint(x:33*sc64,y:36*sc64))
    inf.closeSubpath(); fill(ctx, inf, goldC)
}

private func drawFavAccess(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let vb: CGFloat = 64; let sc = s/vb; let sw: CGFloat = 2
    var path = Path()
    path.move(to:CGPoint(x:26*sc,y:32*sc)); path.addLine(to:CGPoint(x:34*sc,y:34*sc))
    path.addLine(to:CGPoint(x:38*sc,y:42*sc)); path.addLine(to:CGPoint(x:46*sc,y:46*sc))
    ctx.stroke(path, with:.color(skyC), lineWidth:sw)
    var head = Path(); head.addEllipse(in:CGRect(x:(36-4)*sc,y:(20-4)*sc,width:8*sc,height:8*sc))
    fill(ctx, head, skyC)
}

private func drawFavParking(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let vb: CGFloat = 64; let sw: CGFloat = 1.5
    fill(ctx, poly([14,46,20,49,38,38,32,35], vb:vb, canvas:s), .white)
    fill(ctx, poly([22,50,28,53,46,42,40,39], vb:vb, canvas:s), .white)
    fillStroke(ctx, poly([22,40,32,46,50,35,40,30], vb:vb, canvas:s), skyC.opacity(0.5), strokeW:sw)
}

private func drawFavVent(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let vb: CGFloat = 64; let sw: CGFloat = 2
    fillStroke(ctx, poly([20,44,32,50,32,16,20,10], vb:vb, canvas:s), skyC, strokeW:sw)
    fillStroke(ctx, poly([32,50,44,44,44,10,32,16], vb:vb, canvas:s), Color(red:0.490,green:0.663,blue:0.769), strokeW:sw)
    let sc64 = s/vb
    var div = Path()
    div.move(to:CGPoint(x:20*sc64,y:27*sc64)); div.addLine(to:CGPoint(x:44*sc64,y:27*sc64))
    div.move(to:CGPoint(x:20*sc64,y:33*sc64)); div.addLine(to:CGPoint(x:44*sc64,y:33*sc64))
    div.move(to:CGPoint(x:26*sc64,y:13*sc64)); div.addLine(to:CGPoint(x:26*sc64,y:47*sc64))
    div.move(to:CGPoint(x:38*sc64,y:13*sc64)); div.addLine(to:CGPoint(x:38*sc64,y:47*sc64))
    ctx.stroke(div, with:.color(stroke), lineWidth:1)
}

private func drawFavGreen(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let sc64 = s/64; let sw: CGFloat = 2
    var lL = Path()
    lL.move(to:CGPoint(x:32*sc64,y:28*sc64))
    lL.addCurve(to:CGPoint(x:23*sc64,y:16*sc64), control1:CGPoint(x:26*sc64,y:26*sc64), control2:CGPoint(x:23*sc64,y:22*sc64))
    lL.addCurve(to:CGPoint(x:32*sc64,y:28*sc64), control1:CGPoint(x:29*sc64,y:16*sc64), control2:CGPoint(x:32*sc64,y:21*sc64))
    lL.closeSubpath(); fill(ctx, lL, AppTheme.leaf)

    var lR = Path()
    lR.move(to:CGPoint(x:32*sc64,y:22*sc64))
    lR.addCurve(to:CGPoint(x:41*sc64,y:10*sc64), control1:CGPoint(x:38*sc64,y:20*sc64), control2:CGPoint(x:41*sc64,y:16*sc64))
    lR.addCurve(to:CGPoint(x:32*sc64,y:22*sc64), control1:CGPoint(x:35*sc64,y:10*sc64), control2:CGPoint(x:32*sc64,y:15*sc64))
    lR.closeSubpath(); fill(ctx, lR, Color(red:0.604,green:0.682,blue:0.478))

    var stem = Path()
    stem.move(to:CGPoint(x:32*sc64,y:42*sc64)); stem.addLine(to:CGPoint(x:32*sc64,y:22*sc64))
    ctx.stroke(stem, with:.color(AppTheme.leaf), lineWidth:sw)
}

private func drawFavStruct(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let vb: CGFloat = 64; let sw: CGFloat = 2
    fillStroke(ctx, poly([20,44,32,50,32,18,20,14], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([32,50,44,44,44,14,32,18], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([14,18,20,21,20,14,14,11], vb:vb, canvas:s), tile2, strokeW:sw)
    fillStroke(ctx, poly([44,14,50,11,50,18,44,21], vb:vb, canvas:s), tile2, strokeW:sw)
    fill(ctx, poly([14,11,32,5,50,11,32,18], vb:vb, canvas:s), stroke)
}

private func drawFavEquip(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond64(ctx, s)
    let vb: CGFloat = 64; let sc = s/vb; let sw: CGFloat = 2
    var gear = Path(); gear.addEllipse(in:CGRect(x:(32-9)*sc,y:(22-9)*sc,width:18*sc,height:18*sc))
    fillStroke(ctx, gear, goldC, strokeW:sw)
    var stem = Path()
    stem.move(to:CGPoint(x:32*sc,y:31*sc)); stem.addLine(to:CGPoint(x:32*sc,y:40*sc))
    stem.move(to:CGPoint(x:28*sc,y:34*sc)); stem.addLine(to:CGPoint(x:36*sc,y:34*sc))
    stem.move(to:CGPoint(x:28*sc,y:37*sc)); stem.addLine(to:CGPoint(x:36*sc,y:37*sc))
    ctx.stroke(stem, with:.color(stroke), lineWidth:sw)
}

// MARK: - 計算器 calc (48×48 vb)

private func baseDiamond48(_ ctx: GraphicsContext, _ s: CGFloat) {
    fillStroke(ctx, poly([6,36,24,44,42,36,24,28], vb:48, canvas:s), kraft2, strokeW:1.6)
}

private func drawCalcBox(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond48(ctx, s)
    let vb: CGFloat = 48; let sw: CGFloat = 1.6
    fillStroke(ctx, poly([12,33,24,39,24,15,12,9], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([24,39,36,33,36,9,24,15], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([12,9,24,15,36,9,24,3], vb:vb, canvas:s), tile2, strokeW:sw)
}

private func drawCalcWindow(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond48(ctx, s)
    let vb: CGFloat = 48; let sw: CGFloat = 1.6
    fillStroke(ctx, poly([14,32,24,37,24,22,14,17], vb:vb, canvas:s), skyC, strokeW:sw)
    fillStroke(ctx, poly([24,37,34,32,34,17,24,22], vb:vb, canvas:s), Color(red:0.490,green:0.663,blue:0.769), strokeW:sw)
    fill(ctx, poly([14,17,24,22,34,17,24,12], vb:vb, canvas:s), stroke)
}

private func drawCalcSlab(_ ctx: GraphicsContext, _ s: CGFloat) {
    let vb: CGFloat = 48; let sw: CGFloat = 1.6
    fillStroke(ctx, poly([6,30,24,38,42,30,24,22], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([6,30,24,38,24,42,6,34], vb:vb, canvas:s), tile2, strokeW:sw)
    fillStroke(ctx, poly([24,38,42,30,42,34,24,42], vb:vb, canvas:s), deep, strokeW:sw)
    let sc48 = s/vb
    var cross = Path()
    cross.move(to:CGPoint(x:24*sc48,y:22*sc48)); cross.addLine(to:CGPoint(x:24*sc48,y:38*sc48))
    cross.move(to:CGPoint(x:6*sc48,y:30*sc48)); cross.addLine(to:CGPoint(x:42*sc48,y:30*sc48))
    ctx.stroke(cross, with:.color(stroke), lineWidth:1)
}

private func drawCalcStairs(_ ctx: GraphicsContext, _ s: CGFloat) {
    let vb: CGFloat = 48; let sw: CGFloat = 1.6
    let steps: [[CGFloat]] = [
        [6,40,12,42,12,38,6,36],
        [12,38,18,40,18,32,12,30],
        [18,32,24,34,24,26,18,24],
        [24,26,30,28,30,20,24,18],
        [30,20,36,22,36,14,30,12],
        [36,14,42,16,42,8,36,6]
    ]
    for step in steps {
        fillStroke(ctx, poly(step, vb:vb, canvas:s), paper, strokeW:sw)
    }
}

private func drawCalcParking(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond48(ctx, s)
    let vb: CGFloat = 48
    fill(ctx, poly([10,34,16,37,30,29,24,26], vb:vb, canvas:s), .white)
    fill(ctx, poly([18,38,24,41,38,33,32,30], vb:vb, canvas:s), .white)
}

private func drawCalcHeight(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond48(ctx, s)
    let vb: CGFloat = 48; let sw: CGFloat = 1.6; let sc48 = s/vb
    fillStroke(ctx, poly([6,40,24,44,42,40,24,36], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([14,38,24,40,24,8,14,6], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([24,40,34,38,34,6,24,8], vb:vb, canvas:s), kraft2, strokeW:sw)
    var lines = Path()
    lines.move(to:CGPoint(x:14*sc48,y:20*sc48)); lines.addLine(to:CGPoint(x:34*sc48,y:20*sc48))
    lines.move(to:CGPoint(x:14*sc48,y:28*sc48)); lines.addLine(to:CGPoint(x:34*sc48,y:28*sc48))
    ctx.stroke(lines, with:.color(stroke), lineWidth:1)
}

private func drawCalcGround(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond48(ctx, s)
    let vb: CGFloat = 48; let sw: CGFloat = 1.6
    fillStroke(ctx, poly([16,32,24,35,30,32,22,29], vb:vb, canvas:s), .white, strokeW:sw)
    fillStroke(ctx, poly([22,29,30,32,30,28,22,25], vb:vb, canvas:s), skyC, strokeW:sw)
}

// MARK: - Paywall feature list (28×28 vb)

private func baseDiamond28(_ ctx: GraphicsContext, _ s: CGFloat) {
    fillStroke(ctx, poly([4,21,14,26,24,21,14,16], vb:28, canvas:s), kraft2, strokeW:1.4)
}

private func drawFeatIllust(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond28(ctx, s)
    let vb: CGFloat = 28; let sw: CGFloat = 1.4
    fillStroke(ctx, poly([8,19,14,22,14,8,8,5], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([14,22,20,19,20,5,14,8], vb:vb, canvas:s), kraft2, strokeW:sw)
}

private func drawFeatText(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond28(ctx, s)
    let vb: CGFloat = 28; let sw: CGFloat = 1.4; let sc28 = s/vb
    fillStroke(ctx, poly([9,17,14,19,14,7,9,5], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([14,19,19,17,19,5,14,7], vb:vb, canvas:s), kraft2, strokeW:sw)
    var lines = Path()
    lines.move(to:CGPoint(x:9*sc28,y:11*sc28)); lines.addLine(to:CGPoint(x:19*sc28,y:11*sc28))
    lines.move(to:CGPoint(x:9*sc28,y:14*sc28)); lines.addLine(to:CGPoint(x:19*sc28,y:14*sc28))
    ctx.stroke(lines, with:.color(stroke), lineWidth:1)
}

private func drawFeatStar(_ ctx: GraphicsContext, _ s: CGFloat) {
    let pts: [CGFloat] = [14,4, 16.5,11, 24,11, 18,15, 20,22, 14,18, 8,22, 10,15, 4,11, 11.5,11]
    fillStroke(ctx, poly(pts, vb:28, canvas:s), goldC, strokeW:1.4)
}

private func drawFeatCalc(_ ctx: GraphicsContext, _ s: CGFloat) {
    baseDiamond28(ctx, s)
    let vb: CGFloat = 28; let sc28 = s/vb; let sw: CGFloat = 1.4
    var rect = Path(); rect.addRect(CGRect(x:9*sc28,y:6*sc28,width:10*sc28,height:14*sc28))
    fillStroke(ctx, rect, paper, strokeW:sw)
    var lines = Path()
    lines.move(to:CGPoint(x:9*sc28,y:9*sc28)); lines.addLine(to:CGPoint(x:19*sc28,y:9*sc28))
    lines.move(to:CGPoint(x:11*sc28,y:12*sc28)); lines.addLine(to:CGPoint(x:13*sc28,y:12*sc28))
    lines.move(to:CGPoint(x:15*sc28,y:12*sc28)); lines.addLine(to:CGPoint(x:17*sc28,y:12*sc28))
    ctx.stroke(lines, with:.color(stroke), lineWidth:1)
}

private func drawFeatPDF(_ ctx: GraphicsContext, _ s: CGFloat) {
    let vb: CGFloat = 28; let sc28 = s/vb; let sw: CGFloat = 1.4
    var rect = Path(); rect.addRoundedRect(in:CGRect(x:7*sc28,y:6*sc28,width:14*sc28,height:16*sc28), cornerSize:CGSize(width:1*sc28,height:1*sc28))
    fillStroke(ctx, rect, .white, strokeW:sw)
    var arrow = Path()
    arrow.move(to:CGPoint(x:14*sc28,y:16*sc28)); arrow.addLine(to:CGPoint(x:14*sc28,y:8*sc28))
    arrow.move(to:CGPoint(x:11*sc28,y:11*sc28)); arrow.addLine(to:CGPoint(x:14*sc28,y:8*sc28))
    arrow.addLine(to:CGPoint(x:17*sc28,y:11*sc28))
    ctx.stroke(arrow, with:.color(rust), lineWidth:sw)
}

private func drawFeatCloud(_ ctx: GraphicsContext, _ s: CGFloat) {
    let vb: CGFloat = 28; let sc28 = s/vb; let sw: CGFloat = 1.4
    var cloud = Path()
    cloud.move(to:CGPoint(x:7*sc28,y:16*sc28))
    cloud.addArc(center:CGPoint(x:11*sc28,y:12*sc28), radius:4*sc28, startAngle:.degrees(180), endAngle:.degrees(90), clockwise:true)
    cloud.addArc(center:CGPoint(x:16*sc28,y:8*sc28), radius:5*sc28, startAngle:.degrees(180), endAngle:.degrees(0), clockwise:false)
    cloud.addArc(center:CGPoint(x:21*sc28,y:13*sc28), radius:3*sc28, startAngle:.degrees(0), endAngle:.degrees(90), clockwise:false)
    cloud.addLine(to:CGPoint(x:7*sc28,y:19*sc28))
    cloud.closeSubpath()
    fillStroke(ctx, cloud, skyC, strokeW:sw)
}

private func drawFeatNoAd(_ ctx: GraphicsContext, _ s: CGFloat) {
    let vb: CGFloat = 28; let sc28 = s/vb; let sw: CGFloat = 1.4
    var circle = Path(); circle.addEllipse(in:CGRect(x:(14-8)*sc28,y:(14-8)*sc28,width:16*sc28,height:16*sc28))
    fillStroke(ctx, circle, .white, strokeW:sw)
    var line = Path()
    line.move(to:CGPoint(x:9*sc28,y:9*sc28)); line.addLine(to:CGPoint(x:19*sc28,y:19*sc28))
    ctx.stroke(line, with:.color(stroke), lineWidth:sw)
}

// MARK: - Lock Hero (140×140 vb)

private func drawLockHero(_ ctx: GraphicsContext, _ s: CGFloat) {
    let vb: CGFloat = 140; let sw: CGFloat = 2.5; let sc = s/vb

    // Ground
    fillStroke(ctx, poly([30,90,70,110,110,90,70,70], vb:vb, canvas:s), kraft2, strokeW:sw)
    fill(ctx, poly([30,90,70,110,70,114,30,94], vb:vb, canvas:s), tile2)
    fill(ctx, poly([70,110,110,90,110,94,70,114], vb:vb, canvas:s), deep)

    // House body
    fillStroke(ctx, poly([44,82,70,95,70,55,44,42], vb:vb, canvas:s), paper, strokeW:sw)
    fillStroke(ctx, poly([70,95,96,82,96,42,70,55], vb:vb, canvas:s), kraft2, strokeW:sw)
    fillStroke(ctx, poly([44,42,70,55,96,42,70,29], vb:vb, canvas:s), tile2, strokeW:sw)

    // Roof
    fill(ctx, poly([38,45,70,30,70,15,38,30], vb:vb, canvas:s), stroke)
    fill(ctx, poly([70,30,102,45,102,30,70,15], vb:vb, canvas:s), Color(red:0.353,green:0.290,blue:0.188))

    // Lock body
    let lx: CGFloat = 58; let ly: CGFloat = 62
    var lockBody = Path()
    lockBody.addRoundedRect(in:CGRect(x:(lx+0)*sc, y:(ly+14)*sc, width:28*sc, height:22*sc), cornerSize:CGSize(width:2*sc, height:2*sc))
    fillStroke(ctx, lockBody, rust, strokeW:2)

    // Lock shackle
    var shackle = Path()
    shackle.move(to:CGPoint(x:(lx+5)*sc, y:(ly+14)*sc))
    shackle.addLine(to:CGPoint(x:(lx+5)*sc, y:(ly+8)*sc))
    shackle.addArc(center:CGPoint(x:(lx+14)*sc, y:(ly+8)*sc), radius:9*sc, startAngle:.degrees(180), endAngle:.degrees(0), clockwise:false)
    shackle.addLine(to:CGPoint(x:(lx+23)*sc, y:(ly+14)*sc))
    ctx.stroke(shackle, with:.color(stroke), lineWidth:2.5)

    // Lock keyhole
    var keyhole = Path(); keyhole.addEllipse(in:CGRect(x:(lx+12)*sc, y:(ly+20)*sc, width:4*sc, height:4*sc))
    fill(ctx, keyhole, stroke)
    var pin = Path()
    pin.move(to:CGPoint(x:(lx+14)*sc, y:(ly+24)*sc)); pin.addLine(to:CGPoint(x:(lx+14)*sc, y:(ly+30)*sc))
    ctx.stroke(pin, with:.color(stroke), lineWidth:2)
}

// MARK: - Tab bar SVG icon views

/// Custom tab bar icon — renders as SwiftUI Shape path
struct TabIconShape: Shape {
    let kind: TabIcon

    enum TabIcon { case illust, fulltext, common, calc, resource }

    func path(in rect: CGRect) -> Path {
        let s = min(rect.width, rect.height)
        let scale = s / 24
        var p = Path()
        switch kind {
        case .illust:
            // diamond + lower polyline
            p.move(to: CGPoint(x: 3*scale, y: 12*scale))
            p.addLine(to: CGPoint(x: 12*scale, y: 7*scale))
            p.addLine(to: CGPoint(x: 21*scale, y: 12*scale))
            p.addLine(to: CGPoint(x: 12*scale, y: 17*scale))
            p.closeSubpath()
            p.move(to: CGPoint(x: 3*scale, y: 16*scale))
            p.addLine(to: CGPoint(x: 12*scale, y: 21*scale))
            p.addLine(to: CGPoint(x: 21*scale, y: 16*scale))
        case .fulltext:
            // document shape
            p.move(to: CGPoint(x: 5*scale, y: 4*scale))
            p.addLine(to: CGPoint(x: 16*scale, y: 4*scale))
            p.addLine(to: CGPoint(x: 19*scale, y: 7*scale))
            p.addLine(to: CGPoint(x: 19*scale, y: 20*scale))
            p.addLine(to: CGPoint(x: 5*scale, y: 20*scale))
            p.closeSubpath()
        case .common:
            // star
            let pts: [(Double,Double)] = [(12,4),(14.4,9),(20,9.5),(15.8,13.3),(17.1,18.9),(12,16),(6.9,18.9),(8.2,13.3),(4,9.5),(9.6,9)]
            p.move(to: CGPoint(x: pts[0].0*scale, y: pts[0].1*scale))
            pts.dropFirst().forEach { p.addLine(to: CGPoint(x: $0.0*scale, y: $0.1*scale)) }
            p.closeSubpath()
        case .calc:
            // calculator doc
            p.addRoundedRect(in: CGRect(x: 6*scale, y: 4*scale, width: 12*scale, height: 16*scale), cornerSize: CGSize(width: 2*scale, height: 2*scale))
        case .resource:
            // compass pin + reference dot
            p.addEllipse(in: CGRect(x: 5*scale, y: 4*scale, width: 14*scale, height: 14*scale))
            p.move(to: CGPoint(x: 12*scale, y: 8*scale))
            p.addLine(to: CGPoint(x: 14.5*scale, y: 12*scale))
            p.addLine(to: CGPoint(x: 10*scale, y: 15*scale))
            p.closeSubpath()
            p.move(to: CGPoint(x: 7*scale, y: 21*scale))
            p.addLine(to: CGPoint(x: 17*scale, y: 21*scale))
        }
        return p
    }
}
