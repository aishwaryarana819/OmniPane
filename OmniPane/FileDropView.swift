//
//  FileDropView.swift
//  OmniPane
//
//  Created by Aishwarya Rana on 08/04/26.
//

import SwiftUI
import QuickLook
import UniformTypeIdentifiers

struct FileDropView: View {
    @State private var files: [URL] = []
    @State private var quickLookURL: URL? = nil
    
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ReorderButtons(onMoveUp: onMoveUp, onMoveDown: onMoveDown, isFirst: isFirst, isLast: isLast)
                Text("File Drop").font(.title3).foregroundColor(.white.opacity(0.8))
            }
            .padding(.horizontal).padding(.top, 10)
    
            if files.isEmpty {
                Text("Drag & Drop files to/from here.")
                    .foregroundColor(.white.opacity(0.2))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .frame(height: 125)
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 15) {
                        ForEach(files, id: \.self) { url in
                            FileItemView(url: url) {
                                files.removeAll { $0 == url }
                            } onDoubleTap: {
                                quickLookURL = url
                            }
                        }
                    }
                    .padding()
                }
                .frame(height: 100)
            }
        }
        .padding(.bottom, 15)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2), lineWidth: 0.5))
        .padding(.horizontal, 20)
        .onDrop(of: [.fileURL], isTargeted: nil) { providers in
            for provider in providers {
                provider.loadDataRepresentation(for: .fileURL) { data, _ in
                    if let data = data, let url = URL(dataRepresentation: data, relativeTo: nil) {
                        DispatchQueue.main.async {
                            if !files.contains(url) {
                                withAnimation(.spring()) { files.append(url) }
                            }
                        }
                    }
                }
            }
            return true
        }
        .quickLookPreview($quickLookURL)
    }
}

// fetching the icon on a background thread so the main UI
// doesn't stutter when you drop in a bunch of files
struct FileItemView: View {
    let url: URL
    let onDelete: () -> Void
    let onDoubleTap: () -> Void
    
    // Default fallback icon
    @State private var fileIcon = NSImage(systemSymbolName: "doc", accessibilityDescription: nil) ?? NSImage()

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                Image(nsImage: fileIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 45, height: 45)
                
                Text(url.lastPathComponent)
                    .font(.caption2).foregroundColor(.white)
                    .lineLimit(1).frame(width: 65)
            }
            .padding(8)
            .background(Color.white.opacity(0.8))
            .cornerRadius(10)
            .onTapGesture(count: 2) { onDoubleTap() }
            .onDrag { NSItemProvider(object: url as NSURL) }
            .onAppear {
                DispatchQueue.global(qos: .background).async {
                    let icon = NSWorkspace.shared.icon(forFile: url.path)
                    DispatchQueue.main.async {
                        self.fileIcon = icon
                    }
                }
            }
            
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundColor(.red.opacity(0.8))
                    .background(Circle().fill(Color.black))
            }
            .buttonStyle(PlainButtonStyle())
            .offset(x: 5, y: -5)
        }
    }
}
