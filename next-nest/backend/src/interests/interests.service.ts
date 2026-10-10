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

  async getInterestStatus(userId: string, targetProfileId: string) {
    const myProfile = await this.prisma.matrimonialProfile.findUnique({
      where: { userId },
    });
    if (!myProfile) {
      return { status: "NONE" };
    }
    const myProfileId = myProfile.id;
    if (myProfileId === targetProfileId) {
      return { status: "SELF" };
    }

    // Check if I sent to target
    const sent = await this.prisma.matchInterest.findFirst({
      where: {
        senderProfileId: myProfileId,
        receiverProfileId: targetProfileId,
      },
    });

    // Check if target sent to me
    const received = await this.prisma.matchInterest.findFirst({
      where: {
        senderProfileId: targetProfileId,
        receiverProfileId: myProfileId,
      },
    });

    if (sent?.status === "ACCEPTED" || received?.status === "ACCEPTED") {
      const p1 = myProfileId < targetProfileId ? myProfileId : targetProfileId;
      const p2 = myProfileId < targetProfileId ? targetProfileId : myProfileId;
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

    if (senderProfileId === dto.targetProfileId) {
      throw new BadRequestException("You cannot send a connection request to yourself");
    }

    // Check existing request in either direction
    const existingInterest = await this.prisma.matchInterest.findFirst({
      where: {
        OR: [
          { senderProfileId, receiverProfileId: dto.targetProfileId },
          { senderProfileId: dto.targetProfileId, receiverProfileId: senderProfileId },
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
        receiverProfileId: dto.targetProfileId,
        status: "PENDING",
      },
    });

    // Notify Receiver
    try {
      const receiverProfile = await this.prisma.matrimonialProfile.findUnique({
        where: { id: dto.targetProfileId },
      });
      if (receiverProfile?.userId) {
        const senderName = `${senderProfile.firstName} ${senderProfile.lastName}`.trim();
        await this.prisma.userNotification.create({
          data: {
            userId: receiverProfile.userId,
            title: "નવી કનેક્શન વિનંતી (New Connection Request)",
            message: `${senderName} એ તમને કનેક્શન વિનંતી મોકલી છે. પ્રોફાઇલ જુઓ અને સ્વીકારો.`,
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

    if (
      interest.receiverProfileId !== receiverProfileId &&
      interest.senderProfileId !== receiverProfileId
    ) {
      throw new BadRequestException(
        "You can only accept connection requests involving your profile",
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
            message: `${myName} એ તમારી કનેક્શન વિનંતી સ્વીકારી લીધી છે! હવે તમે એકબીજા સાથે ચેટ કરી શકો છો.`,
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
    });
    const profileMap = new Map(profiles.map((p) => [p.id, p]));

    return interests.map((i) => ({
      ...i,
      receiverProfile: profileMap.get(i.receiverProfileId) || null,
    }));
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
    });
    const profileMap = new Map(profiles.map((p) => [p.id, p]));

    return interests.map((i) => ({
      ...i,
      senderProfile: profileMap.get(i.senderProfileId) || null,
    }));
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
    });
    const profileMap = new Map(profiles.map((p) => [p.id, p]));

    const conversations = await this.prisma.chatConversation.findMany({
      where: {
        OR: [
          { participant1Id: userId },
          { participant2Id: userId },
        ],
      },
    });

    return interests.map((i) => {
      const otherProfileId = i.senderProfileId === myProfile.id ? i.receiverProfileId : i.senderProfileId;
      const otherProfile = profileMap.get(otherProfileId) || null;
      const matchedConv = conversations.find(
        (c) =>
          otherProfile &&
          (c.participant1Id === otherProfile.userId || c.participant2Id === otherProfile.userId),
      );

      return {
        ...i,
        otherProfile,
        conversationId: matchedConv?.id || null,
      };
    });
  }
}
