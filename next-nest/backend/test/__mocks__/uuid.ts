import * as crypto from "crypto";

export const v4 = (): string =>
  crypto.randomUUID ? crypto.randomUUID() : "123e4567-e89b-12d3-a456-426614174000";

export const v1 = (): string => "123e4567-e89b-12d3-a456-426614174000";
