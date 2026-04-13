//
//  ScratchNotesView.swift
//  OmniPane
//
//  Created by Aishwarya Rana on 09/04/26.
//

import SwiftUI

struct ScratchNote: Identifiable {
    var id = UUID()
    var text: String
}

struct ScratchNotesView: View {
    @State private var notes: [ScratchNote] = []
    @State private var editingNoteID: UUID? = nil
    @State private var draftText: String = ""
    
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    let isFirst: Bool
    let isLast: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                if editingNoteID != nil {
                    // adding a visible save button, cmd+enter and esc shortcut.
                    // helps clarify when a note is "done" and can be easyly contoled
                    Button(action: { editingNoteID = nil }) {
                        Image(systemName: "chevron.left").foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                    .keyboardShortcut(.escape, modifiers: [])
                } else {
                    ReorderButtons(onMoveUp: onMoveUp, onMoveDown: onMoveDown, isFirst: isFirst, isLast: isLast)
                }
                
                Text("Scratch Notes").font(.title3).foregroundColor(.white.opacity(0.8))
                Spacer()
                
                if editingNoteID != nil {
                    Button(action: saveNote) {
                        Text("Save").font(.caption.bold())
                            .padding(.horizontal, 10).padding(.vertical, 5)
                            .background(Color.white.opacity(0.15)).cornerRadius(6).foregroundColor(.white)
                    }
                    .buttonStyle(PlainButtonStyle())
                    .keyboardShortcut(.return, modifiers: [.command])
                } else {
                    Button(action: {
                        draftText = ""
                        editingNoteID = UUID()
                    }) {
                        Image(systemName: "plus").foregroundColor(.white.opacity(0.8))
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .padding(.horizontal).padding(.top, 10)
            .padding(.bottom, editingNoteID == nil ? 10 : 0)
            
            if editingNoteID != nil {
                ZStack(alignment: .topLeading) {
                    if draftText.isEmpty {
                        Text("Click ⌘ + Enter to save")
                            .font(.body.weight(.light))
                            .foregroundColor(.white.opacity(0.2))
                            .padding(.top, 10)
                            .padding(.horizontal, 15)
                            .allowsHitTesting(false)
                    }
                    
                    TextEditor(text: $draftText)
                        .scrollContentBackground(.hidden)
                        .font(.body.weight(.light))
                        .foregroundColor(.white.opacity(0.9))
                        .background(Color.clear)
                        .padding(.top, 10).padding(.bottom, 15).padding(.horizontal, 10)
                        .frame(minHeight: 150)
                }
            } else {
                if notes.isEmpty {
                    Text("Hit + to scratch")
                        .foregroundColor(.white.opacity(0.2))
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                        .frame(height: 125)
                } else {
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 15) {
                            ForEach(notes) { note in
                                ScratchCardView(
                                    note: note,
                                    onEdit: {
                                        draftText = note.text
                                        editingNoteID = note.id
                                    },
                                    onDelete: { notes.removeAll { $0.id == note.id } }
                                )
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 125)
                }
            }
        }
        .padding(.bottom, 15)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 15))
        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.white.opacity(0.2), lineWidth: 0.5))
        .padding(.horizontal, 20)
        .animation(.easeInOut(duration: 0.2), value: editingNoteID)
    }
    
    private func saveNote() {
        guard let id = editingNoteID else { return }
        let trimmed = draftText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            notes.removeAll { $0.id == id }
        } else {
            if let index = notes.firstIndex(where: { $0.id == id }) {
                notes[index].text = draftText
            } else {
                notes.insert(ScratchNote(id: id, text: draftText), at: 0)
            }
        }
        editingNoteID = nil
    }
}

struct ScratchCardView: View {
    let note: ScratchNote
    let onEdit: () -> Void
    let onDelete: () -> Void
    @State private var isHovering = false
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Text(note.text.isEmpty ? "..." : note.text)
                .font(.caption).foregroundColor(.white.opacity(note.text.isEmpty ? 0.3 : 0.7))
                .lineLimit(4).padding(12).frame(width: 150, height: 125, alignment: .topLeading)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 10))
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.white.opacity(0.2), lineWidth: 0.5))
            
            if isHovering {
                Color.black.opacity(0.5).cornerRadius(10)
                HStack(spacing: 15) {
                    Button(action: onEdit) { Image(systemName: "pencil").foregroundColor(.white) }
                    .buttonStyle(PlainButtonStyle())
                    Button(action: onDelete) { Image(systemName: "trash").foregroundColor(.red.opacity(0.9)) }
                    .buttonStyle(PlainButtonStyle())
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
        }
        .frame(width: 150, height: 125)
        .onHover { hovering in isHovering = hovering }
        .onTapGesture { onEdit() }
    }
}
