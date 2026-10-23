import { SamajSuperStarsService } from "./samaj-super-stars.service";
export declare class SamajSuperStarsController {
    private readonly starsService;
    constructor(starsService: SamajSuperStarsService);
    findAllPublic(): Promise<any>;
    findAllAdmin(): Promise<any>;
    create(createDto: any): Promise<any>;
    update(id: string, updateDto: any): Promise<any>;
    remove(id: string): Promise<any>;
}
