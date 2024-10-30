import UIKit

public protocol YearInReviewCoordinatorDelegate: AnyObject {
    func handleYearInReviewAction(_ action: YearInReviewCoordinatorAction)
}

public enum YearInReviewCoordinatorAction {
    case donate(sourceRect: CGRect, slideLoggingID: String)
    case share(image: UIImage)
}
