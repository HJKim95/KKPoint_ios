//
//  HomeCollectionViewCell.swift
//  kkpoint-oven
//
//  Created by 박영호 on 2021/03/03.
//

import UIKit
import SnapKit

class MainYoutubeVideoCell: UICollectionViewCell {
    // MARK: - Views
    private let viedoImageView: UIImageView = UIImageView().then {
        $0.backgroundColor = .lightGray
        $0.contentMode = .scaleAspectFill
        $0.layer.masksToBounds = true
    }

    private let durationContainer: UIView = UIView().then {
        $0.backgroundColor = Resource.Color.black02
        $0.layer.cornerRadius = 3
        $0.layer.masksToBounds = true
    }

    private let durationLabel: UILabel = UILabel().then {
        $0.textAlignment = .center
        $0.textColor = Resource.Color.white00
    }
    
    private let profileImageView: UIImageView = UIImageView().then {
        $0.backgroundColor = UIColor(named: "elavated")
        $0.layer.cornerRadius = 19
        $0.layer.masksToBounds = true
        $0.layer.borderWidth = 0.3
        $0.layer.borderColor = Resource.Color.grey03.cgColor
        $0.contentMode = .scaleAspectFit
    }

    private let titleLabel: UILabel = UILabel().then {
        $0.textColor = UIColor(named: "primary01")
        $0.sizeToFit()
    }
    
    private let viewAndDateLabel: UILabel = UILabel().then {
        $0.textColor = UIColor(named: "secondary01")
    }
    
    // MARK: - Life Cycle
    required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayouts()
    }
    
    // MARK: - Methods
    func mappingData(data: Video) {
        titleLabel.text = data.title // 영상 제목
        titleLabel.customFont(fontName: .NanumSquareRoundR, size: 15, letterSpacing: -0.3, lineSpacing: 3.0)
        titleLabel.numberOfLines = 2
        titleLabel.lineBreakMode = .byTruncatingTail
        durationLabel.text = durationToString(duration: data.duration) // 영상 재생시간
        durationLabel.customFont(fontName: .NanumSquareRoundR, size: 13, letterSpacing: -0.3)
        
        // width -  (38 + 12 ... + 16)
        let desiredWith = frame.width - 66
        // titleLabel 특성 반영
        let dummyLabel = UILabel()
        dummyLabel.text = data.title // 이모티콘 등을 대비한 한칸 여유
        dummyLabel.numberOfLines = 2

        guard let font = UIFont(name: Resource.Font.NanumSquareRoundR.rawValue, size: 15) else {return}
        let boundingRect = dummyLabel.text?.boundingRect(with: .zero, options: [.usesFontLeading],
                                                         attributes: [.font: font, .kern: -0.3], context: nil)
        let line = Int(ceil((boundingRect!.width / desiredWith)))
        if line == 1 {
            viewAndDateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(2)
                $0.left.equalTo(profileImageView.snp.right).offset(12)
                $0.right.equalToSuperview().offset(-16)
                $0.height.equalTo(20)
            }
        } else {
            viewAndDateLabel.snp.remakeConstraints {
                $0.top.equalTo(titleLabel.snp.bottom).offset(5)
                $0.left.equalTo(profileImageView.snp.right).offset(12)
                $0.right.equalToSuperview().offset(-16)
                $0.height.equalTo(20)
            }
        }

        // 조회수, 생성시간
        viewAndDateLabel.text = "\(getViewsString(value: data.views)) · \(getDateString(str: data.createdAt))"
        viewAndDateLabel.customFont(fontName: .NanumSquareRoundR, size: 12, letterSpacing: -0.5)
        
        // 썸네일 이미지
        guard let thumbnailUrl = URL(string: data.largeThumbnailUrl ?? "") else { return }
        viedoImageView.kf.setImage(with: thumbnailUrl)
        
        // 채널 프로필 사진
        guard let profileUrl = URL(string: data.channelProfileUrl ?? "") else { return }
        profileImageView.kf.setImage(with: profileUrl)
    }
    
    func setShadow() {
        contentView.layer.cornerRadius = 12
        contentView.layer.masksToBounds = true
        
        layer.cornerRadius = 12
        layer.applySketchShadow(color: Resource.Color.black03,
                                            alpha: 1, widthX: 0, widthY: 0, blur: 12, spread: 0)
        layer.masksToBounds = false
    }

    private func getDateString(str: String) -> String {
        // "2021-01-26T04:17:23" -> "2021-01-26"
        let yyyyMMdd = str.split(separator: "T")[0]
//        "2021-01-26" -> "2021.01.26"
        let convertedDate = yyyyMMdd.replacingOccurrences(of: "-", with: ".")
        return convertedDate
    }
    private func getViewsString(value: Int) -> String {
        let numberFormatter = NumberFormatter()
        numberFormatter.numberStyle = .decimal
        let result = "조회수 \(numberFormatter.string(from: NSNumber(value: value))!)회"
        // 몇자리부터 자를지 모름..
        return result
    }
    private func durationToString(duration: Int) -> String {
        let second = duration % 60
        let minite = (duration % 3600) / 60
        let hour = duration / 3600
        var result = ""
        if hour > 0 {
            if hour > 9 {
                result = "\(hour):"
            } else {
                result = "0\(hour):"
            }
        }
        if minite > 9 {
            result += "\(minite):"
        } else {
            result += "0\(minite):"
        }
        
        if second > 9 {
            result += "\(second)"
        } else {
            result += "0\(second)"
        }
        return result
    }
    
    private func setupLayouts() {
        contentView.backgroundColor = UIColor(named: "elavated")
        
        setShadow()
        
        contentView.addSubview(viedoImageView)
        viedoImageView.addSubview(durationContainer)
        durationContainer.addSubview(durationLabel)

        contentView.addSubview(profileImageView)
        contentView.addSubview(titleLabel)
        contentView.addSubview(viewAndDateLabel)

        viedoImageView.snp.makeConstraints {
            $0.top.left.right.equalToSuperview()
            $0.width.equalTo(self.frame.width)
            $0.height.equalTo(self.frame.width * 0.561)
        }
        
        durationContainer.snp.makeConstraints {
            $0.bottom.equalToSuperview().offset(-6)
            $0.right.equalToSuperview().offset(-6)
        }
        durationLabel.snp.makeConstraints {
            $0.top.equalToSuperview().offset(2.5)
            $0.left.right.equalToSuperview().inset(6)
            $0.bottom.equalToSuperview().offset(-1.5)
        }
        
        profileImageView.snp.makeConstraints {
            $0.top.equalTo(viedoImageView.snp.bottom).offset(10)
            $0.left.equalToSuperview().offset(10)
            $0.size.equalTo(38)
        }
        
        titleLabel.snp.makeConstraints {
            $0.top.equalTo(viedoImageView.snp.bottom).offset(15)
            $0.left.equalTo(profileImageView.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-16)
        }
        
        viewAndDateLabel.snp.makeConstraints {
            $0.top.equalTo(titleLabel.snp.bottom).offset(2)
            $0.left.equalTo(profileImageView.snp.right).offset(12)
            $0.right.equalToSuperview().offset(-16)
            $0.height.equalTo(20)
        }
    }
}
