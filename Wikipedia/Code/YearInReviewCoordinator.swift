import UIKit
import PassKit
import SwiftUI
import WMFComponents
import WMFData

@objc(WMFYearInReviewCoordinator)
final class YearInReviewCoordinator: NSObject, Coordinator {
    let theme: Theme
    let dataStore: MWKDataStore

    var navigationController: UINavigationController
    private weak var viewModel: WMFYearInReviewViewModel?
    private let targetRects = WMFProfileViewTargetRects()
    let dataController: WMFYearInReviewDataController
    var donateCoordinator: DonateCoordinator?

    // Collective base numbers that will change
    let collectiveNumArticlesText = WMFLocalizedString("year-in-review-2024-Wikipedia-num-articles", value: "63.69 million articles", comment: "Total number of articles across Wikipedia. This text will be inserted into paragraph text displayed in Wikipedia Year in Review slides for 2024.")

    let collectiveNumLanguagesText = WMFLocalizedString("year-in-review-2024-Wikipedia-num-languages", value: "332 active languages", comment: "Number of active languages available on Wikipedia. This text will be inserted into paragraph text displayed in Wikipedia Year in Review slides for 2024.")

    let collectiveNumViewsText = WMFLocalizedString("year-in-review-2024-Wikipedia-num-views", value: "1.4 billion times", comment: "Number of article views on Wikipedia. This text will be inserted into paragraph text displayed in Wikipedia Year in Review slides for 2024.")

    let collectiveNumEditsText = WMFLocalizedString("year-in-review-2024-Wikipedia-num-edits", value: "460,300 edits", comment: "Number of edits made on Wikipedia. This text will be inserted into paragraph text displayed in Wikipedia Year in Review slides for 2024.")

    let collectiveNumEditsPerMinuteText = WMFLocalizedString("year-in-review-2024-Wikipedia-num-edits-per-minute", value: "342 edits per minute", comment: "Number of edits per minute made on Wikipedia. This text will be inserted into paragraph text displayed in Wikipedia Year in Review slides for 2024.")

    public init(navigationController: UINavigationController, theme: Theme, dataStore: MWKDataStore, dataController: WMFYearInReviewDataController) {
        self.navigationController = navigationController
        self.theme = theme
        self.dataStore = dataStore
        self.dataController = dataController
    }

    var baseSlide1Title: String {
        WMFLocalizedString("year-in-review-base-reading-title", value: "Reading brought us together", comment: "Year in review, collective reading article count slide title")
    }

    var baseSlide1Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-reading-subtitle", value: "Wikipedia had %1$@ across over %2$@ this year. You joined millions in expanding knowledge and exploring diverse topics.", comment: "Year in review, collective reading count slide subtitle. %1$@ is replaced with text representing the number of articles available across Wikipedia, e.g. \"63.69 million articles\". %2$@ is replaced with text representing the number of active languages available on Wikipedia, e.g. \"332 active languages\"")
        return String.localizedStringWithFormat(format, collectiveNumArticlesText, collectiveNumLanguagesText)
    }

    var baseSlide2Title: String {
        let format = WMFLocalizedString("year-in-review-base-viewed-title", value: "We have viewed Wikipedia articles %1$@.", comment: "Year in review, collective article view count slide title. %1$@ is replaced with the text representing the number of article views across Wikipedia, e.g. \"1.4 billion times\".")
        return String.localizedStringWithFormat(format, collectiveNumViewsText)
    }

    var baseSlide2Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-viewed-subtitle", value: "iOS app users have viewed Wikipedia articles %1$@. For people around the world, Wikipedia is the first stop when answering a question, looking up information for school or work, or learning a new fact.", comment: "Year in review, collective article view count subtitle, %1$@ is replaced with the number of article views text, e.g. \"1.4 billion times\"")
        return String.localizedStringWithFormat(format, collectiveNumViewsText)
    }

    var baseSlide3Title: String {
        let format = WMFLocalizedString("year-in-review-base-editors-title", value: "Editors on the iOS app made more than %1$@", comment: "Year in review, collective edits count slide title, %1$@ is replaced with the number of edits text, e.g. \"460,300 edits\".")
        return String.localizedStringWithFormat(format, collectiveNumEditsText)
    }

    var baseSlide3Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-editors-subtitle", value: "Wikipedia's community of volunteer editors made more than %1$@ on the iOS app so far this year. The heart and soul of Wikipedia is our global community of volunteer contributors, donors, and billions of readers like yourself – all united to share unlimited access to reliable information.", comment: "Year in review, collective edits count slide subtitle, %1$@ is replaced with the number of edits text, e.g. \"460,300 edits\"")
        return String.localizedStringWithFormat(format, collectiveNumEditsText)
    }

    var baseSlide4Title: String {
        let format = WMFLocalizedString("year-in-review-base-edits-title", value: "Wikipedia was edited %1$@", comment: "Year in review, collective edits per minute slide title, %1$@ is replaced with the number of edits per minute text, e.g. \"342 times per minute\".")
        return String.localizedStringWithFormat(format, collectiveNumEditsPerMinuteText)
    }

    var baseSlide4Subtitle: String {
        let format = WMFLocalizedString("year-in-review-base-edits-subtitle", value: "This year, Wikipedia was edited at an average rate of %1$@. Articles are collaboratively created and improved using reliable sources. Each edit plays a crucial role in improving and expanding Wikipedia.", comment: "Year in review, collective edits per minute slide subtitle, %1$@ is replaced with the number of edits per minute text, e.g. \"342 times per minute\"")
        return String.localizedStringWithFormat(format, collectiveNumEditsPerMinuteText)
    }

    func personalizedSlide1Title(readCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-reading-title- format", value: "You read {{PLURAL:%1$d|%1$d article|%1$d articles}} this year", comment: "Year in review, personalized reading article count slide title for users that read articles. %1$d is replaced with the number of articles the user read.")
        return String.localizedStringWithFormat(format, readCount)
    }

    func personalizedSlide1Subtitle(readCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-reading-subtitle-format", value: "You read {{PLURAL:%1$d|%1$d article|%1$d articles}} this year. This year Wikipedia had %2$@ available across over %3$@ this year. You joined millions in expanding knowledge and exploring diverse topics.", comment: "Year in review, personalized reading article count slide subtitle for users that read articles. %1$d is replaced with the number of articles the user read. %2$@ is replaced with the number of articles available across Wikipedia, for example, \"63.59 million articles\". %3$@ is replaced with the number of active languages available on Wikipedia, for example \"332 active languages\"")
        return String.localizedStringWithFormat(format, readCount, collectiveNumArticlesText, collectiveNumLanguagesText)
    }

    func personalizedSlide3Title(editCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-title-format", value: "You edited Wikipedia {{PLURAL:%1$d|%1$d time|%1$d times}}", comment: "Year in review, personalized editing article count slide title for users that edited articles. %1$d is replaced with the number of edits the user made.")
        return String.localizedStringWithFormat(format, editCount)
    }
    
    func personalizedSlide3Title500Plus() -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-title-format-500plus", value: "You edited Wikipedia 500+ times", comment: "Year in review, personalized editing article count slide title for users that edited articles 500+ times. ")
        return String.localizedStringWithFormat(format)
    }
    
    func personalizedSlide3Subtitle(editCount: Int) -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-subtitle-format", value: "You edited Wikipedia {{PLURAL:%1$d|%1$d time|%1$d times}}. Thank you for being one of the volunteer editors making a difference on Wikimedia projects around the world.", comment: "Year in review, personalized editing article count slide subtitle for users that edited articles. %1$d is replaced with the number of edits the user made.")
        return String.localizedStringWithFormat(format, editCount)
    }
    
    func personalizedSlide3Subtitle500Plus() -> String {
        let format = WMFLocalizedString("year-in-review-personalized-editing-subtitle-format-500plus", value: "You edited Wikipedia 500+ times. Thank you for being one of the volunteer editors making a difference on Wikimedia projects around the world.", comment: "Year in review, personalized editing article count slide subtitle for users that edited articles more than 500 times.")
        return String.localizedStringWithFormat(format)
    }

    private struct PersonalizedSlides {
        let readCount: YearInReviewSlideContent?
        let editCount: YearInReviewSlideContent?
    }

    private func getPersonalizedSlides() -> PersonalizedSlides {

        guard let dataController = try? WMFYearInReviewDataController(),
              let report = try? dataController.fetchYearInReviewReport(forYear: 2024) else {
            return PersonalizedSlides(readCount: nil, editCount: nil)
        }

        var readCountSlide: YearInReviewSlideContent? = nil
        var editCountSlide: YearInReviewSlideContent? = nil

        for slide in report.slides {
            switch slide.id {
            case .readCount:
                if slide.display == true,
                   let data = slide.data {
                    let decoder = JSONDecoder()
                    if let readCount = try? decoder.decode(Int.self, from: data) {
                        readCountSlide = YearInReviewSlideContent(
                            imageName: "heart_yir", title: personalizedSlide1Title(readCount: readCount), informationBubbleText: nil, subtitle: personalizedSlide1Subtitle(readCount: readCount), loggingID: "read_count_custom")
                    }
                }
            case .editCount:
                if slide.display == true,
                        let data = slide.data {
                    let decoder = JSONDecoder()
                    if let editCount = try? decoder.decode(Int.self, from: data) {
                        editCountSlide = YearInReviewSlideContent(
                            imageName: "languages_yir",
                            title: editCount >= 500 ? personalizedSlide3Title500Plus() : personalizedSlide3Title(editCount: editCount),
                            informationBubbleText: nil,
                            subtitle: editCount >= 500 ? personalizedSlide3Subtitle500Plus() : personalizedSlide3Subtitle(editCount: editCount),
                            loggingID: "edit_count_custom")
                    }
                }
            }
        }

        return PersonalizedSlides(readCount: readCountSlide, editCount: editCountSlide)
    }

    func start() {

        var firstSlide = YearInReviewSlideContent(
            imageName: "heart_yir",
            title: baseSlide1Title,
            informationBubbleText: nil,
            subtitle: baseSlide1Subtitle,
            loggingID: "read_count_base")

        var thirdSlide = YearInReviewSlideContent(
            imageName: "languages_yir",
            title: baseSlide3Title,
            informationBubbleText: nil,
            subtitle: baseSlide3Subtitle,
            loggingID: "edit_count_base")

        let personalizedSlides = getPersonalizedSlides()

        if let readCountSlide = personalizedSlides.readCount {
            firstSlide = readCountSlide
        }

        if let editCountSlide = personalizedSlides.editCount {
            thirdSlide = editCountSlide
        }

        let slides: [YearInReviewSlideContent] = [
            firstSlide,
            YearInReviewSlideContent(
                imageName: "phone_yir",
                title: baseSlide2Title,
                informationBubbleText: nil,
                subtitle: baseSlide2Subtitle,
                loggingID: "read_view_base"),
            thirdSlide,
            YearInReviewSlideContent(
                imageName: "edit_yir",
                title: baseSlide4Title,
                informationBubbleText: nil,
                subtitle: baseSlide4Subtitle,
                loggingID: "edit_rate_base")
        ]

        let localizedStrings = WMFYearInReviewViewModel.LocalizedStrings.init(
            donateButtonTitle: WMFLocalizedString("year-in-review-donate", value: "Donate", comment: "Year in review donate button"),
            doneButtonTitle: WMFLocalizedString("year-in-review-done", value: "Done", comment: "Year in review done button"),
            shareButtonTitle: WMFLocalizedString("year-in-review-share", value: "Share", comment: "Year in review share button"),
            nextButtonTitle: WMFLocalizedString("year-in-review-next", value: "Next", comment: "Year in review next button"),
            firstSlideTitle: WMFLocalizedString("year-in-review-title", value: "Explore your Wikipedia Year in Review", comment: "Year in review page title"),
            firstSlideSubtitle: WMFLocalizedString("year-in-review-subtitle", value: "See insights about which articles you read on the Wikipedia app and the edits you made. Share your journey and discover what stood out for you this year. Your reading history is kept protected. Reading insights are calculated using locally stored data on your device.", comment: "Year in review page information"),
            firstSlideCTA: WMFLocalizedString("year-in-review-get-started", value: "Get Started", comment: "Button to continue to year in review"),
            firstSlideHide: WMFLocalizedString("year-in-review-hide", value: "Hide this feature", comment: "Button to hide year in review feature"),
            shareText: WMFLocalizedString("year-in-review-share-text", value: "Here's my Wikipedia year in review. Created with the Wikipedia iOS app", comment: "Text shared the Year In Review slides"),
            usernameTitle: CommonStrings.userTitle
        )

        let appShareLink = "https://apps.apple.com/app/apple-store/id324715238?pt=208305&ct=yir_2024_share&mt=8"
        let hashtag = "#WikipediaYearInReview"
        let viewModel = WMFYearInReviewViewModel(localizedStrings: localizedStrings, slides: slides, username: dataStore.authenticationManager.authStatePermanentUsername, shareLink: appShareLink, hashtag: hashtag, coordinatorDelegate: self, loggingDelegate: self)

        var yirview = WMFYearInReviewView(viewModel: viewModel)

        yirview.donePressed = { [weak self] in
            self?.navigationController.dismiss(animated: true, completion: nil)
        }

        self.viewModel = viewModel
        let finalView = yirview.environmentObject(targetRects)
        let hostingController = UIHostingController(rootView: finalView)
        hostingController.modalPresentationStyle = .pageSheet

        if let sheetPresentationController = hostingController.sheetPresentationController {
            sheetPresentationController.detents = [.large()]
            sheetPresentationController.prefersGrabberVisible = false
        }
        
        hostingController.presentationController?.delegate = self

        navigationController.present(hostingController, animated: true, completion: nil)
    }

}

extension YearInReviewCoordinator: WMFYearInReviewLoggingDelegate {
    
    func logYearInReviewSlideDidAppear(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewSlideImpression(slideLoggingID: slideLoggingID)
    }
    
    func logYearInReviewDidTapDone(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewDidTapDone(slideLoggingID: slideLoggingID)
    }
    
    func logYearInReviewIntroDidTapContinue() {
        DonateFunnel.shared.logYearInReviewDidTapIntroContinue()
    }
    
    func logYearInReviewIntroDidTapDisable() {
        DonateFunnel.shared.logYearInReviewDidTapIntroDisable()
    }
    
    func logYearInReviewDidTapNext(slideLoggingID: String) {
        DonateFunnel.shared.logYearInReviewDidTapNext(slideLoggingID: slideLoggingID)
    }
}

extension YearInReviewCoordinator: UIAdaptivePresentationControllerDelegate {
    public func presentationControllerWillDismiss(_ presentationController: UIPresentationController) {
        viewModel?.logYearInReviewDidTapDone()
    }
}

extension YearInReviewCoordinator: YearInReviewCoordinatorDelegate {
    func handleYearInReviewAction(_ action: WMFComponents.YearInReviewCoordinatorAction) {
        switch action {
        case .donate(let rect, let slideLoggingID):
            
            if let metricsID = DonateCoordinator.metricsID(for: .yearInReview, languageCode: dataStore.languageLinkController.appLanguage?.languageCode) {
                DonateFunnel.shared.logYearInReviewDidTapDonate(slideLoggingID: slideLoggingID, metricsID: metricsID)
            }
            
            let donateCoordinator = DonateCoordinator(navigationController: navigationController, donateButtonGlobalRect: rect, source: .yearInReview, dataStore: dataStore, theme: theme) { loading in
                guard let viewModel = self.viewModel else { return }
                viewModel.isLoading = loading
            }
            self.donateCoordinator = donateCoordinator
            donateCoordinator.start()
        case .share(let image):

            guard let viewModel else { return }

            let text = "\(viewModel.localizedStrings.shareText) (\(viewModel.shareLink))\(viewModel.hashtag)"

            let activityItems: [Any] = [ShareAFactActivityImageItemProvider(image: image), text]

            let activityController = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
            activityController.excludedActivityTypes = [.print, .assignToContact, .addToReadingList]

            if let visibleVC = self.navigationController.visibleViewController {
                if let popover = activityController.popoverPresentationController {
                    popover.sourceRect = visibleVC.view.bounds
                    popover.sourceView = visibleVC.view
                    popover.permittedArrowDirections = []
                }

                visibleVC.present(activityController, animated: true, completion: nil)
            }
        }
    }
}
