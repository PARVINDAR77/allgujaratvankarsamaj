import {
  registerDecorator,
  ValidationOptions,
  ValidationArguments,
} from "class-validator";

export function IsMinAge(
  minAge: number = 18,
  validationOptions?: ValidationOptions,
) {
  return function (object: object, propertyName: string) {
    registerDecorator({
      name: "isMinAge",
      target: object.constructor,
      propertyName: propertyName,
      options: validationOptions,
      validator: {
        validate(value: any, args: ValidationArguments) {
          if (!value || typeof value !== "string") return false;
          const dob = new Date(value);
          if (isNaN(dob.getTime())) return false;

          const today = new Date();

          // Reject future dates
          if (dob > today) return false;

          let age = today.getFullYear() - dob.getFullYear();
          const monthDiff = today.getMonth() - dob.getMonth();
          const dayDiff = today.getDate() - dob.getDate();

          if (monthDiff < 0 || (monthDiff === 0 && dayDiff < 0)) {
            age--;
          }

          return age >= minAge;
        },
        defaultMessage(args: ValidationArguments) {
          return `${args.property} must be a valid date representing an age of at least ${minAge} years and cannot be in the future`;
        },
      },
    });
  };
}
