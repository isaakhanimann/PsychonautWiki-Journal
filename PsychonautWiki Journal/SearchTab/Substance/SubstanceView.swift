import SwiftUI

struct SubstanceView: View {

    let substance: Substance
    var areThereInteractions: Bool {
        guard substance.uncertainSubstancesUnwrapped.isEmpty else {return true}
        guard substance.uncertainPsychoactivesUnwrapped.isEmpty else {return true}
        guard substance.uncertainChemicalsUnwrapped.isEmpty else {return true}
        guard substance.uncertainUnresolvedUnwrapped.isEmpty else {return true}
        guard substance.unsafeSubstancesUnwrapped.isEmpty else {return true}
        guard substance.unsafePsychoactivesUnwrapped.isEmpty else {return true}
        guard substance.unsafeChemicalsUnwrapped.isEmpty else {return true}
        guard substance.unsafeUnresolvedUnwrapped.isEmpty else {return true}
        guard substance.dangerousSubstancesUnwrapped.isEmpty else {return true}
        guard substance.dangerousPsychoactivesUnwrapped.isEmpty else {return true}
        guard substance.dangerousChemicalsUnwrapped.isEmpty else {return true}
        guard substance.dangerousUnresolvedUnwrapped.isEmpty else {return true}
        return false
    }

    var body: some View {
        List {
            if let addictionPotential = substance.addictionPotentialUnwrapped {
                Section("Addiction Potential") {
                    Text(addictionPotential)
                }
            }
            if let toxicity = substance.toxicityUnwrapped {
                Section("Toxicity") {
                    Text(toxicity)
                }
            }
            if substance.tolerance?.isAtLeastOneDefined ?? false {
                toleranceSection
            }
            let hasSubs = !substance.crossToleranceSubstancesUnwrapped.isEmpty
            let hasPsych = !substance.crossTolerancePsychoactivesUnwrapped.isEmpty
            let hasChem = !substance.crossToleranceChemicalsUnwrapped.isEmpty
            let showTolerance = hasSubs || hasPsych || hasChem
            if showTolerance {
                crossToleranceSection
            }
            roaSection
            if areThereInteractions {
                interactionSection
            }
            if !substance.effectsUnwrapped.isEmpty {
                effectSection
            }
        }
        .navigationTitle(substance.nameUnwrapped)
        .toolbar {
            ArticleToolbarItem(articleURL: substance.url)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Ingest", action: ingest)
            }
        }
    }

    private var toleranceSection: some View {
        Section("Tolerance") {
            if let zero = substance.tolerance?.zero {
                RowLabelView(label: "zero", value: zero)
            }
            if let half = substance.tolerance?.half {
                RowLabelView(label: "half", value: half)
            }
            if let full = substance.tolerance?.full {
                RowLabelView(label: "full", value: full)
            }
        }
    }

    private var crossToleranceSection: some View {
        Section("Cross Tolerance") {
            ForEach(substance.crossTolerancePsychoactivesUnwrapped) { psych in
                NavigationLink(psych.nameUnwrapped) {
                    PsychoactiveView(psychoactive: psych)
                }
            }
            ForEach(substance.crossToleranceChemicalsUnwrapped) { chem in
                NavigationLink(chem.nameUnwrapped) {
                    ChemicalView(chemical: chem)
                }
            }
            ForEach(substance.crossToleranceSubstancesUnwrapped) { sub in
                NavigationLink(sub.nameUnwrapped) {
                    SubstanceView(substance: sub)
                }
            }
        }
    }

    private var roaSection: some View {
        ForEach(substance.roasUnwrapped) { roa in
            Section(roa.nameUnwrapped.rawValue) {
                DoseView(roaDose: roa.dose)
                DurationView(duration: roa.duration)
                if let bio = roa.bioavailability?.displayString {
                    RowLabelView(label: "Bioavailability", value: "\(bio)%")
                }
            }
        }
    }

    private var interactionSection: some View {
        Section("Interactions (Not Exhaustive)") {
            Group {
                ForEach(substance.uncertainPsychoactivesUnwrapped) { psych in
                    NavigationLink(psych.nameUnwrapped) {
                        PsychoactiveView(psychoactive: psych)
                    }
                    .listRowBackground(Color.yellow)
                }
                ForEach(substance.uncertainChemicalsUnwrapped) { chem in
                    NavigationLink(chem.nameUnwrapped) {
                        ChemicalView(chemical: chem)
                    }
                    .listRowBackground(Color.yellow)
                }
                ForEach(substance.uncertainSubstancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                    .listRowBackground(Color.yellow)
                }
                ForEach(substance.uncertainUnresolvedUnwrapped) { unr in
                    NavigationLink(unr.nameUnwrapped) {
                        UnresolvedView(unresolved: unr)
                    }
                    .listRowBackground(Color.yellow)
                }
            }
            Group {
                ForEach(substance.unsafePsychoactivesUnwrapped) { psych in
                    NavigationLink(psych.nameUnwrapped) {
                        PsychoactiveView(psychoactive: psych)
                    }
                    .listRowBackground(Color.orange)                        }
                ForEach(substance.unsafeChemicalsUnwrapped) { chem in
                    NavigationLink(chem.nameUnwrapped) {
                        ChemicalView(chemical: chem)
                    }
                    .listRowBackground(Color.orange)
                }
                ForEach(substance.unsafeSubstancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                    .listRowBackground(Color.orange)
                }
                ForEach(substance.unsafeUnresolvedUnwrapped) { unr in
                    NavigationLink(unr.nameUnwrapped) {
                        UnresolvedView(unresolved: unr)
                    }
                    .listRowBackground(Color.orange)
                }
            }
            Group {
                ForEach(substance.dangerousPsychoactivesUnwrapped) { psych in
                    NavigationLink(psych.nameUnwrapped) {
                        PsychoactiveView(psychoactive: psych)
                    }
                    .listRowBackground(Color.red)
                }
                ForEach(substance.dangerousChemicalsUnwrapped) { chem in
                    NavigationLink(chem.nameUnwrapped) {
                        ChemicalView(chemical: chem)
                    }
                    .listRowBackground(Color.red)
                }
                ForEach(substance.dangerousSubstancesUnwrapped) { sub in
                    NavigationLink(sub.nameUnwrapped) {
                        SubstanceView(substance: sub)
                    }
                    .listRowBackground(Color.red)
                }
                ForEach(substance.dangerousUnresolvedUnwrapped) { unr in
                    NavigationLink(unr.nameUnwrapped) {
                        UnresolvedView(unresolved: unr)
                    }
                    .listRowBackground(Color.red)
                }
            }
        }
    }

    private var effectSection: some View {
        Section("Subjective Effects (not exhaustive)") {
            ForEach(substance.effectsUnwrapped) { eff in
                NavigationLink(eff.nameUnwrapped) {
                    EffectView(effect: eff)
                }
            }
        }
    }

    private func ingest() {}
}

struct RowLabelView: View {

    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label+" ")
            Spacer()
            Text(value)
                .foregroundColor(.secondary)
        }
    }
}

struct SubstanceView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            SubstanceView(substance: PreviewHelper.shared.getSubstance(with: "Caffeine")!)
        }
    }
}