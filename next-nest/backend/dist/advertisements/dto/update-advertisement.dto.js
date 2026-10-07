"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateAdvertisementDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_advertisement_dto_1 = require("./create-advertisement.dto");
class UpdateAdvertisementDto extends (0, swagger_1.PartialType)(create_advertisement_dto_1.CreateAdvertisementDto) {
}
exports.UpdateAdvertisementDto = UpdateAdvertisementDto;
//# sourceMappingURL=update-advertisement.dto.js.map