//
//  DetailYoutubeViewController.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/01/21.
//
import UIKit
import YoutubePlayer_in_WKWebView
import GoogleMobileAds

class DetailYoutubeViewController: UIViewController {
    
    private let headerID = "headerID"
    // MARK: - Params
    private var channelVideoList: [Video] = []
    
    private let adShowTerm = Resource.AdMob.adShowTerm
    private var playVarDic = ["playsinline": 1] // 처음에 전체화면 안되게하기
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // 현재 재생하는 비디오.
    var video: Video? {
        didSet {
            guard let video = self.video else { return }
            self.customYTPlayer.load(withVideoId: video.vid, playerVars: self.playVarDic)
            updateViews(vid: video.vid) // 조회수 늘리기
            getRelatedItems(vid: video.vid)
        }
    }
    
    private func updateViews(vid: String) {
        NetworkManager.getVideoViewsUpdate(vid: vid) { (result) in
            switch result {
            case .success(let data):
                print(data, "Views UPDATE SUCCESS")
            case .failure(let error):
                print(error)
            }
        }
    }
    
    var relatedItems = [RelatedVideoItem]()
    
    private func getRelatedItems(vid: String) {
        NetworkManager.getRelatedItems(vid: vid) { [weak self] (result) in
            switch result {
            case .success(let data):
                print(data)
                guard let itemData = data.data else {return}
                self?.relatedItems = itemData
                DispatchQueue.main.async {
                    self?.relatedCollectionView.reloadData()
                }
                
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func calculateTextSize(text: String) -> CGFloat {
        let desiredWith = view.frame.width - 32

        let dummyLabel = UILabel()
        dummyLabel.text = text + " " // 이모티콘 등을 대비한 한칸 여유
        dummyLabel.numberOfLines = 2

        guard let font = UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 15) else {return 0}
        let boundingRect = dummyLabel.text?.boundingRect(with: .zero, options: [.usesFontLeading],
                                                         attributes: [.font: font, .kern: -0.3], context: nil)
        let line = Int(ceil((boundingRect!.width / desiredWith)))
        var totalSize: CGFloat = 0
        if line == 1 {
            totalSize += 15 + 37
            totalSize += 20 // text Size
        } else {
            totalSize += 17 + 33
            totalSize += 40 // text Size
        }
        
        return totalSize
        
    }
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        return navBar
    }()

    private lazy var customYTPlayer = WKYTPlayerView()

    private lazy var relatedCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = .clear
        collectionview.showsVerticalScrollIndicator = false
        collectionview.alwaysBounceVertical = true
        return collectionview
    }()

    // MARK: - Init
    override func viewDidLoad() {
        super.viewDidLoad()
        configure()
        setupLayout()

    }
    
    override func willMove(toParent parent: UIViewController?) {
        super.willMove(toParent: parent)
        if parent == nil { // HomeVC로 돌아갈때만 인터스티셜 재생
            AdiscopeManager.shared.showInterStitial()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    private func configure() {
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil
        
        let cells = [DetailRelatedProductCell.self]
        cells.forEach { (cell) in
            relatedCollectionView.register(cell.self, forCellWithReuseIdentifier: cell.description())
        }
        
        relatedCollectionView.register(DetailYoutubeHeader.self,
                                    forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader,
                                    withReuseIdentifier: headerID)
        customYTPlayer.delegate = self
    }
    
    private func setupLayout() {
        view.backgroundColor = UIColor(named: "elavated")
        let width = view.frame.width
        
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        view.addSubview(customYTPlayer)
        customYTPlayer.snp.makeConstraints {
            $0.top.equalTo(customNavigationBar.snp.bottom)
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(width * 9/16)
        }

        view.addSubview(relatedCollectionView)
        relatedCollectionView.snp.makeConstraints { (make) in
            make.top.equalTo(customYTPlayer.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    // MARK: - 함수들
    private func getDateString(str: String) -> String {
        let yyyyMMdd = str.split(separator: "T")[0]
        let piece = yyyyMMdd.split(separator: "-")
        let strIdx = piece[0].index(piece[0].startIndex, offsetBy: 2)
        return "\(piece[0][strIdx...]).\(piece[1]).\(piece[2])"
    }
    private func getViewsString(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = "조회수 \(numberFormatter.string(from: NSNumber(value: value))!)회"
        return result
    }
    @objc func goChannelHome() {
        let nextVC = SearchViewController()
        nextVC.isChannelHome = true
        nextVC.cid = video?.cid
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
extension DetailYoutubeViewController: WKYTPlayerViewDelegate {
    func playerViewDidBecomeReady(_ playerView: WKYTPlayerView) {
        playerView.playVideo() // 처음에 자동으로 재생하기
    }
    func playerView(_ playerView: WKYTPlayerView, didChangeTo state: WKYTPlayerState) {
        if state == .ended { playerView.stopVideo() }
    }
    func playerView(_ playerView: WKYTPlayerView, receivedError error: WKYTPlayerError) {
        ToastManager.showToast(message: "영상을 가져오는데 실패했어요.")
    }
    func playerViewIframeAPIDidFailed(toLoad playerView: WKYTPlayerView) {
        ToastManager.showToast(message: "영상을 요청하는데 실패했어요.")
    }
}
extension DetailYoutubeViewController: UICollectionViewDelegate, UICollectionViewDataSource,
                                       UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        // 연관상품
        let innerCellWidth: CGFloat = (view.frame.width-32-12)/2
        let innerCellHeight: CGFloat = innerCellWidth * 1.02 + 10 + 36 + 2 + 18 // 36 = 제목 height
        let count: CGFloat = (CGFloat(relatedItems.count) / 2) + 1
        let innerCollectionViewHeight: CGFloat = innerCellHeight*count + 20*(count-1)
        return CGSize(width: collectionView.frame.width - 32, height: 48 + innerCollectionViewHeight)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: DetailRelatedProductCell.description(),
                for: indexPath) as? DetailRelatedProductCell
        else {return UICollectionViewCell()}
        cell.relatedItems = relatedItems
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let header = collectionView.dequeueReusableSupplementaryView(
            ofKind: kind, withReuseIdentifier: headerID, for: indexPath) as? DetailYoutubeHeader {
            
            let desiredWith = view.frame.width - 32

            let dummyLabel = UILabel()
            dummyLabel.text = video?.title ?? "" // 이모티콘 등을 대비한 한칸 여유
            dummyLabel.numberOfLines = 2
            
            var line = 0
            
            if let font = UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 15) {
                let boundingRect = dummyLabel.text?.boundingRect(with: .zero, options: [.usesFontLeading],
                                                                 attributes: [.font: font, .kern: -0.3], context: nil)
                line = Int(ceil((boundingRect!.width / desiredWith)))
            }
            
            let textSize = calculateTextSize(text: video?.title ?? "") // 제목 & 조회수

            if line == 1 {
                header.videoInfoContainer.snp.remakeConstraints {
                    $0.top.equalToSuperview()
                    $0.left.equalToSuperview().offset(16)
                    $0.right.equalToSuperview().offset(-16)
                    $0.height.equalTo(textSize)
                }
                
                header.viewersAndDate.snp.remakeConstraints {
                    $0.left.right.equalToSuperview()
                    $0.bottom.equalToSuperview().offset(-12)
                    $0.height.equalTo(20)
                }
                
                header.videoTitle.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(15)
                    $0.left.right.equalToSuperview()
                    $0.bottom.equalTo(header.viewersAndDate.snp.top).offset(-5)
                }
                
            } else {
                header.videoInfoContainer.snp.remakeConstraints {
                    $0.top.equalToSuperview()
                    $0.left.equalToSuperview().offset(16)
                    $0.right.equalToSuperview().offset(-16)
                    $0.height.equalTo(textSize)
                }
                
                header.viewersAndDate.snp.remakeConstraints {
                    $0.left.right.equalToSuperview()
                    $0.bottom.equalToSuperview().offset(-10)
                    $0.height.equalTo(20)
                }
                
                header.videoTitle.snp.remakeConstraints {
                    $0.top.equalToSuperview().offset(17)
                    $0.left.right.equalToSuperview()
                    $0.bottom.equalTo(header.viewersAndDate.snp.top).offset(-3)
                }
                
            }
            
            header.videoTitle.text = video?.title
            header.videoTitle.customFont(fontName: .NanumSquareRoundR, size: 15,
                                         letterSpacing: -0.3, lineSpacing: 3)
            header.videoTitle.numberOfLines = 2
            header.videoTitle.lineBreakMode = .byTruncatingTail
            
            header.nameLabel.text = video?.channelCName
            header.nameLabel.customFont(fontName: .NanumSquareRoundB, size: 15, letterSpacing: -0.3)
            header.nameLabel.addGestureRecognizer(UITapGestureRecognizer(target: self,
                                                                  action: #selector(self.goChannelHome)))

            if let url = URL(string: video?.channelProfileUrl ?? "") {
                header.personerImage.kf.setImage(with: url)
            }
            header.personerImage.addGestureRecognizer(
                UITapGestureRecognizer(target: self, action: #selector(self.goChannelHome)))
            header.viewersAndDate.text =
                "\(self.getViewsString(value: video?.views ?? 0)) · \(self.getDateString(str: video?.createdAt ?? ""))"
            header.viewersAndDate.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)

            NetworkManager.getSubscribe(cid: video?.cid ?? "") { (result) in
                header.cid = self.video?.cid ?? ""
                switch result {
                case .success(let data):
                    if data.data {
                        header.isSubscribed = true
                    } else {
                        header.isSubscribed = false
                    }
                case .failure(let error):
                    print("getSubscribe Error : \(error)")
                    ToastManager.showToast(message: "구독정보를 가져오는데 실패했어요.")
                }
            }
            return header
        }
        return UICollectionViewCell()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let textSize = calculateTextSize(text: video?.title ?? "") // 제목 & 조회수
        let height: CGFloat = textSize + 56 + 8
        return CGSize(width: collectionView.frame.width, height: height)
    }
}
