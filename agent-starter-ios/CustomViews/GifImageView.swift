//
//  GifImageView.swift
//  agent-starter-ios
//
//  Created by Parth Asodariya on 12/03/26.
//

import SwiftUI
import UIKit
import WebKit

// MARK: - Helper View to load GIF using WKWebView
struct GifImageView: UIViewRepresentable {
    private let gifName: String

    init(gifName: String) {
        self.gifName = gifName
    }

    func makeUIView(context: Context) -> WKWebView {
        let webview = WKWebView()
        webview.isOpaque = false
        webview.backgroundColor = UIColor.clear
        webview.scrollView.isScrollEnabled = false
        webview.isUserInteractionEnabled = false

        if let asset = NSDataAsset(name: gifName) {
            webview.load(
                asset.data,
                mimeType: "image/gif",
                characterEncodingName: "UTF-8",
                baseURL: Bundle.main.bundleURL
            )
        } else if let url = Bundle.main.url(
            forResource: gifName,
            withExtension: "gif"
        ) {
            do {
                let data = try Data(contentsOf: url)
                webview.load(
                    data,
                    mimeType: "image/gif",
                    characterEncodingName: "UTF-8",
                    baseURL: url.deletingLastPathComponent()
                )
            } catch {
                print("Error loading gif: \(error.localizedDescription)")
            }
        } else {
            print("GIF not found in assets or bundle: \(gifName)")
        }

        return webview
    }

    func updateUIView(_ uiView: WKWebView, context: Context) { }
}
