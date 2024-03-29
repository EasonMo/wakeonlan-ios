//
//  HostListInteractor.swift
//  Wake on LAN
//
//  Created by Владислав Лисянский on 21.05.2020.
//  Copyright © 2020 Владислав Лисянский. All rights reserved.
//

import CocoaLumberjackSwift
import CoreDataService
import Foundation
import WakeOnLanService

final class HostListInteractor: HostListInteractorInput {

    weak var presenter: HostListInteractorOutput?

    private let coreDataService: CoreDataServiceProtocol
    private let wakeOnLanService: WakeOnLanService

    init(
        coreDataService: CoreDataServiceProtocol,
        wakeOnLanService: WakeOnLanService
    ) {
        self.coreDataService = coreDataService
        self.wakeOnLanService = wakeOnLanService
    }

    private lazy var cacheTracker: HostListCacheTracker<Host, HostListInteractor> = {
        DDLogVerbose("HostListCacheTracker initialized")
        return HostListCacheTracker(
            with: Host.sortedFetchRequest,
            context: coreDataService.mainContext,
            delegate: self
        )
    }()

    func fetchHosts() {
        guard let hosts = cacheTracker.fetchedObjects else { return }
        presenter?.interactor(self, didFetchHosts: hosts)
    }

    func deleteHost(_ host: Host) {
        guard let context = host.managedObjectContext else { return }
        context.perform { [weak self] in
            context.delete(host)
            self?.coreDataService.saveContext(context, completionHandler: nil)
            DDLogDebug("Host deleted")
        }
    }

    func wakeHost(_ host: Host) {
        do {
            try wakeOnLanService.sendMagicPacket(to: host)
            DDLogDebug("Magic packet was sent")
        } catch {
            presenter?.interactor(self, didEncounterError: error)
            DDLogError("Magic packet was not sent due to error: \(error)")
        }
    }

}

// MARK: - HostListCacheTrackerDelegate

extension HostListInteractor: HostListCacheTrackerDelegate {

    typealias Object = Host

    func cacheTracker(
        _ tracker: CacheTracker,
        didChangeContent content: [Content]
    ) {
        DDLogDebug("CacheTracker changed content")
        presenter?.interactor(self, didChangeContent: content)
    }

}
