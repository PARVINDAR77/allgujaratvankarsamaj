export declare class ForgotPasswordDto {
    identifier: string;
}
export declare class VerifyResetCodeDto {
    identifier: string;
    code: string;
}
export declare class ResetPasswordDto {
    identifier: string;
    code: string;
    newPassword: string;
}
