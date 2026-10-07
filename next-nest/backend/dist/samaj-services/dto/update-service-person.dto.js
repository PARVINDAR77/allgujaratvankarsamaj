"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.UpdateServicePersonDto = void 0;
const swagger_1 = require("@nestjs/swagger");
const create_service_person_dto_1 = require("./create-service-person.dto");
class UpdateServicePersonDto extends (0, swagger_1.PartialType)(create_service_person_dto_1.CreateServicePersonDto) {
}
exports.UpdateServicePersonDto = UpdateServicePersonDto;
//# sourceMappingURL=update-service-person.dto.js.map