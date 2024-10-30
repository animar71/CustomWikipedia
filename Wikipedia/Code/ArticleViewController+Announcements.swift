import WMF
import CocoaLumberjackSwift
import WMFData
import WMFComponents

extension ArticleViewController {
    
    func showAnnouncementIfNeeded() {
        
        guard let countryCode = Locale.current.region?.identifier,
           let wikimediaProject = WikimediaProject(siteURL: articleURL),
           let wmfProject = wikimediaProject.wmfProject else {
            return
        }
        
        let dataController = WMFFundraisingCampaignDataController.shared
        
        Task {
            let isOptedIn = await dataController.isOptedIn(project: wmfProject)
            
            guard let activeCampaignAsset = dataController.loadActiveCampaignAsset(countryCode: countryCode, wmfProject: wmfProject, currentDate: .now) else {
                return
            }

            if !isOptedIn {
                if let project {
                    DonateFunnel.shared.logHiddenBanner(project: project, metricsID: activeCampaignAsset.metricsID)
                }
            }

            guard isOptedIn else {
                return
            }

            willDisplayFundraisingBanner = true

            showNewDonateExperienceCampaignModal(asset: activeCampaignAsset, project: wikimediaProject)
        }
    }
    
    private func showNewDonateExperienceCampaignModal(asset: WMFFundraisingCampaignConfig.WMFAsset, project: WikimediaProject) {
        
        DonateFunnel.shared.logFundraisingCampaignModalImpression(project: project, metricsID: asset.metricsID)
        
        let dataController = WMFFundraisingCampaignDataController.shared
        
        let shouldShowMaybeLater = dataController.showShowMaybeLaterOption(asset: asset, currentDate: Date())

        wmf_showFundraisingAnnouncement(theme: theme, asset: asset, primaryButtonTapHandler: { [weak self] button, viewController in
            
            guard let self else {
                return
            }
            
            DonateFunnel.shared.logFundraisingCampaignModalDidTapDonate(project: project, metricsID: asset.metricsID)
            
            guard let navigationController = self.navigationController,
            let globalPoint = button.superview?.convert(button.frame.origin, to: navigationController.view),
            let donateURL =  asset.actions[0].url else {
                return
            }
            
            let globalRect = CGRect(x: globalPoint.x, y: globalPoint.y, width: button.frame.width, height: button.frame.height)
            
            let donateCoordinator = DonateCoordinator(navigationController: navigationController, donateButtonGlobalRect: globalRect, source: .articleCampaignModal(articleURL, asset.metricsID, donateURL), dataStore: dataStore, theme: theme, setLoadingBlock: { isLoading in
                guard let fundraisingPanelVC = viewController as? FundraisingAnnouncementPanelViewController else {
                    return
                }
                
                fundraisingPanelVC.isLoading = isLoading
            })
            
            self.donateCoordinator = donateCoordinator
            donateCoordinator.start()
            
            dataController.markAssetAsPermanentlyHidden(asset: asset)
            
        }, secondaryButtonTapHandler: { _, _ in
            DonateFunnel.shared.logFundraisingCampaignModalDidTapMaybeLater(project: project, metricsID: asset.metricsID)
            
            if shouldShowMaybeLater {
                dataController.markAssetAsMaybeLater(asset: asset, currentDate: Date())
                self.donateDidSetMaybeLater(metricsID: asset.metricsID)
            } else {
                DonateFunnel.shared.logFundraisingCampaignModalDidTapAlreadyDonated(project: project, metricsID: asset.metricsID)
                self.donateAlreadyDonated()
                dataController.markAssetAsPermanentlyHidden(asset: asset)
            }
            
        }, optionalButtonTapHandler: { _, _ in
            DonateFunnel.shared.logFundraisingCampaignModalDidTapAlreadyDonated(project: project, metricsID: asset.metricsID)
            self.donateAlreadyDonated()
            dataController.markAssetAsPermanentlyHidden(asset: asset)
            
        }, footerLinkAction: { url in
            DonateFunnel.shared.logFundraisingCampaignModalDidTapDonorPolicy(project: project, metricsID: asset.metricsID)
            self.navigate(to: url, useSafari: true)
        }, traceableDismissHandler: { action in
            
            if action == .tappedClose {
                DonateFunnel.shared.logFundraisingCampaignModalDidTapClose(project: project, metricsID: asset.metricsID)
                dataController.markAssetAsPermanentlyHidden(asset: asset)
            }
        }, showMaybeLater: shouldShowMaybeLater)
    }

    func donateDidSetMaybeLater(metricsID: String) {
        
        let project = WikimediaProject(siteURL: articleURL)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let title = WMFLocalizedString("donate-later-title", value: "We will remind you again tomorrow.", comment: "Title for toast shown when user clicks remind me later on fundraising banner")

            if let project {
                DonateFunnel.shared.logArticleDidSeeReminderToast(project: project, metricsID: metricsID)
            }
            
            WMFAlertManager.sharedInstance.showBottomAlertWithMessage(title, subtitle: nil, image: UIImage.init(systemName: "checkmark.circle.fill"), type: .custom, customTypeName: "watchlist-add-remove-success", duration: -1, dismissPreviousAlerts: true)
        }
    }

    func donateAlreadyDonated() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let title = WMFLocalizedString("donate-already-donated", value: "Thank you, dear donor! Your generosity helps keep Wikipedia and its sister sites thriving.", comment: "Thank you toast shown when user clicks already donated on fundraising banner")

            WMFAlertManager.sharedInstance.showBottomAlertWithMessage(title, subtitle: nil, image: UIImage.init(systemName: "checkmark.circle.fill"), type: .custom, customTypeName: "watchlist-add-remove-success", duration: -1, dismissPreviousAlerts: true)
        }
    }

    // TODO: remove after expiry date (1 March 2025)
    func presentYearInReviewAnnouncement() {

        if UIDevice.current.userInterfaceIdiom == .pad && navigationBar.hiddenHeight > 0 {
            return
        }

        guard !willDisplayFundraisingBanner else {
            return
        }

        guard let yirDataController = try? WMFYearInReviewDataController() else {
            return
        }

        guard let wmfProject = project?.wmfProject, yirDataController.shouldShowYearInReviewFeatureAnnouncement(primaryAppLanguageProject: wmfProject) else {
            return
        }

        let title = CommonStrings.yirFeatureAnnoucementTitle
        let body = CommonStrings.yirFeatureAnnoucementBody
        let primaryButtonTitle = CommonStrings.continueButton
        let image = UIImage(named: "wikipedia-globe")

        let viewModel = WMFFeatureAnnouncementViewModel(title: title, body: body, primaryButtonTitle: primaryButtonTitle, image: image, primaryButtonAction: { [weak self] in
            guard let self,
                  let navController = self.navigationController
            else { return }
            yirCoordinator = YearInReviewCoordinator(navigationController: navController, theme: theme, dataStore: dataStore, dataController: yirDataController)
            yirCoordinator?.start()
            DonateFunnel.shared.logYearInReviewFeatureAnnouncementDidTapContinue()
        }, closeButtonAction: {
            DonateFunnel.shared.logYearInReviewFeatureAnnouncementDidTapClose()
        })

        if navigationBar.superview != nil {
            let xOrigin = navigationBar.frame.width - 100
            let yOrigin = view.safeAreaInsets.top + navigationBar.barTopSpacing + 15
            let sourceRect = CGRect(x:  xOrigin, y: yOrigin, width: 30, height: 30)
            announceFeature(viewModel: viewModel, sourceView: self.view, sourceRect: sourceRect)
            DonateFunnel.shared.logYearInReviewFeatureAnnouncementDidAppear()
        }
        
        yirDataController.hasPresentedYiRFeatureAnnouncementModel = true
    }
}

extension WMFFundraisingCampaignConfig.WMFAsset {
    var metricsID: String {
        return "\(languageCode)\(countryCode)_\(id)_iOS"
    }
}

extension ArticleViewController: WMFFeatureAnnouncing { }
