import { ValidationOptions } from "class-validator";
export declare function IsMinAge(minAge?: number, validationOptions?: ValidationOptions): (object: object, propertyName: string) => void;
