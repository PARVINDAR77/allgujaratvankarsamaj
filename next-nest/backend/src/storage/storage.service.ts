import { Injectable, Logger } from "@nestjs/common";
import { v4 as uuidv4 } from "uuid";
import * as fs from "fs/promises";
import * as path from "path";

@Injectable()
export class StorageService {
  private readonly logger = new Logger(StorageService.name);
  private readonly uploadDir = path.join(process.cwd(), "uploads");

  async uploadFile(
    fileBuffer: Buffer,
    mimetype: string,
    originalName: string,
  ): Promise<string> {
    this.logger.log(`Uploading file ${originalName} of type ${mimetype}`);

    // Ensure the uploads directory exists
    await fs.mkdir(this.uploadDir, { recursive: true });

    // Generate a unique filename and return a local URL
    const ext = originalName.split(".").pop() || "";
    const uniqueFilename = `${uuidv4()}.${ext}`;
    const filePath = path.join(this.uploadDir, uniqueFilename);

    // Write file to disk
    await fs.writeFile(filePath, fileBuffer);

    // Return the local URL
    return `http://localhost:3000/uploads/${uniqueFilename}`;
  }

  async deleteFile(fileUrl: string): Promise<void> {
    this.logger.log(`Deleting file at ${fileUrl}`);
    // Simulate delete delay
    await new Promise((resolve) => setTimeout(resolve, 300));
  }
}
