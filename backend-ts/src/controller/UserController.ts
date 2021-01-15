import { NextFunction, Request, Response } from "express";
import { getRepository } from "typeorm";
import User from "../entity/User";

export class UserController {
  private userRepository = getRepository(User);

  async all(_: Request, _response: Response, _next: NextFunction) {
    return this.userRepository.find();
  }

  async one(request: Request, _response: Response, _next: NextFunction) {
    return this.userRepository.findOne(request.params.id);
  }

  async save(request: Request, _response: Response, _next: NextFunction) {
    return this.userRepository.save(request.body);
  }

  async remove(request: Request, _response: Response, _next: NextFunction) {
    const userToRemove = await this.userRepository.findOne(request.params.id);
    if (userToRemove) await this.userRepository.remove(userToRemove);
  }
}
