import { MatrimonialProfile, User } from "@prisma/client";
type ProfileWithUser = MatrimonialProfile & {
    user?: User;
};
export declare class ProfileVisibilityPolicy {
    isProfilePubliclyVisible(profile: ProfileWithUser, viewer?: Partial<User>): boolean;
}
export {};
