import { Gender, MaritalStatus } from "@prisma/client";

/**
 * Normalizes any incoming string or value to Prisma Gender enum.
 */
export function normalizeGender(val: any): Gender | undefined {
  if (val === null || val === undefined) return undefined;
  const s = String(val).trim().toUpperCase();
  if (!s) return undefined;

  // Check Female / Bride / Girl / Kanya / Stri
  if (
    s === "FEMALE" ||
    s === "BRIDE" ||
    s === "GIRL" ||
    s === "WOMAN" ||
    s.includes("FEMALE") ||
    s.includes("BRIDE") ||
    s.includes("GIRL") ||
    s.includes("સ્ત્રી") ||
    s.includes("કન્યા")
  ) {
    return Gender.FEMALE;
  }

  // Check Male / Groom / Boy / Var / Purush
  if (
    s === "MALE" ||
    s === "GROOM" ||
    s === "BOY" ||
    s === "MAN" ||
    s.includes("MALE") ||
    s.includes("GROOM") ||
    s.includes("BOY") ||
    s.includes("પુરુષ") ||
    s.includes("વર")
  ) {
    return Gender.MALE;
  }

  if (s === "OTHER" || s.includes("OTHER") || s.includes("અન્ય")) {
    return Gender.OTHER;
  }

  return undefined;
}

/**
 * Normalizes any incoming string or value to Prisma MaritalStatus enum.
 */
export function normalizeMaritalStatus(val: any): MaritalStatus | undefined {
  if (val === null || val === undefined) return undefined;
  const s = String(val).trim().toUpperCase();
  if (!s) return undefined;

  if (s.includes("DIVORC") || s.includes("છૂટાછેડા લીધેલ")) {
    return MaritalStatus.DIVORCED;
  }
  if (s.includes("WIDOW") || s.includes("વિધવા") || s.includes("વિધુર")) {
    return MaritalStatus.WIDOWED;
  }
  if (s.includes("SEPARAT") || s.includes("AWAITING") || s.includes("રાહમાં")) {
    return MaritalStatus.SEPARATED;
  }
  if (
    s.includes("NEVER") ||
    s.includes("UNMARRIED") ||
    s.includes("SINGLE") ||
    s.includes("અપરિણીત") ||
    s.includes("અવિવાહિત")
  ) {
    return MaritalStatus.NEVER_MARRIED;
  }
  if (
    (s.includes("MARRIED") && !s.includes("NEVER") && !s.includes("UN")) ||
    (s.includes("પરિણીત") && !s.includes("અપરિણીત")) ||
    (s.includes("વિવાહિત") && !s.includes("અવિવાહિત"))
  ) {
    return MaritalStatus.MARRIED;
  }

  return undefined;
}
