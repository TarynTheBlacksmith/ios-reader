//
//  DesignSystem.swift
//  ResonateApp
//
//  Unified design system for consistent UI/UX
//

import SwiftUI

// MARK: - Colors

enum AppColors {
    // Primary Brand Colors (inspired by Duarte's bold presentation style)
    static let primary = Color("PrimaryBlue", fallback: Color(red: 0.0, green: 0.48, blue: 0.80))
    static let primaryDark = Color("PrimaryBlueDark", fallback: Color(red: 0.0, green: 0.38, blue: 0.65))
    static let accent = Color("AccentOrange", fallback: Color(red: 0.95, green: 0.52, blue: 0.18))

    // Narrative Role Colors (more vibrant than before)
    static let whatIs = Color(red: 0.90, green: 0.30, blue: 0.30)          // Bold red
    static let whatCouldBe = Color(red: 0.20, green: 0.70, blue: 0.40)    // Vibrant green
    static let contrast = Color(red: 0.95, green: 0.60, blue: 0.20)       // Energy orange
    static let callToAction = Color(red: 0.30, green: 0.50, blue: 0.90)   // Inspiring blue
    static let resolution = Color(red: 0.60, green: 0.40, blue: 0.85)     // Triumphant purple

    // Semantic Colors
    static let success = Color(red: 0.20, green: 0.78, blue: 0.35)
    static let warning = Color(red: 0.95, green: 0.77, blue: 0.06)
    static let error = Color(red: 0.90, green: 0.26, blue: 0.21)

    // Neutral Colors
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    static let groupedBackground = Color(UIColor.systemGroupedBackground)

    // Text Colors
    static let textPrimary = Color.primary
    static let textSecondary = Color.secondary
    static let textTertiary = Color(UIColor.tertiaryLabel)
}

// Color extension for fallback support
extension Color {
    init(_ name: String, fallback: Color) {
        if let color = UIColor(named: name) {
            self.init(uiColor: color)
        } else {
            self = fallback
        }
    }
}

// MARK: - Typography

enum AppFonts {
    // Sizes
    enum Size {
        static let largeTitle: CGFloat = 34
        static let title1: CGFloat = 28
        static let title2: CGFloat = 22
        static let title3: CGFloat = 20
        static let headline: CGFloat = 17
        static let body: CGFloat = 17
        static let callout: CGFloat = 16
        static let subheadline: CGFloat = 15
        static let footnote: CGFloat = 13
        static let caption1: CGFloat = 12
        static let caption2: CGFloat = 11
    }

    // Weights
    enum Weight {
        static let bold = Font.Weight.bold
        static let semibold = Font.Weight.semibold
        static let medium = Font.Weight.medium
        static let regular = Font.Weight.regular
        static let light = Font.Weight.light
    }

    // Predefined Styles
    static let largeTitle = Font.system(size: Size.largeTitle, weight: Weight.bold)
    static let title = Font.system(size: Size.title1, weight: Weight.bold)
    static let title2 = Font.system(size: Size.title2, weight: Weight.semibold)
    static let title3 = Font.system(size: Size.title3, weight: Weight.semibold)
    static let headline = Font.system(size: Size.headline, weight: Weight.semibold)
    static let body = Font.system(size: Size.body, weight: Weight.regular)
    static let bodyEmphasis = Font.system(size: Size.body, weight: Weight.semibold)
    static let callout = Font.system(size: Size.callout, weight: Weight.regular)
    static let subheadline = Font.system(size: Size.subheadline, weight: Weight.regular)
    static let footnote = Font.system(size: Size.footnote, weight: Weight.regular)
    static let caption = Font.system(size: Size.caption1, weight: Weight.regular)
    static let caption2 = Font.system(size: Size.caption2, weight: Weight.regular)
}

// MARK: - Spacing

enum Spacing {
    static let xxxSmall: CGFloat = 2
    static let xxSmall: CGFloat = 4
    static let xSmall: CGFloat = 8
    static let small: CGFloat = 12
    static let medium: CGFloat = 16
    static let large: CGFloat = 24
    static let xLarge: CGFloat = 32
    static let xxLarge: CGFloat = 48
    static let xxxLarge: CGFloat = 64

    // Semantic spacing
    static let cardPadding = medium
    static let sectionSpacing = large
    static let screenPadding = medium
}

// MARK: - Corner Radius

enum CornerRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xLarge: CGFloat = 24

    // Semantic radii
    static let card = medium
    static let button = small
    static let sheet = large
}

// MARK: - Shadows

enum Shadows {
    static func card(elevation: CGFloat = 1) -> some View {
        EmptyView().shadow(
            color: .black.opacity(0.08 * elevation),
            radius: 8 * elevation,
            x: 0,
            y: 4 * elevation
        )
    }

    static func button(isPressed: Bool = false) -> some View {
        EmptyView().shadow(
            color: .black.opacity(isPressed ? 0.15 : 0.1),
            radius: isPressed ? 4 : 8,
            x: 0,
            y: isPressed ? 2 : 4
        )
    }
}

// MARK: - View Modifiers

struct CardStyle: ViewModifier {
    var elevation: CGFloat = 1

    func body(content: Content) -> some View {
        content
            .background(AppColors.background)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.card))
            .shadow(
                color: .black.opacity(0.08 * elevation),
                radius: 8 * elevation,
                x: 0,
                y: 4 * elevation
            )
    }
}

struct PrimaryButtonStyle: ButtonStyle {
    var isDestructive: Bool = false

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.bodyEmphasis)
            .foregroundStyle(.white)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(isDestructive ? AppColors.error : AppColors.primary)
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .shadow(
                color: (isDestructive ? AppColors.error : AppColors.primary).opacity(0.3),
                radius: configuration.isPressed ? 4 : 8,
                x: 0,
                y: configuration.isPressed ? 2 : 4
            )
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(AppFonts.body)
            .foregroundStyle(AppColors.primary)
            .padding(.horizontal, Spacing.medium)
            .padding(.vertical, Spacing.small)
            .background(AppColors.primary.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: CornerRadius.button))
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: configuration.isPressed)
    }
}

// MARK: - View Extensions

extension View {
    func cardStyle(elevation: CGFloat = 1) -> some View {
        modifier(CardStyle(elevation: elevation))
    }

    func primaryButtonStyle(isDestructive: Bool = false) -> some View {
        buttonStyle(PrimaryButtonStyle(isDestructive: isDestructive))
    }

    func secondaryButtonStyle() -> some View {
        buttonStyle(SecondaryButtonStyle())
    }
}

// MARK: - Animations

enum AppAnimations {
    static let spring = Animation.spring(response: 0.4, dampingFraction: 0.75)
    static let quick = Animation.easeInOut(duration: 0.2)
    static let standard = Animation.easeInOut(duration: 0.3)
    static let slow = Animation.easeInOut(duration: 0.5)
}

// MARK: - Layout Constants

enum Layout {
    static let maxCardWidth: CGFloat = 400
    static let minCardWidth: CGFloat = 300
    static let sidebarWidth: CGFloat = 320
    static let sidebarMinWidth: CGFloat = 280
    static let sidebarMaxWidth: CGFloat = 400

    // Grid
    static let gridSpacing: CGFloat = Spacing.large
    static let gridColumns = [
        GridItem(.adaptive(minimum: minCardWidth, maximum: maxCardWidth), spacing: gridSpacing)
    ]
}

// MARK: - Shape Extensions

struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(
            roundedRect: rect,
            byRoundingCorners: corners,
            cornerRadii: CGSize(width: radius, height: radius)
        )
        return Path(path.cgPath)
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}
