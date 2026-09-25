-- CreateEnum
CREATE TYPE "Gender" AS ENUM ('MALE', 'FEMALE', 'OTHER');

-- CreateEnum
CREATE TYPE "MaritalStatus" AS ENUM ('NEVER_MARRIED', 'DIVORCED', 'WIDOWED', 'SEPARATED');

-- CreateTable
CREATE TABLE "matrimonial_profiles" (
    "id" TEXT NOT NULL,
    "user_id" TEXT NOT NULL,
    "first_name" TEXT NOT NULL,
    "last_name" TEXT NOT NULL,
    "date_of_birth" TIMESTAMP(3) NOT NULL,
    "gender" "Gender" NOT NULL,
    "marital_status" "MaritalStatus" NOT NULL,
    "religion" TEXT,
    "caste" TEXT,
    "city" TEXT,
    "state" TEXT,
    "country" TEXT,
    "education" TEXT,
    "occupation" TEXT,
    "about" TEXT,
    "created_at" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updated_at" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "matrimonial_profiles_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "matrimonial_profiles_user_id_key" ON "matrimonial_profiles"("user_id");

-- AddForeignKey
ALTER TABLE "matrimonial_profiles" ADD CONSTRAINT "matrimonial_profiles_user_id_fkey" FOREIGN KEY ("user_id") REFERENCES "users"("id") ON DELETE CASCADE ON UPDATE CASCADE;
