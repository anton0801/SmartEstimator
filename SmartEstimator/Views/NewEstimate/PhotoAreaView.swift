import SwiftUI
import UIKit

struct PhotoAreaMarkingView: View {
    @ObservedObject var vm: NewEstimateViewModel
    @Binding var isPresented: Bool

    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()

                if let img = vm.capturedImage {
                    GeometryReader { geo in
                        ZStack {
                            Image(uiImage: img)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: .infinity)
                                .onAppear { vm.imageViewSize = geo.size }

                            if vm.cornerPoints.count > 1 {
                                Path { p in
                                    p.move(to: vm.cornerPoints[0])
                                    for pt in vm.cornerPoints.dropFirst() { p.addLine(to: pt) }
                                    if vm.cornerPoints.count == 4 { p.closeSubpath() }
                                }
                                .stroke(Color.seAmber, lineWidth: 2)
                            }

                            ForEach(Array(vm.cornerPoints.enumerated()), id: \.offset) { i, pt in
                                ZStack {
                                    Circle().fill(Color.seAmber).frame(width: 16, height: 16)
                                    Text("\(i+1)").font(.system(size: 9, weight: .bold)).foregroundColor(.white)
                                }
                                .position(pt)
                            }

                            Color.clear.contentShape(Rectangle())
                                .onTapGesture { loc in
                                    if vm.cornerPoints.count < 4 {
                                        withAnimation(.spring(response: 0.2)) {
                                            vm.cornerPoints.append(loc)
                                        }
                                        if vm.cornerPoints.count == 4 {
                                            vm.calculatePhotoArea()
                                        }
                                    }
                                }
                        }
                    }
                }
            }
            .overlay(alignment: .bottom) {
                VStack(spacing: 12) {
                    HStack {
                        Image(systemName: "info.circle").foregroundColor(.seAmber)
                        Text(vm.cornerPoints.count < 4
                            ? "Tap \(4 - vm.cornerPoints.count) more corner\(4 - vm.cornerPoints.count == 1 ? "" : "s")"
                            : "Area: \(String(format: "%.2f", vm.photoAreaSqM)) m²  ✓")
                        .font(SEFont.subheadline())
                        .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20).padding(.vertical, 10)
                    .background(Color.black.opacity(0.7))
                    .cornerRadius(20)

                    HStack(spacing: 12) {
                        Button { vm.cornerPoints = [] } label: {
                            Label("Reset", systemImage: "arrow.counterclockwise").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SESecondaryButtonStyle())

                        Button { isPresented = false } label: {
                            Label("Done", systemImage: "checkmark").frame(maxWidth: .infinity)
                        }
                        .buttonStyle(SEPrimaryButtonStyle())
                        .disabled(vm.cornerPoints.count < 4)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 24)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { isPresented = false }.foregroundColor(.white)
                }
                ToolbarItem(placement: .principal) {
                    Text("Mark Surface Corners").font(SEFont.headline()).foregroundColor(.white)
                }
            }
        }
    }
}

// MARK: - UIImagePickerController wrapper
struct ImagePickerView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    let sourceType: UIImagePickerController.SourceType
    @Environment(\.presentationMode) var presentationMode

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: ImagePickerView
        init(_ p: ImagePickerView) { parent = p }

        func imagePickerController(_ picker: UIImagePickerController,
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            parent.image = info[.originalImage] as? UIImage
            parent.presentationMode.wrappedValue.dismiss()
        }
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.presentationMode.wrappedValue.dismiss()
        }
    }
}
