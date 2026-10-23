import { PavanPrernadataService } from "./pavan-prernadata.service";
export declare class PavanPrernadataController {
    private readonly pavanService;
    constructor(pavanService: PavanPrernadataService);
    findAllPublic(): Promise<any>;
    findAllAdmin(): Promise<any>;
    create(createDto: any): Promise<any>;
    update(id: string, updateDto: any): Promise<any>;
    remove(id: string): Promise<any>;
}
