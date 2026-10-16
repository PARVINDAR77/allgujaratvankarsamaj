import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { CreateInterestDto } from "./dto/create-interest.dto";

@Injectable()
export class InterestsService {
  constructor(private readonly prisma: PrismaService) {}

  private async getProfileIdForUser(userId: string) {
    const profile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!profile) {
      throw new BadRequestException(
        "You must create a profile before sending connection requests",
      );
    }
    return profile.id;
  }

  private get profileInclude() {
    return {
      district: true,
      taluka: true,
      pargana: true,
      village: true,
      stateRef: true,
      user: {
        select: { phone: true, email: true },
      },
      governmentEmployment: {
        include: {
          department: true,
          designation: true,
        },
      },
    };
  }

  async getInterestStatus(userId: string, targetProfileId: string) {
    const myProfile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!myProfile) {
      return { status: "NONE" };
    }
    const myProfileId = myProfile.id;

    // Resolve target profile by id or userId
    const targetProfile = await this.prisma.matrimonialProfile.findFirst({
      where: {
        OR: [{ id: targetProfileId }, { userId: targetProfileId }],
      },
    });
    if (!targetProfile) {
      return { status: "NONE" };
    }
    const resolvedTargetId = targetProfile.id;

    if (myProfileId === resolvedTargetId) {
      return { status: "SELF" };
    }

    // Check if I sent to target
    const sent = await this.prisma.matchInterest.findFirst({
      where: {
        senderProfileId: myProfileId,
        receiverProfileId: resolvedTargetId,
      },
    });

    // Check if target sent to me
    const received = await this.prisma.matchInterest.findFirst({
      where: {
        senderProfileId: resolvedTargetId,
        receiverProfileId: myProfileId,
      },
    });

    if (sent?.status === "ACCEPTED" || received?.status === "ACCEPTED") {
      const p1 = myProfileId < resolvedTargetId ? myProfileId : resolvedTargetId;
      const p2 = myProfileId < resolvedTargetId ? resolvedTargetId : myProfileId;
      const conversation = await this.prisma.chatConversation.findUnique({
        where: { participant1Id_participant2Id: { participant1Id: p1, participant2Id: p2 } },
      });
      return {
        status: "ACCEPTED",
        interestId: sent?.id || received?.id,
        conversationId: conversation?.id,
      };
    }

    if (sent) {
      return {
        status: sent.status === "PENDING" ? "PENDING_SENT" : sent.status,
        interestId: sent.id,
      };
    }

    if (received) {
      return {
        status: received.status === "PENDING" ? "PENDING_RECEIVED" : received.status,
        interestId: received.id,
      };
    }

    return { status: "NONE" };
  }

  async sendInterest(userId: string, dto: CreateInterestDto) {
    const senderProfile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!senderProfile) {
      throw new BadRequestException(
        "You must create a profile before sending connection requests",
      );
    }
    const senderProfileId = senderProfile.id;

    // Resolve target profile by id or userId
    const targetProfile = await this.prisma.matrimonialProfile.findFirst({
      where: {
        OR: [{ id: dto.targetProfileId }, { userId: dto.targetProfileId }],
      },
    });
    if (!targetProfile) {
      throw new BadRequestException("Target candidate profile not found");
    }
    const resolvedTargetId = targetProfile.id;

    if (senderProfileId === resolvedTargetId) {
      throw new BadRequestException("You cannot send a connection request to yourself");
    }

    if (senderProfile.maritalStatus === "MARRIED") {
      throw new BadRequestException("પરિણીત સભ્યો મેટ્રિમોની સંબંધ પ્રસ્તાવ મોકલી શકતા નથી (Married members cannot send matrimonial proposals)");
    }

    if (targetProfile.maritalStatus === "MARRIED") {
      throw new BadRequestException("પસંદ કરેલ સભ્ય પરિણીત હોવાથી મેટ્રિમોની પ્રસ્તાવ મોકલી શકાતો નથી (Cannot send matrimonial interest to a married member)");
    }

    // Check existing request in either direction
    const existingInterest = await this.prisma.matchInterest.findFirst({
      where: {
        OR: [
          { senderProfileId, receiverProfileId: resolvedTargetId },
          { senderProfileId: resolvedTargetId, receiverProfileId: senderProfileId },
        ],
      },
    });

    if (existingInterest) {
      if (existingInterest.status === "ACCEPTED") {
        return { message: "Already connected", status: "ACCEPTED", interest: existingInterest };
      }
      if (existingInterest.senderProfileId === senderProfileId) {
        return { message: "Request already sent", status: "PENDING_SENT", interest: existingInterest };
      } else {
        // Target candidate already sent a request to current user, so accept it!
        return this.acceptInterest(userId, existingInterest.id);
      }
    }

    const created = await this.prisma.matchInterest.create({
      data: {
        senderProfileId,
        receiverProfileId: resolvedTargetId,
        status: "PENDING",
      },
    });

    // Notify Receiver
    try {
      if (targetProfile.userId) {
        const senderName = `${senderProfile.firstName} ${senderProfile.lastName}`.trim();
        await this.prisma.userNotification.create({
          data: {
            userId: targetProfile.userId,
            title: "નવી સંબંધ વિનંતી (New Connection Request)",
            message: `${senderName} તરફથી તમને નવી સંબંધ વિનંતી મળી છે. વિનંતી જુઓ અને સ્વીકારો.`,
            type: "CONNECTION_REQUEST",
            metadata: JSON.stringify({
              senderProfileId,
              senderName,
              interestId: created.id,
            }),
          },
        });
      }
    } catch (_) {}

    return { message: "Connection request sent successfully", status: "PENDING_SENT", interest: created };
  }

  async acceptInterest(userId: string, interestId: string) {
    const receiverProfile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!receiverProfile) {
      throw new BadRequestException("Profile not found");
    }
    const receiverProfileId = receiverProfile.id;

    const interest = await this.prisma.matchInterest.findUnique({
      where: { id: interestId },
    });

    if (!interest) {
      throw new NotFoundException("Interest not found");
    }

    if (interest.receiverProfileId !== receiverProfileId) {
      throw new BadRequestException(
        "તમને મળેલી સંબંધ વિનંતીઓ જ તમે સ્વીકારી શકો છો (You can only accept connection requests sent directly to you)",
      );
    }

    if (interest.status !== "PENDING") {
      throw new BadRequestException(
        `Cannot accept interest with status "${interest.status}"`,
      );
    }

    const updated = await this.prisma.matchInterest.update({
      where: { id: interestId },
      data: { status: "ACCEPTED" },
    });

    // Create or find Conversation Room
    const p1 = interest.senderProfileId < interest.receiverProfileId ? interest.senderProfileId : interest.receiverProfileId;
    const p2 = interest.senderProfileId < interest.receiverProfileId ? interest.receiverProfileId : interest.senderProfileId;

    let conversation = await this.prisma.chatConversation.findUnique({
      where: {
        participant1Id_participant2Id: {
          participant1Id: p1,
          participant2Id: p2,
        },
      },
    });

    if (!conversation) {
      conversation = await this.prisma.chatConversation.create({
        data: {
          participant1Id: p1,
          participant2Id: p2,
        },
      });
    }

    // Notify the other candidate
    try {
      const otherProfileId =
        interest.senderProfileId === receiverProfileId
          ? interest.receiverProfileId
          : interest.senderProfileId;
      const otherProfile = await this.prisma.matrimonialProfile.findUnique({
        where: { id: otherProfileId },
      });

      if (otherProfile?.userId) {
        const myName = `${receiverProfile.firstName} ${receiverProfile.lastName}`.trim();
        await this.prisma.userNotification.create({
          data: {
            userId: otherProfile.userId,
            title: "વિનંતી સ્વીકારાઈ! (Connection Accepted)",
            message: `${myName} એ તમારી સંબંધ વિનંતી સ્વીકારી લીધી છે! હવે તમે એકબીજા સાથે ચેટ કરી શકો છો.`,
            type: "REQUEST_ACCEPTED",
            metadata: JSON.stringify({
              partnerProfileId: receiverProfileId,
              partnerName: myName,
              conversationId: conversation.id,
            }),
          },
        });
      }
    } catch (_) {}

    return {
      message: "Connection request accepted successfully",
      status: "ACCEPTED",
      interest: updated,
      conversationId: conversation.id,
    };
  }

  async declineInterest(userId: string, interestId: string) {
    const receiverProfileId = await this.getProfileIdForUser(userId);

    const interest = await this.prisma.matchInterest.findUnique({
      where: { id: interestId },
    });

    if (!interest) {
      throw new NotFoundException("Interest not found");
    }

    if (interest.receiverProfileId !== receiverProfileId) {
      throw new BadRequestException(
        "You can only decline interests sent to you",
      );
    }

    if (interest.status !== "PENDING") {
      throw new BadRequestException(
        `Cannot decline interest with status "${interest.status}"`,
      );
    }

    return this.prisma.matchInterest.update({
      where: { id: interestId },
      data: { status: "DECLINED" },
    });
  }

  async getSentInterests(userId: string) {
    const myProfile = await this.prisma.matrimonialProfile.findUnique({ where: { userId } });
    if (!myProfile) return [];

    const interests = await this.prisma.matchInterest.findMany({
      where: { senderProfileId: myProfile.id },
      orderBy: { createdAt: "desc" },
    });

    const receiverIds = interests.map((i) => i.receiverProfileId);
    const profiles = await this.prisma.matrimonialProfile.findMany({
      where: { id: { in: receiverIds } },
      include: this.profileInclude,
    });
    const profileMap = new Map(profiles.map((p) => [p.id, p]));

    return interests.map((i) => {
      const p = profileMap.get(i.receiverProfileId);
      if (!p) return { ...i, receiverProfile: null };
      if (i.status === "ACCEPTED") {
        return { ...i, receiverProfile: p };
      }
      const { user: _, ...rest } = p as any;
      return {
        ...i,
        receiverProfile: {
          ...rest,
          contactPhone: null,
          contactEmail: null,
          altPhone: null,
          fatherContact: null,
          guardianContact: null,
          addressLine: null,
          pincode: null,
        },
      };
    });
  }

  async getReceivedInterests(userId: string) {
    const myProfile = await this.prisma.matrimonialProfile.findUnique({ where: { userId } });
    if (!myProfile) return [];

    const interests = await this.prisma.matchInterest.findMany({
      where: { receiverProfileId: myProfile.id },
      orderBy: { createdAt: "desc" },
    });

    const senderIds = interests.map((i) => i.senderProfileId);
    const profiles = await this.prisma.matrimonialProfile.findMany({
      where: { id: { in: senderIds } },
      include: this.profileInclude,
    });
    const profileMap = new Map(profiles.map((p) => [p.id, p]));

    return interests.map((i) => {
      const p = profileMap.get(i.senderProfileId);
      if (!p) return { ...i, senderProfile: null };
      if (i.status === "ACCEPTED") {
        return { ...i, senderProfile: p };
      }
      const { user: _, ...rest } = p as any;
      return {
        ...i,
        senderProfile: {
          ...rest,
          contactPhone: null,
          contactEmail: null,
          altPhone: null,
          fatherContact: null,
          guardianContact: null,
          addressLine: null,
          pincode: null,
        },
      };
    });
  }

  async getMutualInterests(userId: string) {
    const myProfile = await this.prisma.matrimonialProfile.findUnique({ where: { userId } });
    if (!myProfile) return [];

    const interests = await this.prisma.matchInterest.findMany({
      where: {
        status: "ACCEPTED",
        OR: [
          { senderProfileId: myProfile.id },
          { receiverProfileId: myProfile.id },
        ],
      },
      orderBy: { createdAt: "desc" },
    });

    const otherProfileIds = interests.map((i) =>
      i.senderProfileId === myProfile.id ? i.receiverProfileId : i.senderProfileId,
    );

    const profiles = await this.prisma.matrimonialProfile.findMany({
      where: { id: { in: otherProfileIds } },
      include: this.profileInclude,
    });
    const profileMap = new Map(profiles.map((p) => [p.id, p]));

    const conversations = await this.prisma.chatConversation.findMany({
      where: {
        OR: [
          { participant1Id: myProfile.id },
          { participant2Id: myProfile.id },
        ],
      },
    });

    return interests.map((i) => {
      const otherProfileId = i.senderProfileId === myProfile.id ? i.receiverProfileId : i.senderProfileId;
      const otherProfile = profileMap.get(otherProfileId) || null;
      const matchedConv = conversations.find(
        (c) =>
          otherProfile &&
          (c.participant1Id === otherProfile.id || c.participant2Id === otherProfile.id),
      );

      return {
        ...i,
        otherProfile,
        conversationId: matchedConv?.id || null,
      };
    });
  }
}
