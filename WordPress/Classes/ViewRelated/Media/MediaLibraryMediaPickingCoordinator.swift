import MobileCoreServices
import WPMediaPicker

final class MediaLibraryMediaPickingCoordinator {
    private weak var delegate: MediaPickingOptionsDelegate?

    private let stockPhotos = StockPhotosPicker()
    private let cameraCapture = CameraCaptureCoordinator()

    init(delegate: MediaPickingOptionsDelegate & StockPhotosPickerDelegate) {
        self.delegate = delegate
        stockPhotos.delegate = delegate
    }

    func present(context: MediaPickingContext) {
        let origin = context.origin
        let blog = context.blog
        let fromView = context.view

        let menuAlert = UIAlertController(title: nil, message: nil, preferredStyle: UIAlertControllerStyle.actionSheet)

        if let quotaUsageDescription = blog.quotaUsageDescription {
            menuAlert.title = quotaUsageDescription
        }

        if WPMediaCapturePresenter.isCaptureAvailable() {
            menuAlert.addAction(cameraAction(origin: origin, blog: blog))
        }

        menuAlert.addDefaultActionWithTitle(NSLocalizedString("Photo Library", comment: "Menu option for selecting media from the device's photo library.")) { [weak self] _ in
            self?.showMediaPicker(origin: origin)
        }

        menuAlert.addAction(freePhotoAction(origin: origin, blog: blog))

        if #available(iOS 11.0, *) {
            menuAlert.addAction(otherAppsAction(origin: origin))
        }

        menuAlert.addAction(cancelAction())

        // iPad support
//        menuAlert.popoverPresentationController?.sourceView = fromView
//        menuAlert.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem

        origin.present(menuAlert, animated: true, completion: nil)
    }

    private func cameraAction(origin: UIViewController, blog: Blog) -> UIAlertAction {
                return UIAlertAction(title: .takePhotoOrVideo, style: .default, handler: { [weak self] action in
                    self?.showCameraCapture(origin: origin, blog: blog)
                })
    }

    private func freePhotoAction(origin: UIViewController, blog: Blog) -> UIAlertAction {
        return UIAlertAction(title: .freePhotosLibrary, style: .default, handler: { [weak self] action in
            self?.showStockPhotos(origin: origin, blog: blog)
        })
    }

    private func otherAppsAction(origin: UIViewController & UIDocumentPickerDelegate) -> UIAlertAction {
        return UIAlertAction(title: .files, style: .default, handler: { [weak self] action in
            self?.showDocumentPicker(origin: origin)
        })
    }

    private func cancelAction() -> UIAlertAction {
        return UIAlertAction(title: .cancelMoreOptions, style: .cancel, handler: { [weak self] action in
            self?.delegate?.didCancel()
        })
    }

    private func showCameraCapture(origin: UIViewController, blog: Blog) {
        cameraCapture.presentMediaCapture(origin: origin, blog: blog)
    }

    private func showStockPhotos(origin: UIViewController, blog: Blog) {
        stockPhotos.presentPicker(origin: origin, blog: blog)
    }

    private func showDocumentPicker(origin: UIViewController & UIDocumentPickerDelegate) {
        let docTypes = [String(kUTTypeImage), String(kUTTypeMovie)]
        let docPicker = UIDocumentPickerViewController(documentTypes: docTypes, in: .import)
        docPicker.delegate = origin
        WPStyleGuide.configureDocumentPickerNavBarAppearance()
        origin.present(docPicker, animated: true, completion: nil)
    }

    private func showMediaPicker(origin: UIViewController & UIDocumentPickerDelegate) {
        let options = WPMediaPickerOptions()
        options.showMostRecentFirst = true
        options.filter = [.all]
        options.allowCaptureOfMedia = false

        let picker = WPNavigationMediaPickerViewController(options: options)
        picker.dataSource = WPPHAssetDataSource()
        //picker.delegate = self

        origin.present(picker, animated: true, completion: nil)
    }
}
