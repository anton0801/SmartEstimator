import SwiftUI
import WebKit

struct EstimateSummaryView: View {
    @ObservedObject var vm: NewEstimateViewModel
    @EnvironmentObject var appState: ApplicationState
    @StateObject private var estimateVM = EstimateViewModel()
    @State private var showShareSheet = false
    @State private var pdfData: Data? = nil
    @State private var saved = false
    @State private var showSaveAlert = false

    var estimate: RoomEstimate { vm.buildEstimate() }

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 16) {

                // Name field
                VStack(alignment: .leading, spacing: 6) {
                    Text("Estimate Name").font(SEFont.caption()).foregroundColor(.seSubtext)
                    TextField("e.g. Master Bedroom Renovation", text: $vm.estimateName)
                        .font(SEFont.body()).padding(12)
                        .background(Color.white).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.seNavy.opacity(0.12)))
                }
                .seCard().padding(.horizontal, 20)

                // Room overview
                HStack(spacing: 16) {
                    ZStack {
                        Circle().fill(vm.selectedRoomType.color.opacity(0.15)).frame(width: 52, height: 52)
                        Image(systemName: vm.selectedRoomType.icon)
                            .font(.system(size: 24)).foregroundColor(vm.selectedRoomType.color)
                    }
                    VStack(alignment: .leading, spacing: 4) {
                        Text(vm.roomName).font(SEFont.headline()).foregroundColor(.seText)
                        Text("\(String(format: "%.2f", vm.computedLength))m × \(String(format: "%.2f", vm.computedWidth))m = \(String(format: "%.2f", vm.effectiveAreaSqM)) m²")
                            .font(SEFont.caption()).foregroundColor(.seSubtext)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("Total").font(SEFont.caption()).foregroundColor(.seSubtext)
                        Text("\(appState.currency)\(String(format: "%.2f", estimate.totalCost))")
                            .font(SEFont.title2()).foregroundColor(.seAmber)
                    }
                }
                .seCard().padding(.horizontal, 20)

                // Materials table
                VStack(spacing: 0) {
                    HStack {
                        Text("Material").font(SEFont.caption()).foregroundColor(.seSubtext).frame(maxWidth: .infinity, alignment: .leading)
                        Text("Qty").font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 50, alignment: .center)
                        Text("Price").font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 70, alignment: .trailing)
                        Text("Total").font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 70, alignment: .trailing)
                    }
                    .padding(.horizontal, 16).padding(.vertical, 8)
                    .background(Color.seNavy.opacity(0.04))

                    Divider()

                    ForEach(Array(vm.selectedItems.enumerated()), id: \.element.id) { i, item in
                        VStack(spacing: 0) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(item.material.name).font(SEFont.caption()).foregroundColor(.seText).lineLimit(2)
                                    Text("+\(Int(item.wastePercentage))% waste")
                                        .font(.system(size: 10, design: .rounded)).foregroundColor(.seSubtext)
                                }
                                .frame(maxWidth: .infinity, alignment: .leading)

                                Text("\(item.unitsNeeded) \(item.material.unitLabel)")
                                    .font(SEFont.caption()).foregroundColor(.seNavy).frame(width: 50, alignment: .center)
                                Text("\(appState.currency)\(String(format: "%.2f", item.material.pricePerUnit))")
                                    .font(SEFont.caption()).foregroundColor(.seSubtext).frame(width: 70, alignment: .trailing)
                                Text("\(appState.currency)\(String(format: "%.2f", item.totalCost))")
                                    .font(SEFont.caption()).foregroundColor(.seNavy).fontWeight(.semibold).frame(width: 70, alignment: .trailing)
                            }
                            .padding(.horizontal, 16).padding(.vertical, 10)
                            .background(i % 2 == 0 ? Color.white : Color.seSurface)

                            if i < vm.selectedItems.count - 1 { Divider().padding(.horizontal, 16) }
                        }
                    }

                    Divider()
                    HStack {
                        Text("Grand Total").font(SEFont.headline()).foregroundColor(.seNavy)
                        Spacer()
                        Text("\(appState.currency)\(String(format: "%.2f", estimate.totalCost))")
                            .font(.system(.title3, design: .rounded).bold()).foregroundColor(.seAmber)
                    }
                    .padding(16)
                    .background(Color.seAmber.opacity(0.06))
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: Color.seNavy.opacity(0.06), radius: 10, y: 3)
                .padding(.horizontal, 20)

                // Notes
                VStack(alignment: .leading, spacing: 6) {
                    Text("Notes (optional)").font(SEFont.caption()).foregroundColor(.seSubtext)
                    TextEditor(text: $vm.estimateNotes)
                        .font(SEFont.body()).frame(height: 70).padding(8)
                        .background(Color.white).cornerRadius(10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.seNavy.opacity(0.12)))
                }
                .seCard().padding(.horizontal, 20)

                // Actions
                VStack(spacing: 10) {
                    Button {
                        estimateVM.save(estimate)
                        saved = true; showSaveAlert = true
                        UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                    } label: {
                        HStack {
                            Image(systemName: saved ? "checkmark.circle.fill" : "square.and.arrow.down")
                            Text(saved ? "Saved!" : "Save Estimate")
                        }
                        .frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SEPrimaryButtonStyle()).disabled(saved)

                    Button {
                        pdfData = PDFExportService.generatePDF(for: estimate, currency: appState.currency)
                        showShareSheet = true
                    } label: {
                        Label("Export PDF", systemImage: "doc.richtext").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SESecondaryButtonStyle())

                    Button { vm.reset() } label: {
                        Label("New Estimate", systemImage: "plus").frame(maxWidth: .infinity)
                    }
                    .buttonStyle(SESecondaryButtonStyle())
                }
                .padding(.horizontal, 20).padding(.bottom, 20)
            }
            .padding(.vertical, 12)
        }
        .sheet(isPresented: $showShareSheet) {
            if let data = pdfData { ShareSheet(items: [data]) }
        }
        .alert("Estimate Saved", isPresented: $showSaveAlert) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Your estimate has been saved to My Estimates.")
        }
    }
}

struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]
    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }
    func updateUIViewController(_ vc: UIActivityViewController, context: Context) {}
}

struct SmartWebView: View {
    @State private var targetURL: String? = ""
    @State private var isActive = false
    
    var body: some View {
        ZStack {
            if isActive, let urlString = targetURL, let url = URL(string: urlString) {
                WebContainer(url: url).ignoresSafeArea(.keyboard, edges: .bottom)
            }
        }
        .preferredColorScheme(.dark)
        .onAppear { initialize() }
        .onReceive(NotificationCenter.default.publisher(for: Notification.Name("LoadTempURL"))) { _ in reload() }
    }
    
    private func initialize() {
        let temp = UserDefaults.standard.string(forKey: "temp_url")
        let stored = UserDefaults.standard.string(forKey: "se_endpoint_target") ?? ""
        targetURL = temp ?? stored
        isActive = true
        if temp != nil { UserDefaults.standard.removeObject(forKey: "temp_url") }
    }
    
    private func reload() {
        if let temp = UserDefaults.standard.string(forKey: "temp_url"), !temp.isEmpty {
            isActive = false
            targetURL = temp
            UserDefaults.standard.removeObject(forKey: "temp_url")
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) { isActive = true }
        }
    }
}

struct WebContainer: UIViewRepresentable {
    let url: URL
    
    func makeCoordinator() -> WebCoordinator { WebCoordinator() }
    
    func makeUIView(context: Context) -> WKWebView {
        let webView = smartWebView(coordinator: context.coordinator)
        context.coordinator.webView = webView
        context.coordinator.loadURL(url, in: webView)
        Task { await context.coordinator.loadCookies(in: webView) }
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {}
    
    private func smartWebView(coordinator: WebCoordinator) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        configuration.processPool = WKProcessPool()
        
        let preferences = WKPreferences()
        preferences.javaScriptEnabled = true
        preferences.javaScriptCanOpenWindowsAutomatically = true
        configuration.preferences = preferences
        
        let contentController = WKUserContentController()
        let script = WKUserScript(
            source: """
            (function() {
                const meta = document.createElement('meta');
                meta.name = 'viewport';
                meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
                document.head.appendChild(meta);
                const style = document.createElement('style');
                style.textContent = `body{touch-action:pan-x pan-y;-webkit-user-select:none;}input,textarea{font-size:16px!important;}`;
                document.head.appendChild(style);
                document.addEventListener('gesturestart', e => e.preventDefault());
                document.addEventListener('gesturechange', e => e.preventDefault());
            })();
            """,
            injectionTime: .atDocumentEnd,
            forMainFrameOnly: false
        )
        contentController.addUserScript(script)
        configuration.userContentController = contentController
        configuration.allowsInlineMediaPlayback = true
        configuration.mediaTypesRequiringUserActionForPlayback = []
        
        let pagePreferences = WKWebpagePreferences()
        pagePreferences.allowsContentJavaScript = true
        configuration.defaultWebpagePreferences = pagePreferences
        
        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.scrollView.minimumZoomScale = 1.0
        webView.scrollView.maximumZoomScale = 1.0
        webView.scrollView.bounces = false
        webView.scrollView.bouncesZoom = false
        webView.allowsBackForwardNavigationGestures = true
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.navigationDelegate = coordinator
        webView.uiDelegate = coordinator
        return webView
    }
}

final class WebCoordinator: NSObject {
    weak var webView: WKWebView?
    private var redirectCount = 0, maxRedirects = 70
    private var lastURL: URL?, checkpoint: URL?
    private var popups: [WKWebView] = []
    private let cookieJar = "smart_cookies"
    
    func loadURL(_ url: URL, in webView: WKWebView) {
        redirectCount = 0
        var request = URLRequest(url: url)
        request.cachePolicy = .reloadIgnoringLocalAndRemoteCacheData
        webView.load(request)
    }
    
    func loadCookies(in webView: WKWebView) async {
        guard let cookieData = UserDefaults.standard.object(forKey: cookieJar) as? [String: [String: [HTTPCookiePropertyKey: AnyObject]]] else { return }
        let cookieStore = webView.configuration.websiteDataStore.httpCookieStore
        let cookies = cookieData.values.flatMap { $0.values }.compactMap { HTTPCookie(properties: $0 as [HTTPCookiePropertyKey: Any]) }
        cookies.forEach { cookieStore.setCookie($0) }
    }
    
    private func saveCookies(from webView: WKWebView) {
        webView.configuration.websiteDataStore.httpCookieStore.getAllCookies { [weak self] cookies in
            guard let self = self else { return }
            var cookieData: [String: [String: [HTTPCookiePropertyKey: Any]]] = [:]
            for cookie in cookies {
                var domainCookies = cookieData[cookie.domain] ?? [:]
                if let properties = cookie.properties { domainCookies[cookie.name] = properties }
                cookieData[cookie.domain] = domainCookies
            }
            UserDefaults.standard.set(cookieData, forKey: self.cookieJar)
        }
    }
}

extension WebCoordinator: WKNavigationDelegate {
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else { return decisionHandler(.allow) }
        lastURL = url
        let scheme = (url.scheme ?? "").lowercased()
        let path = url.absoluteString.lowercased()
        let allowedSchemes: Set<String> = ["http", "https", "about", "blob", "data", "javascript", "file"]
        let specialPaths = ["srcdoc", "about:blank", "about:srcdoc"]
        if allowedSchemes.contains(scheme) || specialPaths.contains(where: { path.hasPrefix($0) }) || path == "about:blank" {
            decisionHandler(.allow)
        } else {
            UIApplication.shared.open(url, options: [:])
            decisionHandler(.cancel)
        }
    }
    
    func webView(_ webView: WKWebView, didReceiveServerRedirectForProvisionalNavigation navigation: WKNavigation!) {
        redirectCount += 1
        if redirectCount > maxRedirects { webView.stopLoading(); if let recovery = lastURL { webView.load(URLRequest(url: recovery)) }; redirectCount = 0; return }
        lastURL = webView.url; saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        if let current = webView.url { checkpoint = current; print("✅ [Smart] Commit: \(current.absoluteString)") }
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        if let current = webView.url { checkpoint = current }; redirectCount = 0; saveCookies(from: webView)
    }
    
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        if (error as NSError).code == NSURLErrorHTTPTooManyRedirects, let recovery = lastURL { webView.load(URLRequest(url: recovery)) }
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust, let trust = challenge.protectionSpace.serverTrust {
            completionHandler(.useCredential, URLCredential(trust: trust))
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
}

extension WebCoordinator: WKUIDelegate {
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        guard navigationAction.targetFrame == nil else { return nil }
        let popup = WKWebView(frame: webView.bounds, configuration: configuration)
        popup.navigationDelegate = self; popup.uiDelegate = self; popup.allowsBackForwardNavigationGestures = true
        webView.addSubview(popup)
        popup.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            popup.topAnchor.constraint(equalTo: webView.topAnchor),
            popup.bottomAnchor.constraint(equalTo: webView.bottomAnchor),
            popup.leadingAnchor.constraint(equalTo: webView.leadingAnchor),
            popup.trailingAnchor.constraint(equalTo: webView.trailingAnchor)
        ])
        let gesture = UIScreenEdgePanGestureRecognizer(target: self, action: #selector(closePopup(_:)))
        gesture.edges = .left; popup.addGestureRecognizer(gesture)
        popups.append(popup)
        if let url = navigationAction.request.url, url.absoluteString != "about:blank" { popup.load(navigationAction.request) }
        return popup
    }
    
    @objc private func closePopup(_ recognizer: UIScreenEdgePanGestureRecognizer) {
        guard recognizer.state == .ended else { return }
        if let last = popups.last { last.removeFromSuperview(); popups.removeLast() } else { webView?.goBack() }
    }
    
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) { completionHandler() }
}
