"use strict";
Object.defineProperty(exports, "__esModule", { value: true });
exports.IsMinAge = IsMinAge;
const class_validator_1 = require("class-validator");
function IsMinAge(minAge = 18, validationOptions) {
    return function (object, propertyName) {
        (0, class_validator_1.registerDecorator)({
            name: "isMinAge",
            target: object.constructor,
            propertyName: propertyName,
            options: validationOptions,
            validator: {
                validate(value, args) {
                    if (!value || typeof value !== "string")
                        return false;
                    const dob = new Date(value);
                    if (isNaN(dob.getTime()))
                        return false;
                    const today = new Date();
                    if (dob > today)
                        return false;
                    let age = today.getFullYear() - dob.getFullYear();
                    const monthDiff = today.getMonth() - dob.getMonth();
                    const dayDiff = today.getDate() - dob.getDate();
                    if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
                        age--;
                    }
                    return age >= minAge;
                },
                defaultMessage(args) {
                    return `${args.property} must be a valid date representing an age of at least ${minAge} years and cannot be in the future`;
                },
            },
        });
    };
}
//# sourceMappingURL=is-min-age.validator.js.map