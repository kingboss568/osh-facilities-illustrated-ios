//
//  QuizView.swift
//  職業安全衛生設施規則全圖解
//

import SwiftUI

private struct LegacyCalculatorsHomeView: View {
    @EnvironmentObject private var iap: IAPManager
    @State private var showPaywall = false

    private let sections: [InteriorToolSection] = [
        .init(title: "作業前檢核", subtitle: "開工前把危害源先收斂", tools: [.init(title: "雇主最低標準檢核", subtitle: "第1-2條基礎責任", icon: "checklist.checked", accent: AppTheme.resourceBlue, steps: ["確認作業是否已依職業安全衛生法及本規則配置必要設備。", "把最低標準轉成現場檢核項目，指定改善責任人與期限。", "保存照片、會議紀錄與改善前後對照。"]), .init(title: "危險物分類速查", subtitle: "爆炸、著火、氧化、可燃氣體", icon: "flame", accent: AppTheme.resourceBlue, steps: ["確認物質是否屬爆炸性、著火性、氧化性或可燃性。", "核對標示、SDS、儲存相容性與通風條件。", "禁水、禁火、分隔與洩漏應變要先列入作業許可。"]), .init(title: "高壓氣體作業檢核", subtitle: "容器、導管、壓力與防護", icon: "gauge.with.dots.needle.50percent", accent: AppTheme.resourceBlue, steps: ["確認容器固定、壓力調整器、逆火防止與導管狀態。", "避開熱源、撞擊與不相容氣體混放。", "異常洩漏時依應變流程疏散、關斷與通報。"], isPro: true), .init(title: "承攬入場安全包", subtitle: "教育、告知、動線、許可", icon: "person.2.badge.gearshape", accent: AppTheme.resourceBlue, steps: ["入場前完成危害告知、教育訓練與作業許可。", "確認臨時用電、動火、高處與局限空間是否另需管制。", "留下簽到、照片與作業前會議紀錄。"], isPro: true)]),
        .init(title: "機械車輛", subtitle: "把設備防護變成可操作清單", tools: [.init(title: "機械防護罩檢查", subtitle: "捲夾、切割、傳動點", icon: "gearshape.2", accent: AppTheme.resourceBlue, steps: ["確認危險點有護罩、連鎖或安全距離。", "維修調整前執行停機、上鎖掛牌與殘能釋放。", "試車前清點工具、人員與防護復歸狀態。"]), .init(title: "堆高機通道檢核", subtitle: "人車分流與視線死角", icon: "fork.knife.circle", accent: AppTheme.resourceBlue, steps: ["劃設人車分道、速限、鏡面與警示標誌。", "確認載重、貨叉高度、坡道與倒車警報。", "交叉口、出入口及盲區安排指揮或警示。"], isPro: true), .init(title: "起重吊掛前檢查", subtitle: "荷重、吊具、指揮", icon: "arrow.up.and.down.and.sparkles", accent: AppTheme.resourceBlue, steps: ["確認額定荷重、吊點、吊索角度與吊具外觀。", "指定合格指揮手，作業半徑內淨空。", "禁止人員通過吊物下方，異常立即停止。"], isPro: true), .init(title: "軌道與搬運設備", subtitle: "軌道車、捲揚、手推車", icon: "tram", accent: AppTheme.resourceBlue, steps: ["檢查軌道、擋止、制動與警示裝置。", "搬運路線保持平整、照明與防滑。", "載重、速度與人員站位需明確管制。"], isPro: true)]),
        .init(title: "高處與通道", subtitle: "防墜、開口、施工動線", tools: [.init(title: "開口防墜檢核", subtitle: "護欄、蓋板、警示", icon: "square.split.bottomrightquarter", accent: AppTheme.resourceBlue, steps: ["樓板、坑洞、開口需設置固定護欄或足夠強度蓋板。", "蓋板標示用途與承載，避免任意移除。", "夜間或低照度處增加照明與警示。"]), .init(title: "施工架使用前檢查", subtitle: "踏板、拉結、上下設備", icon: "stairs", accent: AppTheme.resourceBlue, steps: ["檢查基礎、立柱、拉結、踏板與護欄。", "上下設備、踢腳板與安全網需完整。", "強風、豪雨或變更後重新檢查。"], isPro: true), .init(title: "屋頂邊緣作業", subtitle: "水平母索與防墜器具", icon: "figure.fall", accent: AppTheme.resourceBlue, steps: ["評估邊緣距離、坡度、脆弱屋面與天候。", "使用合格安全帶、母索、錨點與防墜系統。", "材料堆置避免滑落，設置下方管制區。"], isPro: true), .init(title: "安全通道與照明", subtitle: "走道、出口、緊急通行", icon: "figure.walk.motion", accent: AppTheme.resourceBlue, steps: ["保持通道淨空、乾燥、防滑與足夠照明。", "出口、消防設備與配電盤前不可堆置。", "臨時變更動線時同步更新標示。"], isPro: true)]),
        .init(title: "特殊危害", subtitle: "電氣、化學、局限與溫熱", tools: [.init(title: "臨時用電檢核", subtitle: "漏電、接地、配線保護", icon: "bolt.shield", accent: AppTheme.resourceBlue, steps: ["確認漏電斷路器、接地、線徑與防水保護。", "電線不得浸水、重壓、破皮或凌亂跨越通道。", "維修前斷電、驗電並上鎖掛牌。"], isPro: true), .init(title: "動火作業許可", subtitle: "火源隔離與監火", icon: "flame.circle", accent: AppTheme.resourceBlue, steps: ["移除或遮蔽可燃物，準備滅火器與監火人。", "確認氣瓶、軟管、逆火防止與通風。", "完工後持續巡查復燃風險。"], isPro: true), .init(title: "局限空間進入", subtitle: "通風、測定、救援", icon: "arrow.down.forward.and.arrow.up.backward", accent: AppTheme.resourceBlue, steps: ["進入前測定氧氣、可燃氣體與有害物。", "保持通風、監視人與通訊，不單獨作業。", "救援計畫與器材先到位，不以臨時下去救人取代。"], isPro: true), .init(title: "熱危害與通風", subtitle: "WBGT、補水、輪替", icon: "thermometer.sun", accent: AppTheme.resourceBlue, steps: ["評估熱指數、作業強度、衣著與曝露時間。", "安排補水、休息、遮蔭、通風與輪替。", "異常症狀立即停止作業並通報處置。"], isPro: true)]),
        .init(title: "衛生防護", subtitle: "把管理措施留成紀錄", tools: [.init(title: "個人防護具選用", subtitle: "眼耳呼吸防護與安全帽", icon: "shield.lefthalf.filled", accent: AppTheme.resourceBlue, steps: ["依危害選擇安全帽、護目、耳塞、手套、呼吸防護。", "確認尺寸、密合、有效期限與更換週期。", "PPE 不能取代工程控制，仍需先消除或隔離危害。"], isPro: true), .init(title: "噪音與振動暴露", subtitle: "量測、標示、輪替", icon: "waveform.path.ecg", accent: AppTheme.resourceBlue, steps: ["識別高噪音、高振動設備與暴露時間。", "安排工程改善、隔離、輪替與聽力防護。", "保留測定、教育訓練與健康管理紀錄。"], isPro: true), .init(title: "化學品儲存盤點", subtitle: "標示、相容、洩漏應變", icon: "testtube.2", accent: AppTheme.resourceBlue, steps: ["清點化學品、SDS、容器標示與保存期限。", "不相容物分開，防止傾倒、洩漏與混觸。", "洩漏處理器材、洗眼沖淋與通報流程要可用。"], isPro: true), .init(title: "題庫測驗", subtitle: "100題職安設施規則練習", icon: "questionmark.circle", accent: AppTheme.resourceBlue, steps: ["免費先練前 20 題。", "Pro 解鎖完整 100 題與相關圖解跳轉。", "用答題結果回到條文圖解複習。"], destination: .quiz)])
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        header
                        ForEach(sections) { section in
                            toolSection(section)
                        }
                        Spacer().frame(height: 104)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 18)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("PRO TOOLBOX")
                        .font(.system(size: 9, weight: .medium))
                        .italic()
                        .kerning(3)
                        .foregroundStyle(AppTheme.mute)
                    Text("職安設施工具")
                        .font(.system(size: 34, weight: .heavy, design: .serif))
                        .foregroundStyle(AppTheme.primary)
                }
                Spacer()
                NavigationLink { PaywallView() } label: {
                    Text("Pro / 解鎖完整圖解")
                        .font(.system(size: 13, weight: .heavy))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .background(AppTheme.primary, in: Capsule())
                }
            }
            Text("從危害辨識、機械車輛、高處通道、特殊危害到衛生防護，把職安設施要求整理成可勾選的現場工具。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.mute)
                .lineSpacing(3)
            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 4)
        }
    }

    private func toolSection(_ section: InteriorToolSection) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .firstTextBaseline) {
                Text(section.title)
                    .font(.system(size: 20, weight: .heavy))
                    .foregroundStyle(AppTheme.primary)
                Spacer()
                Text(section.subtitle)
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(AppTheme.mute)
                    .lineLimit(1)
            }

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 158), spacing: 10)], spacing: 10) {
                ForEach(section.tools) { tool in
                    toolCard(tool)
                }
            }
        }
    }

    @ViewBuilder
    private func toolCard(_ tool: InteriorTool) -> some View {
        let locked = tool.isPro && !iap.isUnlocked
        if locked {
            Button { showPaywall = true } label: {
                toolCardContent(tool, locked: true)
            }
            .buttonStyle(.plain)
        } else {
            NavigationLink {
                switch tool.destination {
                case .checklist:
                    InteriorToolDetailView(tool: tool)
                case .quiz:
                    QuizView()
                }
            } label: {
                toolCardContent(tool, locked: false)
            }
            .buttonStyle(.plain)
        }
    }

    private func toolCardContent(_ tool: InteriorTool, locked: Bool) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                Image(systemName: tool.icon)
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundStyle(tool.accent)
                    .frame(width: 38, height: 38)
                    .background(tool.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
                Spacer()
                if locked {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(AppTheme.rust)
                }
            }
            Text(tool.title)
                .font(.system(size: 16, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
                .lineLimit(1)
            Text(tool.subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(AppTheme.mute)
                .lineLimit(2)
            Spacer(minLength: 0)
        }
        .padding(13)
        .frame(maxWidth: .infinity, minHeight: 126, alignment: .topLeading)
        .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 16, style: .continuous).stroke(locked ? AppTheme.rust.opacity(0.3) : AppTheme.line, lineWidth: 1))
        .shadow(color: AppTheme.primary.opacity(0.04), radius: 6, y: 3)
    }
}

private struct InteriorToolDetailView: View {
    let tool: InteriorTool
    @State private var checked: Set<String> = []

    var body: some View {
        ZStack {
            AppTheme.paper.ignoresSafeArea()
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(spacing: 14) {
                        Image(systemName: tool.icon)
                            .font(.system(size: 28, weight: .semibold))
                            .foregroundStyle(tool.accent)
                            .frame(width: 58, height: 58)
                            .background(tool.accent.opacity(0.12), in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                        VStack(alignment: .leading, spacing: 4) {
                            Text(tool.title)
                                .font(.system(size: 28, weight: .heavy, design: .serif))
                                .foregroundStyle(AppTheme.primary)
                            Text(tool.subtitle)
                                .font(.system(size: 14, weight: .medium))
                                .foregroundStyle(AppTheme.mute)
                        }
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        ForEach(tool.steps, id: \.self) { step in
                            Button {
                                if checked.contains(step) {
                                    checked.remove(step)
                                } else {
                                    checked.insert(step)
                                }
                            } label: {
                                HStack(alignment: .top, spacing: 12) {
                                    Image(systemName: checked.contains(step) ? "checkmark.circle.fill" : "circle")
                                        .font(.system(size: 22, weight: .semibold))
                                        .foregroundStyle(checked.contains(step) ? AppTheme.leaf : AppTheme.mute)
                                    Text(step)
                                        .font(.system(size: 15, weight: .semibold))
                                        .foregroundStyle(AppTheme.primary)
                                        .multilineTextAlignment(.leading)
                                    Spacer(minLength: 0)
                                }
                                .padding(14)
                                .background(.white.opacity(0.88), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                                .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(AppTheme.line, lineWidth: 1))
                            }
                            .buttonStyle(.plain)
                        }
                    }

                    Text(Constants.legalDisclaimer)
                        .font(.system(size: 12, weight: .medium))
                        .foregroundStyle(AppTheme.mute)
                        .padding(14)
                        .background(AppTheme.kraft.opacity(0.8), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
                }
                .padding(20)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle(tool.title)
        .navigationBarTitleDisplayMode(.inline)
    }
}

private struct InteriorToolSection: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let tools: [InteriorTool]
}

private struct InteriorTool: Identifiable {
    enum Destination {
        case checklist
        case quiz
    }

    let id = UUID()
    let title: String
    let subtitle: String
    let icon: String
    let accent: Color
    let steps: [String]
    var isPro: Bool = false
    var destination: Destination = .checklist
}

struct QuizView: View {
    @EnvironmentObject private var iap: IAPManager
    @EnvironmentObject private var store: ArticleStore
    @State private var selectedQuestion = QuizQuestion.all.first!
    @State private var selectedOption: Int?
    @State private var showPaywall = false

    private var currentIndex: Int {
        QuizQuestion.all.firstIndex(of: selectedQuestion) ?? 0
    }

    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.paper.ignoresSafeArea()
                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        header
                        questionPicker
                        questionCard
                        relatedArticleSection
                        Spacer().frame(height: 104)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 54)
                }
            }
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("PRACTICE DESK")
                .font(.system(size: 9, weight: .medium))
                .italic()
                .kerning(3)
                .foregroundStyle(AppTheme.mute)
            Text("題庫測驗")
                .font(.system(size: 34, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
            Text("用職安現場情境複習設施規則重點，答題後可回到相關圖解。")
                .font(.system(size: 13, weight: .medium))
                .foregroundStyle(AppTheme.mute)
            Rectangle().fill(AppTheme.line).frame(height: 1).padding(.top, 4)
        }
    }

    private var questionPicker: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(QuizQuestion.all) { question in
                    let locked = !QuizQuestion.canAccess(question, unlocked: iap.isUnlocked)
                    Button {
                        if locked {
                            showPaywall = true
                        } else {
                            selectedQuestion = question
                            selectedOption = nil
                        }
                    } label: {
                        HStack(spacing: 5) {
                            if locked { Image(systemName: "lock.fill") }
                            Text(question.id)
                        }
                        .font(.system(size: 13, weight: .bold))
                        .foregroundStyle(selectedQuestion == question ? .white : AppTheme.primary)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(selectedQuestion == question ? AppTheme.resourceBlue : .white, in: Capsule())
                        .overlay(Capsule().stroke(AppTheme.line, lineWidth: selectedQuestion == question ? 0 : 1))
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private var questionCard: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text(selectedQuestion.topic)
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(AppTheme.resourceBlue)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(AppTheme.resourceSurface, in: Capsule())
                Spacer()
                Text("\(currentIndex + 1) / \(QuizQuestion.all.count)")
                    .font(.custom("Times New Roman", size: 15))
                    .italic()
                    .foregroundStyle(AppTheme.mute)
            }

            Text(selectedQuestion.question)
                .font(.system(size: 22, weight: .heavy))
                .foregroundStyle(AppTheme.primary)
                .lineSpacing(3)

            VStack(spacing: 10) {
                ForEach(Array(selectedQuestion.options.enumerated()), id: \.offset) { index, option in
                    answerButton(index: index, option: option)
                }
            }

            if let selectedOption {
                let isCorrect = selectedOption == selectedQuestion.correctIndex
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: isCorrect ? "checkmark.seal.fill" : "xmark.seal.fill")
                        Text(isCorrect ? "答對了" : "再檢查一次")
                    }
                    .font(.system(size: 16, weight: .heavy))
                    .foregroundStyle(isCorrect ? AppTheme.leaf : AppTheme.rust)
                    Text(selectedQuestion.explanation)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundStyle(AppTheme.mute)
                        .lineSpacing(4)
                }
                .padding(14)
                .background(AppTheme.kraft, in: RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16))
        .overlay(RoundedRectangle(cornerRadius: 16).stroke(AppTheme.line, lineWidth: 1))
    }

    private func answerButton(index: Int, option: String) -> some View {
        let isSelected = selectedOption == index
        let isCorrect = index == selectedQuestion.correctIndex
        let background: Color = {
            guard selectedOption != nil else { return AppTheme.paper }
            if isCorrect { return AppTheme.leaf.opacity(0.16) }
            if isSelected { return AppTheme.rust.opacity(0.12) }
            return AppTheme.paper
        }()

        return Button {
            selectedOption = index
        } label: {
            HStack(spacing: 10) {
                Text(String(UnicodeScalar(65 + index)!))
                    .font(.system(size: 12, weight: .heavy))
                    .foregroundStyle(.white)
                    .frame(width: 24, height: 24)
                    .background(isSelected ? AppTheme.rust : AppTheme.resourceBlue, in: Circle())
                Text(option)
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(AppTheme.primary)
                    .multilineTextAlignment(.leading)
                Spacer()
            }
            .padding(12)
            .background(background, in: RoundedRectangle(cornerRadius: 12))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppTheme.line, lineWidth: 1))
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var relatedArticleSection: some View {
        if let id = selectedQuestion.relatedArticleId,
           let article = store.article(by: id) {
            NavigationLink {
                if iap.canAccess(article: article, allArticles: store.allArticles) {
                    ArticleDetailView(article: article)
                } else {
                    PaywallView()
                }
            } label: {
                HStack(spacing: 12) {
                    Image(systemName: "doc.text.magnifyingglass")
                        .foregroundStyle(AppTheme.resourceBlue)
                    VStack(alignment: .leading, spacing: 4) {
                        Text("相關圖解")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(AppTheme.mute)
                        Text(article.title_zh)
                            .font(.system(size: 16, weight: .heavy))
                            .foregroundStyle(AppTheme.primary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right")
                        .foregroundStyle(AppTheme.mute)
                }
                .padding(14)
                .background(AppTheme.resourceSurface, in: RoundedRectangle(cornerRadius: 14))
            }
            .buttonStyle(.plain)
        }
    }
}

#Preview {
    QuizView()
        .environmentObject(IAPManager())
        .environmentObject(ArticleStore.preview)
}
