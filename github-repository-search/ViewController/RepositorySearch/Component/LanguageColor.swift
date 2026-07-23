//
//  LanguageColor.swift
//  github-repository-search
//
//  Created by Issei Ueda on 2026/07/16.
//

import UIKit

/// 主要言語ごとの色分け（GitHubの言語カラーに準拠した簡易マッピング）。
enum LanguageColor {
    static func color(for language: String) -> UIColor {
        colors[language] ?? .systemGray3
    }

    private static let colors: [String: UIColor] = [
        "Swift": color(hex: 0xF05138),
        "Python": color(hex: 0x3572A5),
        "JavaScript": color(hex: 0xF1E05A),
        "TypeScript": color(hex: 0x3178C6),
        "C++": color(hex: 0xF34B7D),
        "C": color(hex: 0x555555),
        "Ruby": color(hex: 0x701516),
        "Go": color(hex: 0x00ADD8),
        "Java": color(hex: 0xB07219),
        "Jupyter Notebook": color(hex: 0xDA5B0B),
        "HTML": color(hex: 0xE34C26),
        "Shell": color(hex: 0x89E051),
        "Rust": color(hex: 0xDEA584),
        "Kotlin": color(hex: 0xA97BFF),
        "PHP": color(hex: 0x4F5D95),
    ]

    private static func color(hex: UInt32) -> UIColor {
        UIColor(
            red: CGFloat((hex >> 16) & 0xFF) / 255,
            green: CGFloat((hex >> 8) & 0xFF) / 255,
            blue: CGFloat(hex & 0xFF) / 255,
            alpha: 1
        )
    }
}
