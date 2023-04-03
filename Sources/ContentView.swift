//
//  ContentView.swift
//
// Copyright 2023  OpenAlloc LLC
//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at https://mozilla.org/MPL/2.0/.
//

import CoreData
import SwiftUI

import TroutLib
import TroutUI

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject private var manager: CoreDataStack

    @SceneStorage("main-routines-nav") private var routinesNavData: Data?

    var body: some View {
        TroutNavStack(navData: $routinesNavData, destination: destination) {
            MRoutineList()
        }
        .task(priority: .utility, taskAction)
        .onContinueUserActivity(startMRoutineActivityType) {
            handleStartMRoutineUA(viewContext, $0)
        }
    }

    // handle routes for watchOS-specific views here
    @ViewBuilder
    private func destination(_ router: TroutRouter, _ route: TroutRoute) -> some View {
        switch route {
        default:
            TroutDestination(route)
                .environmentObject(router)
                .environment(\.managedObjectContext, viewContext)
        }
    }

    @Sendable
    private func taskAction() async {
        await handleTaskAction(manager)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        let manager = CoreDataStack.getPreviewStack()
        let ctx = manager.container.viewContext
        let routine = MRoutine.create(ctx, userOrder: 0)
        routine.name = "Back & Bicep"
        let e1 = MTask.create(ctx, routine: routine, userOrder: 0)
        e1.name = "Lat Pulldown"
        let e2 = MTask.create(ctx, routine: routine, userOrder: 1)
        e2.name = "Arm Curl"
        return ContentView()
            .environment(\.managedObjectContext, ctx)
            .environmentObject(manager)
    }
}
