import { Injectable } from "@nestjs/common";
import {
  MatrimonialProfile,
  ProfileStatus,
  User,
  Status,
  Role,
} from "@prisma/client";
import {
  Capability,
  RoleCapabilities,
} from "../../auth/constants/capabilities";

type ProfileWithUser = MatrimonialProfile & { user?: User };

@Injectable()
export class ProfileVisibilityPolicy {
  /**
   * Determines if a profile is publicly visible to a specific viewer.
   * Centralizes all visibility logic so it's not duplicated across controllers.
   */
  isProfilePubliclyVisible(
    profile: ProfileWithUser,
    viewer?: Partial<User>,
  ): boolean {
    if (!profile) {
      return false;
    }

    // 1. Check Profile-level status
    if (profile.status !== ProfileStatus.APPROVED) {
      // If the viewer owns the profile, they can see it regardless of approval status
      if (viewer && viewer.id === profile.userId) {
        return true;
      }

      // If the viewer has PROFILES_READ_PRIVATE capability (e.g. Admin), they can see it
      if (viewer && viewer.role) {
        const capabilities = RoleCapabilities[viewer.role as Role] || [];
        if (capabilities.includes(Capability.PROFILES_READ_PRIVATE)) {
          return true;
        }
      }

      return false;
    }

    // 2. Check User-level status (if user relation is joined)
    if (profile.user && profile.user.status !== Status.ACTIVE) {
      return false;
    }

    // 3. (Optional) Check if the profile is verified.
    // Depending on business rules, maybe only verified profiles are public?
    // Uncomment or modify if strict verification is required to be visible:
    // if (!profile.isVerified) return false;

    // Default to visible if all checks pass
    return true;
  }
}
