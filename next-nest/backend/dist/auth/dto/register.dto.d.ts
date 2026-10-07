export declare enum GenderDto {
    Male = "Male",
    Female = "Female",
    Other = "Other"
}
export declare class RegisterDto {
    name?: string;
    phone?: string;
    email?: string;
    gender?: GenderDto;
    password: string;
}
