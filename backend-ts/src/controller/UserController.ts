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
  ValidationError,
  ValidationResult,
} from "../utils/validateInput";

type ReturnUser = {
  email: string;
  token: string;
  username: string;
  bio: string;
  image: string | null;
};

type AuthResult = {
  user?: ReturnUser;
  id?: number;
  errors?: {
    token: string[];
  };
};

type Profile = {
  profile: {
    username: string;
    bio: string;
    image: string | null;
    following?: boolean;
  };
};

const isAuth = (authResult: AuthResult): boolean => {
  return !!authResult.user;
};

class UserController {
  private userRepository = getRepository(User);

  generateToken(userId: number) {
    return jwt.sign({ _id: userId }, process.env.JWT_SECRET!, {
      expiresIn: "10y",
    });
  }

  async useAuth(request: Request): Promise<AuthResult> {
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
        id: userId,
      };
    } catch {
      return {
        errors: {
          token: ["Error validating user"],
        },
      };
    }
  }

  async register(
    request: Request,
    _response: Response,
    _next: NextFunction
  ): Promise<{ user: ReturnUser } | ValidationError> {
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

    const token = this.generateToken(newUser.id);

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

  async login(
    request: Request,
    _response: Response,
    _next: NextFunction
  ): Promise<ValidationError | { user: ReturnUser }> {
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
            token: this.generateToken(userWithEmail.id),
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

  async getUser(
    request: Request,
    _response: Response,
    _next: NextFunction
  ): Promise<AuthResult> {
    const auth = await this.useAuth(request);
    if (isAuth(auth)) {
      return { user: auth.user! };
    }

    return { errors: auth.errors! };
  }

  async updateUser(
    request: Request,
    _response: Response,
    _next: NextFunction
  ): Promise<ValidationError | ReturnUser | AuthResult> {
    const authResult = await this.useAuth(request);
    if (!isAuth(authResult)) {
      return authResult;
    }

    const user = authResult.user!;
    const userId = authResult.id!;
    const updatedFields = request.body.user;
    const existingUsers = await this.userRepository.find();
    const existingEmails = existingUsers
      .map((user) => user.email)
      .filter((email) => email !== user.email);
    const existingUsernames = existingUsers
      .map((user) => user.username)
      .filter((username) => username !== user.username);
    const fieldsToValidate: ValidationResult[] = [];

    if (updatedFields.password) {
      fieldsToValidate.push(validatePassword(updatedFields.password));
    }
    if (updatedFields.email) {
      fieldsToValidate.push(validateEmail(updatedFields.email, existingEmails));
    }
    if (updatedFields.username) {
      fieldsToValidate.push(
        validateUsername(updatedFields.username, existingUsernames)
      );
    }
    const validation = chainResults(fieldsToValidate);
    if (validation !== "ok") {
      return validation;
    }

    const newPassword = updatedFields.password;
    if (newPassword) {
      const hashedPassword = argon2.hash(newPassword);
      updatedFields.password = hashedPassword;
    }

    await this.userRepository.update(userId, {
      ...updatedFields,
    });

    return {
      user: {
        email: updatedFields.email ? updatedFields.email : user.email,
        token: this.generateToken(userId),
        username: updatedFields.username
          ? updatedFields.username
          : user.username,
        bio: updatedFields.bio ? updatedFields.bio : user.bio,
        image: updatedFields.image ? updatedFields.image : user.image,
      },
    };
  }

  async getProfile(
    request: Request,
    _response: Response,
    _next: NextFunction
  ): Promise<Profile | ValidationError> {
    const profileUsername = request.params.username;
    const auth = await this.useAuth(request);

    const profileUser = await this.userRepository.findOne({
      where: { username: profileUsername },
    });

    if (!profileUser) {
      return { errors: { username: ["username not found"] } };
    }

    if (auth.errors) {
      return {
        profile: {
          username: profileUser.username,
          bio: profileUser.bio,
          image: profileUser.image,
        },
      };
    }

    const currentUser = await this.userRepository.findOne({
      where: {
        username: auth.user!.username,
      },
      relations: ["follows"],
    });

    if (!currentUser) {
      return {
        errors: { username: ["username not found"] },
      };
    }

    const following = currentUser.follows.includes(profileUser);

    return {
      profile: {
        username: profileUser.username,
        bio: profileUser.bio,
        image: profileUser.image,
        following,
      },
    };
  }
}

export default UserController;
