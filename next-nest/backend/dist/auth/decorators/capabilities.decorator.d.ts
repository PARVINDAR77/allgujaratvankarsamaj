import { Capability } from "../constants/capabilities";
export declare const CAPABILITIES_KEY = "capabilities";
export declare const Capabilities: (...capabilities: Capability[]) => import("@nestjs/common").CustomDecorator<string>;
