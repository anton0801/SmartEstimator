import SwiftUI

struct AreaInputView: View {
    @ObservedObject var vm: NewEstimateViewModel
    @State private var showImagePicker = false
    @State private var imageSource: UIImagePickerController.SourceType = .camera
    @State private var showPhotoArea = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {

                // Photo input card
                VStack(spacing: 12) {
                    Text("Photo Input")
                        .font(SEFont.headline())
                        .foregroundColor(.seText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        PhotoSourceButton(icon: "camera.fill", label: "Take Photo") {
                            imageSource = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
                            showImagePicker = true
                        }
                        PhotoSourceButton(icon: "photo.on.rectangle", label: "From Library") {
                            imageSource = .photoLibrary
                            showImagePicker = true
                        }
                    }

                    if let image = vm.capturedImage {
                        Button { withAnimation { showPhotoArea = true } } label: {
                            HStack {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 60, height: 60)
                                    .cornerRadius(8)
                                    .clipped()
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Photo loaded — tap to mark area")
                                        .font(SEFont.subheadline())
                                        .foregroundColor(.seNavy)
                                    if vm.photoAreaSqM > 0 {
                                        Text("Area: \(String(format: "%.2f", vm.photoAreaSqM)) m²")
                                            .font(SEFont.caption())
                                            .foregroundColor(.seSuccess)
                                    }
                                }
                                Spacer()
                                Image(systemName: "chevron.right").foregroundColor(.seSubtext)
                            }
                        }
                        .buttonStyle(.plain)
                        .seCard()
                    }
                }
                .seCard()
                .padding(.horizontal, 20)

                HStack {
                    Rectangle().fill(Color.seNavy.opacity(0.12)).frame(height: 1)
                    Text("OR").font(SEFont.caption()).foregroundColor(.seSubtext).padding(.horizontal, 8)
                    Rectangle().fill(Color.seNavy.opacity(0.12)).frame(height: 1)
                }
                .padding(.horizontal, 20)

                // Manual input card
                VStack(spacing: 16) {
                    Text("Manual Dimensions")
                        .font(SEFont.headline())
                        .foregroundColor(.seText)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    HStack(spacing: 12) {
                        DimensionField(label: "Length (m)", value: $vm.length, icon: "arrow.left.and.right")
                        DimensionField(label: "Width (m)",  value: $vm.width,  icon: "arrow.up.and.down")
                    }
                    DimensionField(label: "Height (m) — for wall area", value: $vm.height, icon: "arrow.up")

                    if vm.computedLength > 0 && vm.computedWidth > 0 {
                        HStack {
                            Image(systemName: "square.dashed").foregroundColor(.seAmber)
                            Text("Floor Area: \(String(format: "%.2f", vm.effectiveAreaSqM)) m²")
                                .font(SEFont.headline()).foregroundColor(.seNavy)
                            Spacer()
                            Text("Wall Area: \(String(format: "%.2f", vm.wallAreaSqM)) m²")
                                .font(SEFont.caption()).foregroundColor(.seSubtext)
                        }
                        .padding(12)
                        .background(Color.seAmber.opacity(0.08))
                        .cornerRadius(10)
                        .transition(.scale.combined(with: .opacity))
                    }
                }
                .seCard()
                .padding(.horizontal, 20)

                Button {
                    vm.usePhotoArea = vm.photoAreaSqM > 0
                    vm.goNext()
                } label: {
                    Label("Continue to Materials", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SEPrimaryButtonStyle())
                .padding(.horizontal, 20)
                .disabled(!vm.isAreaValid)
            }
            .padding(.vertical, 12)
        }
        .sheet(isPresented: $showImagePicker) {
            ImagePickerView(image: $vm.capturedImage, sourceType: imageSource)
        }
        .sheet(isPresented: $showPhotoArea) {
            PhotoAreaMarkingView(vm: vm, isPresented: $showPhotoArea)
        }
    }
}

struct PhotoSourceButton: View {
    let icon: String
    let label: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon).font(.system(size: 24)).foregroundColor(.seNavy)
                Text(label).font(SEFont.caption()).foregroundColor(.seNavy)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(Color.seNavy.opacity(0.06))
            .cornerRadius(12)
        }
        .buttonStyle(ScaleButtonStyle())
    }
}

struct DimensionField: View {
    let label: String
    @Binding var value: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Label(label, systemImage: icon).font(SEFont.caption()).foregroundColor(.seSubtext)
            TextField("0.00", text: $value)
                .keyboardType(.decimalPad)
                .font(SEFont.body())
                .padding(10)
                .background(Color.seSurface)
                .cornerRadius(10)
                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.seNavy.opacity(0.12)))
        }
        .frame(maxWidth: .infinity)
    }
}
