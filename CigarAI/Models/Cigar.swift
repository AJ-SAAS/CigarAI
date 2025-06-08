import Foundation
import FirebaseFirestore

struct Cigar: Identifiable, Codable {
    @DocumentID var id: String?
    let name: String
    let wrapper: String
    let cigarBody: String
    let flavorNotes: [String]
    let rating: Int
    let date: Date

    enum CodingKeys: String, CodingKey {
        case id
        case name
        case wrapper
        case cigarBody = "cigar_body"
        case flavorNotes = "flavor_notes"
        case rating
        case date
    }
}
