import argon2 from "argon2";
import { NextFunction, Request, Response } from "express";
import jwt from "jsonwebtoken";
import { getRepository, Repository } from "typeorm";
import User from "../entity/User";
import { AuthResult, isAuth, ReturnUser, useAuth } from "../utils/useAuth";
import {
  chainResults,
  validateEmail,
  validatePassword,
  validateUsername,
  ValidationError,
  ValidationResult,
} from "../utils/validateInput";

type Profile = {
  profile: {
    username: string;
    bio: string;
    image: string | null;
    following?: boolean;
  };
};

export const getProfile = async (
  currentUsername: string | undefined,
  profileUsername: string,
  response: Response,
  userRepository: Repository<User>
): Promise<Profile | ValidationError> => {
  const profileUser = await userRepository.findOne({
    where: { username: profileUsername },
  });

  if (!profileUser) {
    response.statusCode = 422;
    return { errors: { username: ["username not found"] } };
  }

  if (!currentUsername) {
    return {
      profile: {
        username: profileUser.username,
        bio: profileUser.bio,
        image: profileUser.image,
        following: false,
      },
    };
  }

  const currentUser = await userRepository.findOne({
    where: {
      username: currentUsername,
    },
    relations: ["follows"],
  });

  if (!currentUser) {
    return { errors: { username: ["username not found"] } };
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
};
class UserController {
  private userRepository = getRepository(User);

  generateToken(userId: number) {
    return jwt.sign({ _id: userId }, process.env.JWT_SECRET!, {
      expiresIn: "10y",
    });
  }

  async register(
    request: Request,
    response: Response,
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
      response.statusCode = 422;
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
    response: Response,
    _next: NextFunction
  ): Promise<ValidationError | { user: ReturnUser }> {
    const { email, password } = request.body.user;

    const userWithEmail = await this.userRepository.findOne({
      where: { email },
    });

    if (!userWithEmail) {
      response.statusCode = 422;
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

    if (!isPasswordValid) {
      response.statusCode = 422;
      return {
        errors: {
          password: ["incorrect password"],
        },
      };
    }

    return {
      user: {
        email,
        token: this.generateToken(userWithEmail.id),
        username: userWithEmail.username,
        bio: userWithEmail.bio,
        image: userWithEmail.image,
      },
    };
  }

  async getUser(
    request: Request,
    response: Response,
    _next: NextFunction
  ): Promise<AuthResult> {
    const auth = await useAuth(request, response, this.userRepository);
    if (isAuth(auth)) {
      return { user: auth.user! };
    }

    return { errors: auth.errors! };
  }

  async updateUser(
    request: Request,
    response: Response,
    _next: NextFunction
  ): Promise<ValidationError | ReturnUser | AuthResult> {
    const authResult = await useAuth(request, response, this.userRepository);
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
      response.statusCode = 422;
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
    response: Response,
    _next: NextFunction
  ): Promise<Profile | ValidationError> {
    const profileUsername = request.params.username;
    const auth = await useAuth(request, response, this.userRepository);

    const username = auth.user ? auth.user.username : undefined;
    return await getProfile(
      username,
      profileUsername,
      response,
      this.userRepository
    );
  }

  async followUser(
    request: Request,
    response: Response,
    _next: NextFunction
  ): Promise<Profile | ValidationError> {
    const usernameToFollow = request.params.username;
    const auth = await useAuth(request, response, this.userRepository);

    if (auth.errors) {
      return { errors: auth.errors };
    }

    const userToFollow = await this.userRepository.findOne({
      where: { username: usernameToFollow },
    });

    if (!userToFollow) {
      response.statusCode = 422;
      return {
        errors: { username: ["username not found"] },
      };
    }

    const currentUser = await this.userRepository.findOne({
      where: {
        username: auth.user!.username,
      },
      relations: ["follows"],
    });

    if (!currentUser) {
      response.statusCode = 403;
      return {
        errors: { username: ["username not found"] },
      };
    }

    if (!currentUser.follows.includes(userToFollow)) {
      currentUser.follows.push(userToFollow);
      this.userRepository.save(currentUser!);
    }

    return {
      profile: {
        bio: userToFollow.bio,
        image: userToFollow.image,
        username: userToFollow.username,
        following: true,
      },
    };
  }

  async unfollowUser(
    request: Request,
    response: Response,
    _next: NextFunction
  ): Promise<ValidationError | Profile> {
    const usernameToUnfollow = request.params.username;
    const auth = await useAuth(request, response, this.userRepository);

    if (auth.errors) {
      return { errors: auth.errors };
    }

    const userToUnfollow = await this.userRepository.findOne({
      where: { username: usernameToUnfollow },
    });

    if (!userToUnfollow) {
      response.statusCode = 422;
      return { errors: { username: ["username not found"] } };
    }

    const currentUser = await this.userRepository.findOne({
      where: { username: auth.user!.username },
      relations: ["follows"],
    });

    if (!currentUser) {
      response.statusCode = 403;
      return { errors: { username: ["username not found"] } };
    }

    currentUser.follows = currentUser.follows.filter(
      (user) => user.id !== userToUnfollow.id
    );

    this.userRepository.save(currentUser);

    return {
      profile: {
        bio: userToUnfollow.bio,
        image: userToUnfollow.image,
        username: userToUnfollow.username,
        following: false,
      },
    };
  }
}

export default UserController;
