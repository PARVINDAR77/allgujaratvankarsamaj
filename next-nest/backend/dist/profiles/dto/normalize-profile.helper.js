"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.normalizeGender = normalizeGender;
exports.normalizeMaritalStatus = normalizeMaritalStatus;
const client_1 = require("@prisma/client");
function normalizeGender(val) {
    if (val === null || val === undefined)
        return undefined;
    const s = String(val).trim().toUpperCase();
    if (!s)
        return undefined;
    if (s === "FEMALE" ||
        s === "BRIDE" ||
        s === "GIRL" ||
        s === "WOMAN" ||
        s.includes("FEMALE") ||
        s.includes("BRIDE") ||
        s.includes("GIRL") ||
        s.includes("સ્ત્રી") ||
        s.includes("કન્યા")) {
        return client_1.Gender.FEMALE;
    }
    if (s === "MALE" ||
        s === "GROOM" ||
        s === "BOY" ||
        s === "MAN" ||
        s.includes("MALE") ||
        s.includes("GROOM") ||
        s.includes("BOY") ||
        s.includes("પુરુષ") ||
        s.includes("વર")) {
        return client_1.Gender.MALE;
    }
    if (s === "OTHER" || s.includes("OTHER") || s.includes("અન્ય")) {
        return client_1.Gender.OTHER;
    }
    return undefined;
}
function normalizeMaritalStatus(val) {
    if (val === null || val === undefined)
        return undefined;
    const s = String(val).trim().toUpperCase();
    if (!s)
        return undefined;
    if (s.includes("DIVORC") || s.includes("છૂટાછેડા લીધેલ")) {
        return client_1.MaritalStatus.DIVORCED;
    }
    if (s.includes("WIDOW") || s.includes("વિધવા") || s.includes("વિધુર")) {
        return client_1.MaritalStatus.WIDOWED;
    }
    if (s.includes("SEPARAT") || s.includes("AWAITING") || s.includes("રાહમાં")) {
        return client_1.MaritalStatus.SEPARATED;
    }
    if (s.includes("NEVER") ||
        s.includes("UNMARRIED") ||
        s.includes("SINGLE") ||
        s.includes("અપરિણીત") ||
        s.includes("અવિવાહિત")) {
        return client_1.MaritalStatus.NEVER_MARRIED;
    }
    if ((s.includes("MARRIED") && !s.includes("NEVER") && !s.includes("UN")) ||
        (s.includes("પરિણીત") && !s.includes("અપરિણીત")) ||
        (s.includes("વિવાહિત") && !s.includes("અવિવાહિત"))) {
        return client_1.MaritalStatus.MARRIED;
    }
    return undefined;
}
//# sourceMappingURL=normalize-profile.helper.js.map