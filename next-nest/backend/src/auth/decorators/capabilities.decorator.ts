import { SetMetadata } from "@nestjs/common";
import { Capability } from "../constants/capabilities";

export const CAPABILITIES_KEY = "capabilities";
export const Capabilities = (...capabilities: Capability[]) =>
  SetMetadata(CAPABILITIES_KEY, capabilities);
