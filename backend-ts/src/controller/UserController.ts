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

  generateToken(user: User) {
    return jwt.sign({ _id: user.id }, process.env.JWT_SECRET!, {
      expiresIn: "10y",
    });
  }

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

    const token = this.generateToken(newUser);

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

  async login(request: Request, _response: Response, _next: NextFunction) {
    const { email, password } = request.body.user;

    const userWithEmail = await this.userRepository.findOne({
      where: { email },
    });

    if (!userWithEmail) {
      return {
        errors: {
          email: ["email not registered"],
        },
      };
    }

    const isPasswordValid = await argon2.verify(
      userWithEmail.password,
      password
    );

    return isPasswordValid
      ? {
          user: {
            email,
            token: this.generateToken(userWithEmail),
            username: userWithEmail.username,
            bio: userWithEmail.bio,
            image: userWithEmail.image,
          },
        }
      : {
          errors: {
            password: ["incorrect password"],
          },
        };
  }

  async getUser(request: Request, _response: Response, _next: NextFunction) {
    const tokenHeader = request.headers.authorization;

    if (!tokenHeader) {
      return {
        errors: {
          token: ["No token informed"],
        },
      };
    }
    const token = tokenHeader.split(" ")[1];
    const decodedJwt = jwt.decode(token);
    try {
      const userId = (decodedJwt as { _id: number })._id;

      const user = await this.userRepository.findOne(userId);

      if (!user) {
        return {
          errors: {
            token: ["Could not find user"],
          },
        };
      }

      return {
        user: {
          email: user.email,
          token,
          username: user.username,
          bio: user.bio,
          image: user.image,
        },
      };
    } catch {
      return {
        errors: {
          token: ["Error validating user"],
        },
      };
    }
  }
}

export default UserController;
