import Foundation

// Known B-school (IIM / other premier MBA institute) email domains.
// The app restricts sign-up to graduates of these institutions.
enum BSchoolDomain: String, CaseIterable {
    case iimA  = "iima.ac.in"
    case iimB  = "iimb.ac.in"
    case iimC  = "iimc.ac.in"
    case iimL  = "iiml.ac.in"
    case iimK  = "iimk.ac.in"
    case iimI  = "iimi.ac.in"
    case iimT  = "iimt.ac.in"
    case iimU  = "iimu.ac.in"
    case iimR  = "iimraipur.ac.in"
    case iimRo = "iimranchi.ac.in"
    case iimKa = "iimkashipur.ac.in"
    case iimTr = "iimtrichy.ac.in"
    case iimBo = "iimbodhgaya.ac.in"
    case iimSa = "iimsirmaur.ac.in"
    case iimSa2 = "iimsamba.ac.in"
    case iimJa = "iimjammu.ac.in"
    case iimAm = "iimamritsar.ac.in"
    case iimNa = "iimnagpur.ac.in"
    case iimSh = "iimshillong.ac.in"
    case iimVi = "iimvisakhapatnam.ac.in"
    case iimSam = "iimsambalpur.ac.in"
    // Other premier B-schools
    case xlri   = "xlri.ac.in"
    case fms    = "fms.edu"
    case spjain = "spjain.org"
    case mdi    = "mdi.ac.in"
    case nmims  = "nmims.edu"
    case isb    = "isb.edu"
    case imi    = "imi.edu"
    case iift   = "iift.edu"
    case tiss   = "tiss.edu"
    case bimtech = "bimtech.ac.in"

    var displayName: String {
        switch self {
        case .iimA:   return "IIM Ahmedabad"
        case .iimB:   return "IIM Bangalore"
        case .iimC:   return "IIM Calcutta"
        case .iimL:   return "IIM Lucknow"
        case .iimK:   return "IIM Kozhikode"
        case .iimI:   return "IIM Indore"
        case .iimT:   return "IIM Tiruchirappalli"
        case .iimU: return "IIM Udaipur"
        case .iimR:   return "IIM Raipur"
        case .iimRo:  return "IIM Ranchi"
        case .iimKa:  return "IIM Kashipur"
        case .iimTr:  return "IIM Trichy"
        case .iimBo:  return "IIM Bodh Gaya"
        case .iimSa:  return "IIM Sirmaur"
        case .iimSa2: return "IIM Samba"
        case .iimJa:  return "IIM Jammu"
        case .iimAm:  return "IIM Amritsar"
        case .iimNa:  return "IIM Nagpur"
        case .iimSh:  return "IIM Shillong"
        case .iimVi:  return "IIM Visakhapatnam"
        case .iimSam: return "IIM Sambalpur"
        case .xlri:   return "XLRI"
        case .fms:    return "FMS Delhi"
        case .spjain: return "SP Jain"
        case .mdi:    return "MDI Gurgaon"
        case .nmims:  return "NMIMS"
        case .isb:    return "ISB"
        case .imi:    return "IMI Delhi"
        case .iift:   return "IIFT"
        case .tiss:   return "TISS"
        case .bimtech: return "BIMTECH"
        }
    }

    /// All unique display names, deduped (for the institution picker).
    static var allInstitutions: [String] {
        var seen = Set<String>()
        return BSchoolDomain.allCases.compactMap { domain in
            let name = domain.displayName
            return seen.insert(name).inserted ? name : nil
        }.sorted()
    }
}

enum EmailValidator {
    /// Validates that the string is a well-formed email address.
    static func isValidIIMEmail(_ email: String) -> Bool {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return trimmed.range(of: pattern, options: .regularExpression) != nil
    }

    /// Returns the domain portion of the email, lowercased.
    static func domain(of email: String) -> String? {
        let trimmed = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let parts = trimmed.split(separator: "@", maxSplits: 1)
        guard parts.count == 2 else { return nil }
        return String(parts[1])
    }

    /// Returns true when the email domain belongs to a known B-school.
    static func isKnownBSchoolDomain(_ email: String) -> Bool {
        guard let d = domain(of: email) else { return false }
        return BSchoolDomain.allCases.contains { $0.rawValue == d }
    }

    /// Returns the `BSchoolDomain` for the email's domain, if it matches.
    static func bSchoolDomain(for email: String) -> BSchoolDomain? {
        guard let d = domain(of: email) else { return nil }
        return BSchoolDomain.allCases.first { $0.rawValue == d }
    }

    /// Returns the institution display name inferred from the email domain.
    static func institutionName(for email: String) -> String? {
        bSchoolDomain(for: email)?.displayName
    }
}

enum PasswordValidator {
    static func isValid(_ password: String) -> Bool {
        password.count >= 8
    }
}
