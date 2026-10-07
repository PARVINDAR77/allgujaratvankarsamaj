"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.ReportStatus = exports.InterestStatus = exports.VerificationStatus = exports.ProfileStatus = exports.MaritalStatus = exports.Gender = exports.Status = exports.Role = void 0;
var Role;
(function (Role) {
    Role["USER"] = "USER";
    Role["SUPER_ADMIN"] = "SUPER_ADMIN";
    Role["ADMIN"] = "ADMIN";
    Role["VERIFICATION_ADMIN"] = "VERIFICATION_ADMIN";
    Role["CONTENT_ADMIN"] = "CONTENT_ADMIN";
})(Role || (exports.Role = Role = {}));
var Status;
(function (Status) {
    Status["ACTIVE"] = "ACTIVE";
    Status["INACTIVE"] = "INACTIVE";
})(Status || (exports.Status = Status = {}));
var Gender;
(function (Gender) {
    Gender["MALE"] = "MALE";
    Gender["FEMALE"] = "FEMALE";
    Gender["OTHER"] = "OTHER";
})(Gender || (exports.Gender = Gender = {}));
var MaritalStatus;
(function (MaritalStatus) {
    MaritalStatus["NEVER_MARRIED"] = "NEVER_MARRIED";
    MaritalStatus["MARRIED"] = "MARRIED";
    MaritalStatus["DIVORCED"] = "DIVORCED";
    MaritalStatus["WIDOWED"] = "WIDOWED";
    MaritalStatus["SEPARATED"] = "SEPARATED";
})(MaritalStatus || (exports.MaritalStatus = MaritalStatus = {}));
var ProfileStatus;
(function (ProfileStatus) {
    ProfileStatus["PENDING"] = "PENDING";
    ProfileStatus["APPROVED"] = "APPROVED";
    ProfileStatus["REJECTED"] = "REJECTED";
    ProfileStatus["SUSPENDED"] = "SUSPENDED";
})(ProfileStatus || (exports.ProfileStatus = ProfileStatus = {}));
var VerificationStatus;
(function (VerificationStatus) {
    VerificationStatus["PENDING"] = "PENDING";
    VerificationStatus["VERIFIED"] = "VERIFIED";
    VerificationStatus["REJECTED"] = "REJECTED";
})(VerificationStatus || (exports.VerificationStatus = VerificationStatus = {}));
var InterestStatus;
(function (InterestStatus) {
    InterestStatus["PENDING"] = "PENDING";
    InterestStatus["ACCEPTED"] = "ACCEPTED";
    InterestStatus["DECLINED"] = "DECLINED";
})(InterestStatus || (exports.InterestStatus = InterestStatus = {}));
var ReportStatus;
(function (ReportStatus) {
    ReportStatus["OPEN"] = "OPEN";
    ReportStatus["RESOLVED"] = "RESOLVED";
    ReportStatus["DISMISSED"] = "DISMISSED";
})(ReportStatus || (exports.ReportStatus = ReportStatus = {}));
//# sourceMappingURL=profile.enums.js.map