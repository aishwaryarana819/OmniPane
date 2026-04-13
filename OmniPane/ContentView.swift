//
//  ContentView.swift
//  OmniPane
//
//  Created by Aishwarya Rana on 08/04/26.
//

import SwiftUI
import UniformTypeIdentifiers

enum AppUtility: String, CaseIterable, Identifiable {
    case fileDrop = "File Drop"
    case scratchNotes = "Scratch Notes"
    var id: String { self.rawValue }
}

struct ContentView: View {
    @AppStorage("showFileDrop") private var showFileDrop = true
    @AppStorage("showScratchNotes") private var showScratchNotes = true
    @AppStorage("moduleOrder") private var orderString = "fileDrop,scratchNotes"

    @State private var activeOrder: [AppUtility] = []

    var body: some View {
        ZStack {
            Color.clear
                .background(.ultraThinMaterial)
                .ignoresSafeArea()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(spacing: 20) {
                    // Decided to go with physical reorder buttons here.
                    // In my experience building Sigil, I've found that drag-and-drops in general
                    // can be really finicky with mouse-tracking, so these feel
                    // much more fluid.
                    ForEach(activeOrder, id: \.self) { utility in
                        let index = activeOrder.firstIndex(of: utility) ?? 0
                        let isFirst = index == 0
                        let isLast = index == activeOrder.count - 1
                        
                        if utility == .fileDrop && showFileDrop {
                            FileDropView(
                                onMoveUp: { moveUp(index) },
                                onMoveDown: { moveDown(index) },
                                isFirst: isFirst,
                                isLast: isLast
                            )
                            .padding(.top, 5)
                        } else if utility == .scratchNotes && showScratchNotes {
                            ScratchNotesView(
                                onMoveUp: { moveUp(index) },
                                onMoveDown: { moveDown(index) },
                                isFirst: isFirst,
                                isLast: isLast
                            )
                            .padding(.top, 5)
                        }
                    }
                }
                .padding(.top, 5)
                .padding(.bottom, 20)
            }
        }
        .frame(minWidth: 300, maxWidth: 700, minHeight: 400)
        .onAppear { loadOrder() }
        .onChange(of: activeOrder) { _ in saveOrder() }
    }
    
    private func moveUp(_ index: Int) {
        guard index > 0 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeOrder.swapAt(index, index - 1)
        }
    }
    
    private func moveDown(_ index: Int) {
        guard index < activeOrder.count - 1 else { return }
        withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
            activeOrder.swapAt(index, index + 1)
        }
    }
    
    private func loadOrder() {
        let saved = orderString.components(separatedBy: ",")
        activeOrder = saved.compactMap { AppUtility(rawValue: $0) }
        
        for utility in AppUtility.allCases {
            if !activeOrder.contains(utility) {
                activeOrder.append(utility)
            }
        }
    }
    
    private func saveOrder() {
        orderString = activeOrder.map { $0.rawValue }.joined(separator: ",")
    }
}

struct ReorderButtons: View {
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        HStack(spacing: 8) {
            Button(action: onMoveUp) {
                Image(systemName: "chevron.up")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isFirst ? .white.opacity(0.2) : .white.opacity(0.8))
            }
            .disabled(isFirst)
            .buttonStyle(PlainButtonStyle())
            
            Button(action: onMoveDown) {
                Image(systemName: "chevron.down")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isLast ? .white.opacity(0.2) : .white.opacity(0.8))
            }
            .disabled(isLast)
            .buttonStyle(PlainButtonStyle())
        }
        .padding(.trailing, 5)
        .padding(.leading, 5)
    }
}
