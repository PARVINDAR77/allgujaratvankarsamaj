"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.Capabilities = exports.CAPABILITIES_KEY = void 0;
const common_1 = require("@nestjs/common");
exports.CAPABILITIES_KEY = "capabilities";
const Capabilities = (...capabilities) => (0, common_1.SetMetadata)(exports.CAPABILITIES_KEY, capabilities);
exports.Capabilities = Capabilities;
//# sourceMappingURL=capabilities.decorator.js.map