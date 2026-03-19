//
//  TranscriptListView.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 13/03/26.
//

import SwiftUI

// MARK: - Transcript List
struct TranscriptListView: View {

    @Binding var listOfTranscriptions: [TranscriptItem]
    @Binding var maxHeight: Double

    var body: some View {
        ScrollViewReader { proxy in
            VStack {
                ScrollView {
                    ZStack(alignment: .top) {
                        VStack(spacing: 0) {

                            Rectangle()
                                .fill(AppColors.white.opacity(0.05))
                                .frame(height: Responsive.height(40))
                                .blur(radius: 20)

                            ForEach(0..<listOfTranscriptions.count, id: \.self)
                            { index in
                                listOfTranscriptions[index]
                                    .id(index)
                            }
                        }

                        Rectangle()
                            .fill(AppColors.black.opacity(0.8))
                            .frame(height: Responsive.height(40))
                            .blur(radius: Responsive.height(30))
                    }
                }
            }
            .onChange(of: listOfTranscriptions.count) { _ in
                if !listOfTranscriptions.isEmpty {
                    withAnimation {
                        proxy.scrollTo(
                            listOfTranscriptions.count - 1,
                            anchor: .bottom
                        )
                    }
                }
            }
            .onAppear {
                if !listOfTranscriptions.isEmpty {
                    proxy.scrollTo(
                        listOfTranscriptions.count - 1,
                        anchor: .bottom
                    )
                }
            }
        }
        .frame(maxHeight: maxHeight)
    }
}

#Preview {
    ZStack(alignment: .bottom) {
        AppColors.neutral950.edgesIgnoringSafeArea(.all)

        TranscriptListView(
            listOfTranscriptions: .constant(
                [
                    TranscriptItem(
                        peerName: "Lila Chen",
                        message:
                            "Hello There, How are you doing? Am I disturbing you ?"
                    ),
                    TranscriptItem(
                        peerName: "Arjun Kava",
                        message: "Hii There, How are you?"
                    ),
                ]
            ),
            maxHeight: .constant(Responsive.height(170))
        )

    }
}
