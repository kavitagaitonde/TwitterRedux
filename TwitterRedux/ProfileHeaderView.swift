//
//  ProfileHeaderView.swift
//  TwitterRedux
//
//  Created by Kavita Gaitonde on 10/6/17.
//  Copyright © 2017 Kavita Gaitonde. All rights reserved.
//

import UIKit
import TTTAttributedLabel

@IBDesignable
class ProfileHeaderView: UIView, TTTAttributedLabelDelegate {
    
    @IBOutlet var view: UIView!
    @IBOutlet weak var bannerImageView: UIImageView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screennameLabel: TTTAttributedLabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var tweetsCountLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var bannerImageHeightConstraint: NSLayoutConstraint!
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)
        guard let view = view else {return}
        view.frame = bounds
        
        view.autoresizingMask = [UIViewAutoresizing.flexibleWidth,
                                 UIViewAutoresizing.flexibleHeight]
        
        addSubview(view)
        
        // Add our border here and every custom setup
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = UIColor.white.cgColor
        profileImageView.layer.cornerRadius = 5.0
        profileImageView.clipsToBounds = true
        
        pageControl.currentPage = 0
        descriptionLabel.isHidden = true
    }
    
    @IBAction func pageControlAction(_ sender: UIPageControl) {
        if sender.currentPage == 0 {
            nameLabel.isHidden = false
            screennameLabel.isHidden = false
            descriptionLabel.isHidden = true
            bannerImageView.alpha = 1
        } else {
            nameLabel.isHidden = true
            screennameLabel.isHidden = true
            descriptionLabel.isHidden = false
            bannerImageView.alpha = 0.5
        }        
    }
    
    // MARK: - TTTAttributedLabel
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWithPhoneNumber phoneNumber: String!) {
        if let url = URL(string: "tel://\(phoneNumber!)") {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }

    
    /*func loadViewFromNib() -> UIView! {
        Bundle.main.loadNibNamed("ProfileHeaderView", owner: self, options: nil)
        /*let bundle = Bundle(for: type(of: self))
        let nib = UINib(nibName: String(describing: type(of: self)), bundle: bundle)
        let view = nib.instantiate(withOwner: self, options: nil)[0] as! ProfileHeaderView*/
        
        return view
    }*/
}
