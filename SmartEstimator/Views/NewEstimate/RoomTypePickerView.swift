import SwiftUI

struct RoomTypePickerView: View {
    @ObservedObject var vm: NewEstimateViewModel
    let columns = [GridItem(.flexible()), GridItem(.flexible())]

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {
                LazyVGrid(columns: columns, spacing: 14) {
                    ForEach(Array(RoomType.allCases.enumerated()), id: \.element) { i, rt in
                        RoomTypeCard(
                            roomType: rt,
                            isSelected: vm.selectedRoomType == rt,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.65)) {
                                    vm.selectedRoomType = rt
                                }
                            }
                        )
                        .staggerAppear(index: i)
                    }
                }
                .padding(.horizontal, 20)

                if vm.selectedRoomType == .custom {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Room Name")
                            .font(SEFont.caption())
                            .foregroundColor(.seSubtext)
                        TextField("e.g. Storage Room", text: $vm.customRoomName)
                            .font(SEFont.body())
                            .padding(12)
                            .background(Color.white)
                            .cornerRadius(10)
                            .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.seNavy.opacity(0.15)))
                    }
                    .padding(.horizontal, 20)
                    .transition(.scale.combined(with: .opacity))
                }

                Button { vm.goNext() } label: {
                    Label("Continue", systemImage: "arrow.right")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(SEPrimaryButtonStyle())
                .padding(.horizontal, 20)
                .disabled(vm.selectedRoomType == .custom && vm.customRoomName.trimmingCharacters(in: .whitespaces).isEmpty)
            }
            .padding(.vertical, 12)
        }
    }
}

struct RoomTypeCard: View {
    let roomType: RoomType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 10) {
                ZStack {
                    Circle()
                        .fill(isSelected ? roomType.color : roomType.color.opacity(0.12))
                        .frame(width: 52, height: 52)
                    Image(systemName: roomType.icon)
                        .font(.system(size: 24))
                        .foregroundColor(isSelected ? .white : roomType.color)
                }
                Text(roomType.rawValue)
                    .font(SEFont.subheadline())
                    .foregroundColor(isSelected ? roomType.color : .seText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .padding(16)
            .frame(maxWidth: .infinity)
            .background(isSelected ? roomType.color.opacity(0.08) : Color.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? roomType.color : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? roomType.color.opacity(0.2) : Color.seNavy.opacity(0.05),
                    radius: isSelected ? 8 : 4, y: 2)
            .scaleEffect(isSelected ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}
