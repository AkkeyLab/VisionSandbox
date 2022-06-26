//
//  ContentView.swift
//  VisionSandbox
//
//  Created by AkkeyLab on 2022/06/25.
//

import SwiftUI
import VisionKit

struct ContentView: View {
    var body: some View {
        ReceiptAnalyzeView()
    }
}

struct ContentViewPreviews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

private final class ReceiptAnalyzeViewController: UIViewController {
    private enum ImageType: Int, CaseIterable {
        case receipt
        case human

        var image: UIImage? {
            switch self {
            case .receipt:
                return UIImage(named: "receipt")
            case .human:
                return UIImage(named: "craig_federighi")
            }
        }

        var title: String {
            switch self {
            case .receipt:
                return "Receipt"
            case .human:
                return "Human"
            }
        }
    }

    private let segmentedControl = UISegmentedControl(items: ImageType.allCases.map(\.title))
    private let imageView = UIImageView()
    private let analyzer = ImageAnalyzer()
    private let interaction = ImageAnalysisInteraction()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(imageView)
        view.addSubview(segmentedControl)

        imageView.contentMode = .scaleAspectFit
        imageView.addInteraction(interaction)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        imageView.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true

        segmentedControl.addTarget(self, action: #selector(didChangeSegmentedValue), for: .valueChanged)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        segmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }

    @objc func didChangeSegmentedValue() {
        guard let imageType = ImageType(rawValue: segmentedControl.selectedSegmentIndex) else {
            return
        }
        imageView.image = imageType.image
        interaction.preferredInteractionTypes = []
        interaction.analysis = nil

        let image = imageType.image
        if let image {
            Task {
                let config = ImageAnalyzer.Configuration([.text])
                let analysis = try? await analyzer.analyze(image, configuration: config)
                if let analysis {
                    showAlert(hasText: analysis.hasResults(for: .text))
                    interaction.analysis = analysis
                    interaction.preferredInteractionTypes = .textSelection
                }
            }
        }
    }

    private func showAlert(hasText: Bool) {
        let viewController = UIAlertController(
            title: hasText ? "Good job!🎉" : "Try again!🙇‍♀️",
            message: hasText ? "The text was detected :)" : "No text were found :(",
            preferredStyle: .alert
        )
        viewController.addAction(UIAlertAction(title: "OK", style: .default))
        present(viewController, animated: true)
    }
}

private struct ReceiptAnalyzeView: UIViewControllerRepresentable {
    typealias UIViewControllerType = ReceiptAnalyzeViewController

    func makeUIViewController(context: Context) -> ReceiptAnalyzeViewController {
        .init()
    }

    func updateUIViewController(_ uiViewController: ReceiptAnalyzeViewController, context: Context) {
    }
}
