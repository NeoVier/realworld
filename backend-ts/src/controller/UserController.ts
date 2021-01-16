import argon2 from "argon2";
import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { getRepository } from "typeorm";
import User from "../entity/User";
import {
  chainResults,
  validateEmail,
  validatePassword,
  validateUsername,
} from "../utils/validateInput";

class UserController {
  private userRepository = getRepository(User);

  // async all(_: Request, _response: Response, _next: NextFunction) {
  //   return this.userRepository.find();
  // }

  // async one(request: Request, _response: Response, _next: NextFunction) {
  //   return this.userRepository.findOne(request.params.id);
  // }

  // async save(request: Request, _response: Response, _next: NextFunction) {
  //   return this.userRepository.save(request.body);
  // }

  async register(request: Request, _response: Response, _next: NextFunction) {
    const { username, email, password } = request.body.user;

    const existingUsers = await this.userRepository.find();
    const takenEmails = existingUsers.map((user) => user.email);
    const takenUsernames = existingUsers.map((user) => user.username);

    const validation = chainResults([
      validateUsername(username, takenUsernames),
      validateEmail(email, takenEmails),
      validatePassword(password),
    ]);

    if (validation !== "ok") {
      return validation;
    }

    const hashedPassword = await argon2.hash(password);

    const newUser = await this.userRepository.save(
      this.userRepository.create({
        email,
        username,
        password: hashedPassword,
        bio: "",
        image: "",
        articles: [],
        favorited: [],
        followedBy: [],
        follows: [],
        comments: [],
      })
    );

    const token = jwt.sign({ _id: newUser.id }, process.env.JWT_SECRET!);

    return {
      user: {
        email,
        token,
        username,
        bio: newUser.bio,
        image: newUser.image,
      },
    };
  }

  // async remove(request: Request, _response: Response, _next: NextFunction) {
  //   const userToRemove = await this.userRepository.findOne(request.params.id);
  //   if (userToRemove) await this.userRepository.remove(userToRemove);
  // }
}

export default UserController;
