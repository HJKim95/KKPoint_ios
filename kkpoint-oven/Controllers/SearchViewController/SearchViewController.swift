//
//  SearchViewController.swift
//  kkpoint-oven
//
//  Created by 김희중 on 2021/01/21.
//

import UIKit
import SnapKit

class SearchViewController: UIViewController {
    private var searchRecord: [String] = []
    
    private var channelList: [Channel] = []
    private var videoList: [Video] = []
    private var subscribeList: [Bool] = []
    
    var isChannelHome: Bool = false
    var cid: String?
    
    let statusBarHeight = UIApplication.shared.statusBarFrame.height
    let navigationBarHeight: CGFloat = 56
    lazy var totalCustomNavBarHeight = statusBarHeight + navigationBarHeight
    
    // MARK: - Views
    private let customNavigationBar: CustomInnerNavigationBar = {
        let navBar = CustomInnerNavigationBar()
        navBar.titleLabel.alpha = 0
        return navBar
    }()
    
    let searchCustomButton: UIButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "iconSearchB24"), for: .normal)
        $0.addTarget(self, action: #selector(doSearchButton), for: .touchUpInside)
        $0.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
    }
    
    let clearCustomButton: UIButton = UIButton(type: .custom).then {
        $0.setImage(UIImage(named: "iconCloseB24"), for: .normal)
        $0.addTarget(self, action: #selector(clearSearch), for: .touchUpInside)
        $0.frame = CGRect(x: 0, y: 0, width: 24, height: 24)
        $0.alpha = 0
    }
    
    lazy var searchStackview = UIStackView(arrangedSubviews: [clearCustomButton, searchCustomButton]).then {
        $0.distribution = .equalSpacing
        $0.axis = .horizontal
        $0.alignment = .center
        $0.spacing = 4
    }

    lazy var searchBar: UISearchBar = {
        let searchbar = UISearchBar()
        searchbar.backgroundColor = UIColor(named: "elavated")
        searchbar.backgroundImage = UIImage()
        let placeholderText = "  검색어를 입력해 주세요."
        searchbar.placeholder = placeholderText
        if let textField = searchbar.value(forKey: "searchField") as? UITextField {
            textField.backgroundColor = UIColor(named: "elavated")
            textField.returnKeyType = .search
            if let font = UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 16) {
                let placeholderAttributedText =  NSAttributedString(string: placeholderText,
                                                         attributes: [NSAttributedString.Key.kern: -1.0,
                                                                       NSAttributedString.Key.font: font])
                
                let attributes =  [NSAttributedString.Key.kern: -1.0,
                                   NSAttributedString.Key.font: font] as [NSAttributedString.Key: Any]
                
                textField.attributedPlaceholder = placeholderAttributedText
                textField.customFont(fontName: .NanumSquareRoundR, size: 16, letterSpacing: -1)
                textField.textColor = UIColor(named: "secondary02")
                textField.defaultTextAttributes = attributes
                // 검색창 왼쪽 돋보기 없애기
                textField.leftViewMode = .never
                textField.autocorrectionType = .no
                textField.autocapitalizationType = .none
            }
            
        }
        // 검색창 커서 색 설정
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = Resource.Color.orange06
        // 택스트 왼쪽으로 옮기기
        searchbar.setPositionAdjustment(UIOffset(horizontal: -50, vertical: 0), for: .search)
        UISearchBar.appearance().searchTextPositionAdjustment = UIOffset(horizontal: -10, vertical: 0)
        // 검색창 오른쪽 이미지 설정
        // searchbar.setImage(UIImage(named: "iconCloseB24"), for: .clear, state: .normal)
        searchbar.sizeToFit()
        // 처음 커서 설정
        searchbar.becomeFirstResponder()
        // 키보드에서 검색 버튼 눌렀을 때를 수신하기 위한 델리게이트
        searchbar.delegate = self
        // 기본 클리어 버튼 없애기
        let textField = searchbar.value(forKey: "searchField") as? UITextField
        textField?.clearButtonMode = .never
        
        return searchbar
    }()
    
    private let noRecordContainer: UIView = UIView()
    private let noSearchRecordLabel: UILabel = UILabel().then {
        $0.numberOfLines = 0
        $0.text = "최근 검색어가 없습니다."
        $0.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3, lineSpacing: 10)
        $0.textColor = UIColor(named: "primary01")
        $0.textAlignment = .center
    }
    
    private let noRecordImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "imgSearchNone")
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    private let noResultContainer: UIView = UIView()
    private let noResultLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.text = "검색결과가 없어요\n다른 검색어로 검색해주세요"
        label.customFont(fontName: .NanumSquareRoundR, size: 14, letterSpacing: -0.3, lineSpacing: 10)
        label.textColor = UIColor(named: "primary01")
        label.textAlignment = .center
        return label
    }()
    private let noResultImageView: UIImageView = {
        let imageview = UIImageView()
        imageview.image = UIImage(named: "imgSearchNone")
        imageview.contentMode = .scaleAspectFit
        return imageview
    }()
    
    private lazy var searchRecordCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "elavated")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.alwaysBounceVertical = true
        collectionview.tag = 0
        return collectionview
    }()
    
    private lazy var totalSearchCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        layout.scrollDirection = .vertical
        let collectionview = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionview.delegate = self
        collectionview.dataSource = self
        collectionview.backgroundColor = UIColor(named: "base")
        collectionview.showsVerticalScrollIndicator = false
        collectionview.alwaysBounceVertical = true
        collectionview.keyboardDismissMode = .interactive
        collectionview.tag = 1
        return collectionview
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Custom Navigation Bar Enable Swipe Back
        self.navigationController?.interactivePopGestureRecognizer?.delegate = nil

        setupLayouts()
        setupKeyboardNotification()

        searchRecordCollectionView.register(SearchRecordCollectionViewCell.self,
                                             forCellWithReuseIdentifier: SearchRecordCollectionViewCell.description())
        let cells = [TotalChannelCollectionViewCell.self, TotalYoutubeCollectionViewCell.self]
        cells.forEach { (cell) in
            totalSearchCollectionView.register(cell.self, forCellWithReuseIdentifier: cell.description())
        }
        
        // 구독 정보 변경 관련 노티피케이션 설정
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(checkChangeSubscribe),
                                               name: Notification.Subscribe.checkSubscribe,
                                               object: nil)
    }
    
    @objc private func checkChangeSubscribe() {
        guard let searchText = searchBar.text else {return}
        if searchText == "" { return }
        NetworkManager.getRefreshedSubscribeData(searchStr: searchText) { [weak self] (result) in
            switch result {
            case .success(let data):
                self?.subscribeList.removeAll()
                self?.subscribeList = data.data ?? [false]
                DispatchQueue.main.async {
                    self?.totalSearchCollectionView.reloadData()
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    private func setChannelHome() {
        searchStackview.alpha = 0
        
        searchBar.text = ""
        searchBar.isUserInteractionEnabled = false
        searchBar.alpha = 0
        searchBar.placeholder = ""
        
        showOnlyOneView(view: totalSearchCollectionView)
        
        guard let cid = cid else { return }
        NetworkManager.getChannelHome(cid: cid) { [weak self] result in
            switch result {
            case .success(let response):
                guard let data = response.data else { return }
                self?.channelList = [data.channel]
                self?.videoList = data.videoList
                self?.cellSizeArray.removeAll()
                self?.videoList.forEach { self?.calculateTextSize(text: $0.title!) }
                self?.subscribeList = [data.isSubscribed]
                self?.totalSearchCollectionView.reloadData()
            case .failure(let error):
                print("getChannelVideos ERROR : \(error)")
            }
        }
    }
    
    private func unsetChannelHome() {
        searchBar.isUserInteractionEnabled = true
        searchBar.alpha = 1
        searchCustomButton.alpha = 1
        searchBar.placeholder = "검색어를 입력해 주세요."
        searchBar.becomeFirstResponder()
    }
    
    private func setupLayouts() {
        view.backgroundColor = UIColor(named: "base")

        // 최근 검색어 없을 때 보이는 애
        view.addSubview(noRecordContainer)
        noRecordContainer.addSubview(noSearchRecordLabel)
        noRecordContainer.addSubview(noRecordImageView)
        // 검색 결과가 없을 때 보이는 애
        view.addSubview(noResultContainer)
        noResultContainer.addSubview(noResultImageView)
        noResultContainer.addSubview(noResultLabel)
        // 검색 결과 보여주기
        view.addSubview(totalSearchCollectionView)
        // 최근 검색어 보여주기
        view.addSubview(searchRecordCollectionView)
        
        noRecordContainer.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(100+totalCustomNavBarHeight)
            make.leading.trailing.equalToSuperview()
            make.height.equalTo(22+24+190)
        }

        noSearchRecordLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.left.right.equalToSuperview()
            $0.height.equalTo(22)
        }
        
        noRecordImageView.snp.makeConstraints {
            $0.top.equalTo(noSearchRecordLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(190)
            $0.width.equalTo(170)
        }
        
        noResultContainer.snp.makeConstraints {
            $0.top.equalToSuperview().offset(100+totalCustomNavBarHeight)
            $0.leading.trailing.equalToSuperview()
        }
        noResultLabel.snp.makeConstraints {
            $0.top.equalToSuperview()
            $0.leading.trailing.equalToSuperview()
            $0.height.equalTo(44)
        }
        noResultImageView.snp.makeConstraints {
            $0.top.equalTo(noResultLabel.snp.bottom).offset(24)
            $0.centerX.equalToSuperview()
            $0.height.equalTo(190)
            $0.width.equalTo(170)
        }
        
        totalSearchCollectionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(totalCustomNavBarHeight)
            make.left.right.bottom.equalToSuperview()
        }

        searchRecordCollectionView.snp.makeConstraints {
            $0.top.equalToSuperview().offset(totalCustomNavBarHeight)
            $0.left.right.bottom.equalToSuperview()
        }
        
        view.addSubview(customNavigationBar)
        customNavigationBar.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        customNavigationBar.navBackView.addSubview(searchBar)
        customNavigationBar.navBackView.addSubview(searchStackview)
        
        searchStackview.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.right.equalToSuperview().offset(-16)
            make.height.equalTo(24)
            make.width.equalTo(52)
        }
        
        searchBar.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(customNavigationBar.backButton.snp.right)
            make.right.equalTo(searchStackview.snp.left)
            make.height.equalTo(22)
        }
    }

    private func setupKeyboardNotification() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc private func keyboardWillShow(_ notification: Notification) {
        if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            // 키보드 높이만큼 올리기
            searchRecordCollectionView.snp.updateConstraints {
                $0.bottom.equalToSuperview().offset(-keyboardHeight)
            }
            
            noRecordContainer.snp.remakeConstraints { (make) in
                make.top.equalToSuperview().offset(100+totalCustomNavBarHeight)
                make.left.right.equalToSuperview()
                make.bottom.equalToSuperview().offset(-keyboardHeight)
            }
        }
    }

    @objc private func keyboardWillHide(_ notification: Notification) {
        searchRecordCollectionView.snp.updateConstraints {
            $0.bottom.equalToSuperview()
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)

        if isChannelHome {
            setChannelHome()
        }
    }
    
    @objc func doSearchButton() {
        searchBarSearchButtonClicked(searchBar)
    }
    @objc func clearSearch() {
        searchBar.text = ""
        searchBar.becomeFirstResponder()
        searchStackview.arrangedSubviews[0].alpha = 0
    }
    
    /// 한 뷰 빼고 다 투명하게 만들기
    private func showOnlyOneView(view: UIView) {
        let onlyOneViews: [UIView] = [noRecordContainer, noResultContainer,
                                    searchRecordCollectionView, totalSearchCollectionView]
        onlyOneViews.forEach { $0.alpha = 0 }
        view.alpha = 1
    }
    
    var cellSizeArray = [CGFloat]()
    
    private func calculateTextSize(text: String) {
        // width -  (38 + 12 ... + 16) - 16*2
        let desiredWith = view.frame.width - 66 - 32
        let cellWidth = view.frame.width - 32
        // MainYoutubeVideoCell 특성 반영
        let dummyLabel = UILabel()
        dummyLabel.text = text + "  " // 이모티콘 등을 대비한 한칸 여유
        dummyLabel.numberOfLines = 2

        guard let font = UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 15) else {return}
        let boundingRect = dummyLabel.text?.boundingRect(with: .zero, options: [.usesFontLeading],
                                                         attributes: [.font: font, .kern: -0.3], context: nil)
        let line = Int(ceil((boundingRect!.width / desiredWith)))
        let youtubeHeight = cellWidth * 0.561
        var totalSize: CGFloat = youtubeHeight + 15
        if line == 1 {
            totalSize += 20 // text Size
            totalSize += 2 + 20 + 15
        } else {
            totalSize += 40 // text Size
            totalSize += 5 + 20 + 10
        }

        cellSizeArray.append(totalSize)
    }
 
    func navBarUp() {
        self.customNavigationBar.alpha = 1
        customNavigationBar.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(-totalCustomNavBarHeight)
            make.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            self.customNavigationBar.alpha = 0
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.didShowNavBar = false
        }
    }
    
    func navBarDown() {
        customNavigationBar.snp.remakeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalTo(totalCustomNavBarHeight)
        }
        
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1,
                       options: .curveEaseOut) {
            self.customNavigationBar.alpha = 1
            self.view.layoutIfNeeded()
        } completion: { (_) in
            self.didShowNavBar = true
        }
    }
    
    var lastContentOffset: CGFloat = 0
    var didShowNavBar = true
}

extension SearchViewController: UICollectionViewDelegate,
                              UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if collectionView.tag == 0 {
            return searchRecord.count
        } else {
            return 2
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if collectionView.tag == 0 { // 검색 기록 그리기
            guard let cell = collectionView.dequeueReusableCell(
                withReuseIdentifier: SearchRecordCollectionViewCell.description(),
                for: indexPath) as? SearchRecordCollectionViewCell
            else { return UICollectionViewCell() }
            cell.searchLabel.text = searchRecord[indexPath.item]
            cell.searchLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
            return cell
        } else { // 검색 결과 그리기
            if indexPath.item == 0 {
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: TotalChannelCollectionViewCell.description(),
                        for: indexPath) as? TotalChannelCollectionViewCell else {return UICollectionViewCell()}
                cell.channelList = self.channelList
                cell.subscribeList = self.subscribeList
                cell.isChannelHome = self.isChannelHome
                cell.channelCollectionView.reloadData()
                return cell
            } else {
                guard let cell = collectionView.dequeueReusableCell(
                        withReuseIdentifier: TotalYoutubeCollectionViewCell.description(),
                        for: indexPath) as? TotalYoutubeCollectionViewCell else {return UICollectionViewCell()}
                cell.videoList = self.videoList
                cell.cellSizeArray = self.cellSizeArray
                cell.youtubeCollectionView.reloadData()
                return cell
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if collectionView.tag == 0 {
            return CGSize(width: collectionView.frame.width, height: 56)
        } else {
            if indexPath.item == 0 {
                let height: CGFloat = CGFloat(self.channelList.count) * CGFloat(72)
                return CGSize(width: collectionView.frame.width, height: height)
            } else {
                let topInset: CGFloat = 16
                let cellHeight = self.cellSizeArray.reduce(0, +)
                let lineSpace: CGFloat = 16
                let totalLineSpace = CGFloat(self.cellSizeArray.count-1) * lineSpace
                return CGSize(width: collectionView.frame.width, height: topInset+cellHeight+totalLineSpace)
            }
        }
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView.tag == 0 { // 검색 기록 클릭
            searchBar.text = searchRecord[indexPath.item]
            searchBarSearchButtonClicked(searchBar)
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var offsetY = totalSearchCollectionView.contentOffset.y //  searchRecodeCV에는 영향없도록.
        let delta = lastContentOffset - offsetY
        let collectionViewOffset = max(totalCustomNavBarHeight-offsetY, statusBarHeight)
        if delta > 0 && lastContentOffset < scrollView.contentSize.height - scrollView.frame.height {
                // move up
            if !didShowNavBar && delta > 5 {
                self.navBarDown()
            }
            if offsetY < 0 { offsetY = 0 }
                
            if offsetY >= -16 {
                totalSearchCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(
                        max(totalCustomNavBarHeight - min(offsetY, totalCustomNavBarHeight), statusBarHeight))
                    make.left.right.bottom.equalToSuperview()
                }
            }
        } else if delta < 0 && offsetY > 0 && scrollView.contentSize.height > scrollView.frame.height {
            if offsetY > totalCustomNavBarHeight && didShowNavBar && delta < -8 {
                self.navBarUp()
            } else {
                if offsetY <= totalCustomNavBarHeight {
                    let alpha = max((totalCustomNavBarHeight-offsetY*1.3)/totalCustomNavBarHeight, 0)
                    customNavigationBar.alpha = alpha
                    didShowNavBar = false
                    
                    customNavigationBar.snp.remakeConstraints { (make) in
                        make.top.equalToSuperview().offset(-min(offsetY, totalCustomNavBarHeight))
                        make.left.right.equalToSuperview()
                        make.height.equalTo(totalCustomNavBarHeight)
                    }
                }
                totalSearchCollectionView.snp.remakeConstraints { (make) in
                    make.top.equalToSuperview().offset(collectionViewOffset)
                    make.left.right.bottom.equalToSuperview()
                }
            }
            
        }
        lastContentOffset = offsetY
    }
}

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchStackview.arrangedSubviews[0].alpha = 0
        if searchText == "" {
            searchStackview.arrangedSubviews[0].alpha = 0
        } else {
            searchStackview.arrangedSubviews[0].alpha = 1
        }
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        if isChannelHome {
            searchBar.endEditing(true)
            return
        }
        // 검색 기록 가져오기
        searchRecord = AccountManager.shared.getSearchRecord()
        if searchRecord.isEmpty {
            showOnlyOneView(view: noRecordContainer)
        } else {
            showOnlyOneView(view: searchRecordCollectionView)
            searchRecordCollectionView.reloadData()
        }
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if isChannelHome {
            isChannelHome = false
            unsetChannelHome()
            return
        }
        
        // 빈 문자열 예외처리
        guard let searchText = searchBar.text else { return }
        if searchText == "" { return }
        // X버튼 띄우기
        searchStackview.arrangedSubviews[0].alpha = 1
        // 커서 끄기
        searchBar.endEditing(true)
        // 검색 기록하기
        AccountManager.shared.setSearchRecord(record: searchText)
        self.cellSizeArray.removeAll()
        // 검색 리퀘스트 발사
        NetworkManager.getSearchData(searchStr: searchText) { [weak self] result in
            switch result {
            case .success(let response):
                // 검색 결과 가져오기
                guard let data = response.data, let self = self else { return }
                self.channelList = data.channelList
                self.subscribeList = data.subscribeList
                self.videoList = data.videoList
                self.videoList.forEach { self.calculateTextSize(text: $0.title!) }
                // 검색 결과 없을 경우
                if self.channelList.count + self.videoList.count == 0 {
                    self.showOnlyOneView(view: self.noResultContainer)
                } else {
                    self.showOnlyOneView(view: self.totalSearchCollectionView)
                }
                DispatchQueue.main.async {
                    self.totalSearchCollectionView.reloadData()
                }
            case .failure(let error):
                print("getSearchData Error : \(error)")
            }
        }
    }
}
