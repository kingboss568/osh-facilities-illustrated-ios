//
//  FireCommonClausesView.swift
//  職業安全衛生設施規則全圖解
//

import SwiftUI

struct FireCommonClausesView: View {
    @EnvironmentObject private var iap: IAPManager
    @State private var showPaywall = false

    private let groups: [OSHClauseGroup] = [
        .init(title: "總則與最低標準", subtitle: "第1-18條", rows: [
            .init(article: "第1條", title: "法源依據", note: "本規則依職業安全衛生法第六條第三項訂定。"),
            .init(article: "第2條", title: "最低標準", note: "雇主使勞工從事工作之安全衛生設備及措施，至少應達本規則要求。"),
            .init(article: "第11-18條", title: "危險物與高壓氣體", note: "爆炸性、著火性、氧化性、可燃性氣體與高壓氣體需先分類管理。")
        ]),
        .init(title: "機械與車輛安全", subtitle: "防護、制動、警報", rows: [
            .init(article: "機械設備相關條文", title: "危險點防護", note: "傳動、切割、捲夾等危險點需以護罩、連鎖、距離或停止裝置降低風險。"),
            .init(article: "車輛機械相關條文", title: "人車分流", note: "堆高機、營建機械與搬運路線需配置通道、警示、速度與視線管理。"),
            .init(article: "起重吊掛相關條文", title: "吊掛作業", note: "額定荷重、吊具、指揮、作業半徑與下方管制是審查重點。")
        ], isPro: true),
        .init(title: "高處與通道", subtitle: "防墜、開口、施工架", rows: [
            .init(article: "開口防護相關條文", title: "開口墜落", note: "樓板、坑洞、屋頂邊緣需以護欄、蓋板、警示或防墜系統管制。"),
            .init(article: "通道相關條文", title: "安全通道", note: "通道須保持淨空、照明、防滑、標示與緊急通行可用。"),
            .init(article: "施工架相關條文", title: "施工架檢查", note: "基礎、拉結、踏板、護欄與上下設備需作業前確認。")
        ], isPro: true),
        .init(title: "電氣化學與特殊危害", subtitle: "動火、局限、臨時用電", rows: [
            .init(article: "電氣相關條文", title: "臨時用電", note: "漏電、接地、線徑、防水、上鎖掛牌與配線保護是基本檢核。"),
            .init(article: "化學品相關條文", title: "標示與相容", note: "化學品需核對 SDS、容器標示、儲存相容性、通風與洩漏應變。"),
            .init(article: "特殊作業相關條文", title: "作業許可", note: "動火、局限空間、高處與吊掛作業應以許可、監視與救援計畫管理。")
        ], isPro: true),
        .init(title: "衛生環境與防護", subtitle: "通風、噪音、PPE", rows: [
            .init(article: "衛生設施相關條文", title: "作業環境", note: "通風、採光、溫熱、噪音與振動需依危害程度採工程與管理控制。"),
            .init(article: "防護具相關條文", title: "個人防護具", note: "PPE 需依危害選用、密合、維護與更換，不能取代工程控制。"),
            .init(article: "教育紀錄相關條文", title: "留存紀錄", note: "檢查、教育訓練、改善照片與承攬告知應可追溯。")
        ], isPro: true),
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        ForEach(groups) { group in groupCard(group) }
                        Spacer().frame(height: 104)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                }
            }
            .sheet(isPresented: $showPaywall) { PaywallView() }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("COMMON CLAUSES").font(.system(size: 9, weight: .medium)).italic().kerning(3).foregroundStyle(AppTheme.mute)
            Text("常用條文").font(.system(size: 34, weight: .heavy, design: .serif)).foregroundStyle(AppTheme.primary)
            Text("把職安設施規則常見稽核焦點整理成可快速掃描的條文群。").font(.system(size: 13, weight: .medium)).foregroundStyle(AppTheme.mute)
            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 4)
        }
    }

    private func groupCard(_ group: OSHClauseGroup) -> some View {
        let locked = group.isPro && !iap.isUnlocked
        return VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 3) {
                    Text(group.title).font(.system(size: 20, weight: .heavy)).foregroundStyle(AppTheme.primary)
                    Text(group.subtitle).font(.system(size: 12, weight: .semibold)).foregroundStyle(AppTheme.mute)
                }
                Spacer()
                if locked { Image(systemName: "lock.fill").foregroundStyle(AppTheme.rust) }
            }
            ForEach(group.rows) { row in
                HStack(alignment: .top, spacing: 10) {
                    Text(row.article).font(.system(size: 12, weight: .heavy)).foregroundStyle(AppTheme.resourceBlue).frame(width: 72, alignment: .leading)
                    VStack(alignment: .leading, spacing: 3) {
                        Text(row.title).font(.system(size: 15, weight: .heavy)).foregroundStyle(AppTheme.primary)
                        Text(row.note).font(.system(size: 13, weight: .medium)).foregroundStyle(AppTheme.mute).lineSpacing(3)
                    }
                    Spacer(minLength: 0)
                }
                .padding(.vertical, 6)
                .blur(radius: locked ? 2 : 0)
            }
            if locked {
                Button("Pro / 解鎖完整條文群") { showPaywall = true }
                    .font(.system(size: 13, weight: .heavy))
                    .foregroundStyle(.white)
                    .padding(.horizontal, 14)
                    .padding(.vertical, 9)
                    .background(AppTheme.rust, in: Capsule())
            }
        }
        .padding(14)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
    }
}

private struct OSHClauseGroup: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let rows: [OSHClauseRow]
    var isPro: Bool = false
}

private struct OSHClauseRow: Identifiable {
    let id = UUID()
    let article: String
    let title: String
    let note: String
}

#Preview {
    FireCommonClausesView().environmentObject(IAPManager())
}
